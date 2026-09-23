"""Verifies Supabase access tokens. The backend never issues credentials.

Supabase signs tokens with an asymmetric key (ES256); the public keys come
from the project's JWKS endpoint, so no secret is needed here.
"""

from dataclasses import dataclass
from typing import Protocol

import jwt


class Unauthorized(Exception):
    pass


@dataclass(frozen=True)
class AuthUser:
    id: str
    # Passed on to Supabase so row-level security applies the same rules.
    token: str


class TokenVerifier(Protocol):
    def verify(self, token: str) -> AuthUser: ...


class SupabaseTokenVerifier:
    def __init__(self, supabase_url: str) -> None:
        self._issuer = f"{supabase_url}/auth/v1"
        self._keys = jwt.PyJWKClient(
            f"{self._issuer}/.well-known/jwks.json", cache_keys=True
        )

    def verify(self, token: str) -> AuthUser:
        try:
            key = self._keys.get_signing_key_from_jwt(token)
            claims = jwt.decode(
                token,
                key.key,
                algorithms=["ES256", "RS256"],
                audience="authenticated",
                issuer=self._issuer,
                options={"require": ["exp", "sub", "aud", "iss"]},
            )
        except jwt.PyJWTError as e:
            raise Unauthorized(type(e).__name__) from None
        if claims.get("role") != "authenticated":
            raise Unauthorized("not a signed-in user")
        return AuthUser(id=claims["sub"], token=token)
