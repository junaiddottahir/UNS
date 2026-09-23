import os
from collections.abc import AsyncIterator
from contextlib import asynccontextmanager

import httpx
from fastapi import FastAPI

from app.config import load_config
from app.errors import install_error_handlers
from app.routers import classify, health, library, me
from app.services.auth import SupabaseTokenVerifier
from app.services.classifier import ClaudeClassifier
from app.services.library import load_library
from app.services.rate_limit import RateLimiter
from app.services.supabase_rest import SupabaseRest


@asynccontextmanager
async def lifespan(app: FastAPI) -> AsyncIterator[None]:
    # Fails fast: the server won't start with an invalid library.
    app.state.library = load_library()
    app.state.classify_limiter = RateLimiter(limit=20, window_seconds=60)
    # Without credentials the SDK only fails at request time, so check
    # here: /v1/classify then answers 503 and the app falls back to chips.
    configured = any(
        os.environ.get(k) for k in ("ANTHROPIC_API_KEY", "ANTHROPIC_AUTH_TOKEN")
    )
    app.state.classifier = ClaudeClassifier() if configured else None

    config = load_config()
    app.state.config = config
    async with httpx.AsyncClient() as http:
        app.state.http = http
        if config.supabase_configured:
            app.state.token_verifier = SupabaseTokenVerifier(config.supabase_url)
            app.state.supabase = SupabaseRest(
                config.supabase_url, config.supabase_publishable_key, http
            )
        else:
            # Accounts are optional: sync endpoints answer 503.
            app.state.token_verifier = None
            app.state.supabase = None
        yield


app = FastAPI(title="Uns API", version="0.1.0", lifespan=lifespan)
install_error_handlers(app)
app.include_router(health.router, prefix="/v1")
app.include_router(library.router, prefix="/v1")
app.include_router(classify.router, prefix="/v1")
app.include_router(me.router, prefix="/v1")
