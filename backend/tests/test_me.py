import json
import time
from datetime import date
from types import SimpleNamespace

import httpx
import jwt
import pytest
from cryptography.hazmat.primitives.asymmetric import ec
from fastapi.testclient import TestClient

from app.config import Config
from app.main import app
from app.services.auth import SupabaseTokenVerifier, Unauthorized
from app.services.supabase_rest import SupabaseError, SupabaseRest
from app.services.sync import TasbihDay, merge_tasbih

URL = "https://proj.supabase.co"
KEY = ec.generate_private_key(ec.SECP256R1())
OTHER_KEY = ec.generate_private_key(ec.SECP256R1())


def token(sub="user-1", *, key=KEY, **overrides) -> str:
    claims = {
        "sub": sub,
        "aud": "authenticated",
        "iss": f"{URL}/auth/v1",
        "role": "authenticated",
        "exp": int(time.time()) + 3600,
        **overrides,
    }
    return jwt.encode(claims, key, algorithm="ES256", headers={"kid": "k1"})


def verifier() -> SupabaseTokenVerifier:
    v = SupabaseTokenVerifier(URL)
    # Serve our test public key instead of fetching the project's JWKS.
    v._keys = SimpleNamespace(  # type: ignore[assignment]
        get_signing_key_from_jwt=lambda _: SimpleNamespace(key=KEY.public_key())
    )
    return v


class FakeRest:
    """Supabase with row-level security: each token only sees its user."""

    def __init__(self) -> None:
        self.tables: dict[str, list[dict]] = {"user_settings": [], "tasbih_days": []}
        self.rpcs: list[tuple[str, str]] = []
        self.fail = False

    def _user(self, token: str) -> str:
        return jwt.decode(token, options={"verify_signature": False})["sub"]

    async def select(self, table, token, params):
        if self.fail:
            raise SupabaseError("503")
        me = self._user(token)
        cols = params["select"].split(",")
        rows = [r for r in self.tables[table] if r["user_id"] == me]
        return [{c: r[c] for c in cols} for r in rows]

    async def upsert(self, table, token, rows, on_conflict):
        me = self._user(token)
        keys = on_conflict.split(",")
        for row in rows:
            assert row["user_id"] == me  # RLS would refuse otherwise
            existing = [
                r for r in self.tables[table] if all(r[k] == row[k] for k in keys)
            ]
            if existing:
                existing[0].update(row)
            else:
                self.tables[table].append(dict(row))

    async def rpc(self, function, token):
        self.rpcs.append((function, self._user(token)))


@pytest.fixture
def rest() -> FakeRest:
    return FakeRest()


@pytest.fixture
def client(rest: FakeRest):
    with TestClient(app) as c:
        app.state.token_verifier = verifier()
        app.state.supabase = rest
        app.state.config = Config(URL, "pk", "")
        yield c


def auth(sub="user-1") -> dict[str, str]:
    return {"Authorization": f"Bearer {token(sub)}"}


SETTINGS = {
    "prayer": {"method": "ummAlQura", "asr": "hanafi", "highLatitude": "middleOfNight"},
    "alerts": {
        "sound": "adhan",
        "prayers": {"fajr": {"mode": "adhan", "before": 15, "checkIn": False}},
    },
    "reciter": "sudais",
}


# --- tokens ---------------------------------------------------------------


def test_a_valid_token_identifies_the_user() -> None:
    assert verifier().verify(token("abc")).id == "abc"


@pytest.mark.parametrize(
    "bad",
    [
        token(exp=int(time.time()) - 10),
        token(aud="someone-else"),
        token(iss="https://evil.example/auth/v1"),
        token(role="anon"),
        token(key=OTHER_KEY),
        "not-a-token",
    ],
)
def test_bad_tokens_are_refused(bad: str) -> None:
    with pytest.raises(Unauthorized):
        verifier().verify(bad)


def test_no_or_bad_token_is_401(client: TestClient) -> None:
    r = client.get("/v1/me/settings")
    assert r.status_code == 401
    assert r.json()["error"]["code"] == "unauthorized"
    r = client.get(
        "/v1/me/settings", headers={"Authorization": f"Bearer {token(aud='x')}"}
    )
    assert r.status_code == 401


def test_accounts_not_configured_is_503(client: TestClient) -> None:
    app.state.token_verifier = None
    assert client.get("/v1/me/settings", headers=auth()).status_code == 503


# --- settings -------------------------------------------------------------


def test_settings_round_trip_and_newest_wins(client: TestClient) -> None:
    r = client.get("/v1/me/settings", headers=auth())
    assert r.json() == {"settings": None, "updated_at": None}

    put = {"settings": SETTINGS, "updated_at": "2026-09-24T10:00:00Z"}
    r = client.put("/v1/me/settings", headers=auth(), json=put)
    assert r.status_code == 200
    assert r.json()["settings"]["prayer"]["method"] == "ummAlQura"

    older = {"settings": {"reciter": "alafasy"}, "updated_at": "2026-09-24T09:00:00Z"}
    r = client.put("/v1/me/settings", headers=auth(), json=older)
    assert r.json()["settings"]["reciter"] == "sudais"  # account's were newer

    newer = {"settings": {"reciter": "alafasy"}, "updated_at": "2026-09-24T11:00:00Z"}
    r = client.put("/v1/me/settings", headers=auth(), json=newer)
    assert r.json()["settings"]["reciter"] == "alafasy"


def test_users_only_see_their_own_settings(client: TestClient) -> None:
    put = {"settings": SETTINGS, "updated_at": "2026-09-24T10:00:00Z"}
    client.put("/v1/me/settings", headers=auth("a"), json=put)
    r = client.get("/v1/me/settings", headers=auth("b"))
    assert r.json()["settings"] is None


@pytest.mark.parametrize(
    "settings",
    [
        {"latitude": -33.8},
        {"prayer": {"method": "ummAlQura", "lat": 1}},
        {"location": {"city": "Sydney"}},
        {"mood": "anxious"},
        {"prayer": {"method": "made-up"}},
        {"alerts": {"prayers": {"fajr": {"before": 7}}}},
    ],
)
def test_location_mood_and_unknown_values_are_refused(
    client: TestClient, settings: dict
) -> None:
    r = client.put(
        "/v1/me/settings",
        headers=auth(),
        json={"settings": settings, "updated_at": "2026-09-24T10:00:00Z"},
    )
    assert r.status_code == 422


def test_supabase_down_is_503(client: TestClient, rest: FakeRest) -> None:
    rest.fail = True
    assert client.get("/v1/me/settings", headers=auth()).status_code == 503


# --- tasbih ---------------------------------------------------------------


def test_merge_keeps_the_higher_count_per_day() -> None:
    stored = {date(2026, 9, 22): 100, date(2026, 9, 23): 33}
    incoming = [
        TasbihDay(day=date(2026, 9, 23), count=99),
        TasbihDay(day=date(2026, 9, 22), count=50),
        TasbihDay(day=date(2026, 9, 24), count=10),
    ]
    assert merge_tasbih(stored, incoming) == {
        date(2026, 9, 23): 99,
        date(2026, 9, 24): 10,
    }


def test_tasbih_sync(client: TestClient) -> None:
    r = client.put(
        "/v1/me/tasbih",
        headers=auth(),
        json={"days": [{"day": "2026-09-23", "count": 33}]},
    )
    assert r.json() == {"days": [{"day": "2026-09-23", "count": 33}]}
    # A second phone with more for that day, and another day.
    r = client.put(
        "/v1/me/tasbih",
        headers=auth(),
        json={
            "days": [
                {"day": "2026-09-23", "count": 20},
                {"day": "2026-09-24", "count": 99},
            ]
        },
    )
    assert r.json()["days"] == [
        {"day": "2026-09-24", "count": 99},
        {"day": "2026-09-23", "count": 33},
    ]
    assert client.get("/v1/me/tasbih", headers=auth()).json() == r.json()


def test_tasbih_rejects_negative_counts(client: TestClient) -> None:
    r = client.put(
        "/v1/me/tasbih",
        headers=auth(),
        json={"days": [{"day": "2026-09-23", "count": -1}]},
    )
    assert r.status_code == 422


# --- account deletion -----------------------------------------------------


def test_delete_account(client: TestClient, rest: FakeRest) -> None:
    r = client.delete("/v1/me", headers=auth("gone"))
    assert r.status_code == 204
    assert rest.rpcs == [("delete_my_account", "gone")]


def test_delete_needs_a_signed_in_user(client: TestClient, rest: FakeRest) -> None:
    assert client.delete("/v1/me").status_code == 401
    assert rest.rpcs == []


# --- the REST client ------------------------------------------------------


async def test_rest_client_sends_the_users_token() -> None:
    seen: list[httpx.Request] = []

    def handler(request: httpx.Request) -> httpx.Response:
        seen.append(request)
        return httpx.Response(200, json=[{"settings": {}, "updated_at": None}])

    async with httpx.AsyncClient(transport=httpx.MockTransport(handler)) as http:
        rest = SupabaseRest(URL, "pk", http)
        await rest.select("user_settings", "tok", {"select": "settings"})
        await rest.upsert("tasbih_days", "tok", [{"a": 1}], on_conflict="user_id,day")
        await rest.rpc("delete_my_account", "tok")

    get, post, rpc = seen
    assert get.headers["apikey"] == "pk"
    assert get.headers["authorization"] == "Bearer tok"
    assert str(post.url) == f"{URL}/rest/v1/tasbih_days?on_conflict=user_id%2Cday"
    assert "merge-duplicates" in post.headers["prefer"]
    assert json.loads(post.content) == [{"a": 1}]
    assert str(rpc.url) == f"{URL}/rest/v1/rpc/delete_my_account"


async def test_rest_errors_become_supabase_errors() -> None:
    def handler(request: httpx.Request) -> httpx.Response:
        return httpx.Response(401, json={"message": "JWT expired"})

    async with httpx.AsyncClient(transport=httpx.MockTransport(handler)) as http:
        with pytest.raises(SupabaseError):
            await SupabaseRest(URL, "pk", http).select("t", "tok", {})
