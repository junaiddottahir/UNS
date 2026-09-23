from typing import Annotated

from fastapi import APIRouter, Depends, Header, Request, Response

from app.services.library import Library

router = APIRouter(tags=["library"])


def get_library(request: Request) -> Library:
    return request.app.state.library


@router.get(
    "/library",
    response_model=Library,
    responses={304: {"description": "Not modified since the given ETag"}},
)
def library(
    response: Response,
    lib: Annotated[Library, Depends(get_library)],
    if_none_match: Annotated[str | None, Header()] = None,
) -> Library | Response:
    """The approved verse library (references and tags only). Public and
    carries no identifiers; the app caches it and revalidates by ETag."""
    headers = {"ETag": lib.etag, "Cache-Control": "public, max-age=3600"}
    if if_none_match == lib.etag:
        return Response(status_code=304, headers=headers)
    response.headers.update(headers)
    return lib
