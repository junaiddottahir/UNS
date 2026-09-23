"""Errors as `{"error": {"code", "message"}}` (code-standards.md)."""

from fastapi import FastAPI, Request
from fastapi.exceptions import RequestValidationError
from fastapi.responses import JSONResponse
from starlette.exceptions import HTTPException

_CODES = {
    400: "bad_request",
    401: "unauthorized",
    404: "not_found",
    405: "method_not_allowed",
    429: "rate_limited",
    503: "unavailable",
}


def _error(status: int, code: str, message: str) -> JSONResponse:
    return JSONResponse(
        status_code=status, content={"error": {"code": code, "message": message}}
    )


def install_error_handlers(app: FastAPI) -> None:
    @app.exception_handler(HTTPException)
    async def http_error(_: Request, exc: HTTPException) -> JSONResponse:
        code = _CODES.get(exc.status_code, "error")
        return _error(exc.status_code, code, str(exc.detail))

    @app.exception_handler(RequestValidationError)
    async def validation_error(_: Request, exc: RequestValidationError) -> JSONResponse:
        # Only where and why - never the submitted value, which could be a
        # user's private words.
        first = exc.errors()[0] if exc.errors() else {}
        where = ".".join(str(p) for p in first.get("loc", ()))
        return _error(422, "invalid_request", f"{where}: {first.get('msg', '')}")
