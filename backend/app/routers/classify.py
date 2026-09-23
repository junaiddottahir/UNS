from typing import Annotated

from fastapi import APIRouter, Depends, HTTPException, Request
from pydantic import BaseModel, Field, field_validator

from app.services.classifier import (
    MAX_TEXT_CHARS,
    Classification,
    Classifier,
    ClassifierUnavailable,
)
from app.services.rate_limit import RateLimiter

router = APIRouter(tags=["classify"])


class ClassifyRequest(BaseModel):
    """Only the text: no user ID, token or device details."""

    text: str = Field(min_length=1, max_length=MAX_TEXT_CHARS)

    @field_validator("text")
    @classmethod
    def _not_blank(cls, v: str) -> str:
        if not v.strip():
            raise ValueError("text is blank")
        return v.strip()


def get_classifier(request: Request) -> Classifier:
    classifier = request.app.state.classifier
    if classifier is None:
        raise HTTPException(503, "Mood classification isn't available right now.")
    return classifier


def get_limiter(request: Request) -> RateLimiter:
    return request.app.state.classify_limiter


@router.post("/classify", response_model=Classification)
async def classify(
    body: ClassifyRequest,
    request: Request,
    classifier: Annotated[Classifier, Depends(get_classifier)],
    limiter: Annotated[RateLimiter, Depends(get_limiter)],
) -> Classification:
    """Free text → one of the fixed emotion categories (or "unknown") and a
    risk flag. The text is not logged or stored."""
    client = request.client.host if request.client else "unknown"
    if not limiter.allow(client):
        raise HTTPException(429, "Too many requests. Try again in a minute.")
    try:
        return await classifier.classify(body.text)
    except ClassifierUnavailable:
        raise HTTPException(
            503, "Mood classification isn't available right now."
        ) from None
