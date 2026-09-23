"""Supabase's REST API (PostgREST), called with the user's own token so the
database's row-level security decides what they can read and write."""

from typing import Any

import httpx


class SupabaseError(Exception):
    """Supabase couldn't be reached or refused the request."""


class SupabaseRest:
    def __init__(self, url: str, publishable_key: str, http: httpx.AsyncClient):
        self._url = f"{url}/rest/v1"
        self._key = publishable_key
        self._http = http

    def _headers(self, token: str, **extra: str) -> dict[str, str]:
        return {
            "apikey": self._key,
            "authorization": f"Bearer {token}",
            **extra,
        }

    async def _send(self, method: str, path: str, token: str, **kw: Any):
        headers = self._headers(token, **kw.pop("headers", {}))
        try:
            r = await self._http.request(
                method, f"{self._url}/{path}", headers=headers, timeout=10, **kw
            )
        except httpx.HTTPError as e:
            raise SupabaseError(type(e).__name__) from None
        if r.status_code >= 400:
            raise SupabaseError(f"{r.status_code}")
        return r

    async def select(
        self, table: str, token: str, params: dict[str, str]
    ) -> list[dict[str, Any]]:
        r = await self._send("GET", table, token, params=params)
        return r.json()

    async def upsert(
        self, table: str, token: str, rows: list[dict[str, Any]], on_conflict: str
    ) -> None:
        await self._send(
            "POST",
            table,
            token,
            params={"on_conflict": on_conflict},
            json=rows,
            headers={"prefer": "resolution=merge-duplicates,return=minimal"},
        )

    async def rpc(self, function: str, token: str) -> None:
        await self._send("POST", f"rpc/{function}", token, json={})
