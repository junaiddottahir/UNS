from collections.abc import AsyncIterator
from contextlib import asynccontextmanager

from fastapi import FastAPI

from app.errors import install_error_handlers
from app.routers import health, library
from app.services.library import load_library


@asynccontextmanager
async def lifespan(app: FastAPI) -> AsyncIterator[None]:
    # Fails fast: the server won't start with an invalid library.
    app.state.library = load_library()
    yield


app = FastAPI(title="Uns API", version="0.1.0", lifespan=lifespan)
install_error_handlers(app)
app.include_router(health.router, prefix="/v1")
app.include_router(library.router, prefix="/v1")
