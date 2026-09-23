from typing import Annotated

import httpx
from fastapi import APIRouter, Depends, Header, HTTPException, Request, Response

from app.services.auth import AuthUser, TokenVerifier, Unauthorized
from app.services.revenuecat import delete_customer
from app.services.supabase_rest import SupabaseError, SupabaseRest
from app.services.sync import (
    SettingsOut,
    SettingsPut,
    TasbihDay,
    TasbihOut,
    TasbihPut,
    merge_tasbih,
)

router = APIRouter(prefix="/me", tags=["account"])


def _supabase(request: Request) -> SupabaseRest:
    rest = request.app.state.supabase
    if rest is None:
        raise HTTPException(503, "Accounts aren't available right now.")
    return rest


def current_user(
    request: Request, authorization: Annotated[str | None, Header()] = None
) -> AuthUser:
    """The signed-in user from `Authorization: Bearer <Supabase token>`."""
    verifier: TokenVerifier | None = request.app.state.token_verifier
    if verifier is None:
        raise HTTPException(503, "Accounts aren't available right now.")
    scheme, _, token = (authorization or "").partition(" ")
    if scheme.lower() != "bearer" or not token:
        raise HTTPException(401, "Sign in to sync.")
    try:
        return verifier.verify(token)
    except Unauthorized:
        raise HTTPException(401, "Sign in again to sync.") from None


User = Annotated[AuthUser, Depends(current_user)]
Rest = Annotated[SupabaseRest, Depends(_supabase)]


def _unavailable() -> HTTPException:
    return HTTPException(503, "Sync isn't available right now.")


@router.get("/settings", response_model=SettingsOut)
async def get_settings(user: User, rest: Rest) -> SettingsOut:
    try:
        rows = await rest.select(
            "user_settings",
            user.token,
            {"select": "settings,updated_at", "user_id": f"eq.{user.id}"},
        )
    except SupabaseError:
        raise _unavailable() from None
    if not rows:
        return SettingsOut(settings=None, updated_at=None)
    return SettingsOut.model_validate(rows[0])


@router.put("/settings", response_model=SettingsOut)
async def put_settings(body: SettingsPut, user: User, rest: Rest) -> SettingsOut:
    """Saves the phone's settings unless the account has newer ones; always
    returns what the account now holds."""
    current = await get_settings(user, rest)
    if current.updated_at is None or body.updated_at > current.updated_at:
        try:
            await rest.upsert(
                "user_settings",
                user.token,
                [
                    {
                        "user_id": user.id,
                        "settings": body.settings.model_dump(mode="json"),
                        "updated_at": body.updated_at.isoformat(),
                    }
                ],
                on_conflict="user_id",
            )
        except SupabaseError:
            raise _unavailable() from None
        return SettingsOut(settings=body.settings, updated_at=body.updated_at)
    return current


@router.get("/tasbih", response_model=TasbihOut)
async def get_tasbih(user: User, rest: Rest) -> TasbihOut:
    try:
        rows = await rest.select(
            "tasbih_days",
            user.token,
            {"select": "day,count", "user_id": f"eq.{user.id}", "order": "day.desc"},
        )
    except SupabaseError:
        raise _unavailable() from None
    days = [TasbihDay.model_validate(r) for r in rows]
    return TasbihOut(days=sorted(days, key=lambda d: d.day, reverse=True))


@router.put("/tasbih", response_model=TasbihOut)
async def put_tasbih(body: TasbihPut, user: User, rest: Rest) -> TasbihOut:
    """Merges the phone's daily totals (higher count per day wins) and
    returns the account's full history, for the phone to merge back."""
    stored = {d.day: d.count for d in (await get_tasbih(user, rest)).days}
    changed = merge_tasbih(stored, body.days)
    if changed:
        try:
            await rest.upsert(
                "tasbih_days",
                user.token,
                [
                    {"user_id": user.id, "day": day.isoformat(), "count": count}
                    for day, count in changed.items()
                ],
                on_conflict="user_id,day",
            )
        except SupabaseError:
            raise _unavailable() from None
    stored.update(changed)
    return TasbihOut(
        days=[
            TasbihDay(day=d, count=c) for d, c in sorted(stored.items(), reverse=True)
        ]
    )


@router.delete("", status_code=204)
async def delete_account(request: Request, user: User, rest: Rest) -> Response:
    """Deletes the account and everything synced with it. The RevenueCat
    record goes too when the secret key is configured."""
    try:
        await rest.rpc("delete_my_account", user.token)
    except SupabaseError:
        raise HTTPException(503, "Couldn't delete the account. Try again.") from None
    http: httpx.AsyncClient = request.app.state.http
    await delete_customer(http, request.app.state.config.revenuecat_secret_key, user.id)
    return Response(status_code=204)
