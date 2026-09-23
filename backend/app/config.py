"""Settings from the environment (backend/.env in development)."""

import os
from dataclasses import dataclass


@dataclass(frozen=True)
class Config:
    supabase_url: str
    supabase_publishable_key: str
    revenuecat_secret_key: str

    @property
    def supabase_configured(self) -> bool:
        return bool(self.supabase_url and self.supabase_publishable_key)


def load_config() -> Config:
    return Config(
        supabase_url=os.environ.get("SUPABASE_URL", "").rstrip("/"),
        supabase_publishable_key=os.environ.get("SUPABASE_PUBLISHABLE_KEY", ""),
        revenuecat_secret_key=os.environ.get("REVENUECAT_SECRET_KEY", ""),
    )
