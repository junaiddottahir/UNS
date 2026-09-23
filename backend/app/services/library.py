"""The scholar-approved verse library: references and tags only, never text.

Loaded and validated once at startup from `app/data/library.json`. A
placeholder library (until the scholar delivers) uses surah 0, which does
not exist, so it can never be mistaken for approved content.
"""

import hashlib
import json
from enum import StrEnum
from pathlib import Path
from typing import Self

from pydantic import BaseModel, ConfigDict, Field, model_validator

from app.services.quran_structure import is_valid_reference

LIBRARY_PATH = Path(__file__).resolve().parent.parent / "data" / "library.json"

PLACEHOLDER_SURAH = 0


class Category(StrEnum):
    """The fixed emotion categories from the MVP 1 scope."""

    SADNESS = "sadness"
    ANXIETY = "anxiety"
    ANGER = "anger"
    LONELINESS = "loneliness"
    GRATITUDE = "gratitude"
    HOPE = "hope"
    HUMILITY = "humility"
    ARROGANCE = "arrogance"
    GREED = "greed"


class Tag(StrEnum):
    """Powers "comfort me" (comfort) and "remind me" (the other two)."""

    COMFORT = "comfort"
    GENTLE_REMINDER = "gentle_reminder"
    WARNING = "warning"


class LibraryEntry(BaseModel):
    model_config = ConfigDict(frozen=True, extra="forbid")

    surah: int = Field(ge=0)
    ayah: int = Field(ge=1)
    category: Category
    tag: Tag


class Library(BaseModel):
    model_config = ConfigDict(frozen=True, extra="forbid")

    version: str = Field(min_length=1)
    placeholder: bool
    entries: tuple[LibraryEntry, ...]

    @model_validator(mode="after")
    def _check_references(self) -> Self:
        seen: set[tuple[int, int, Category, Tag]] = set()
        for e in self.entries:
            if self.placeholder:
                if e.surah != PLACEHOLDER_SURAH:
                    raise ValueError(
                        f"placeholder library must only use surah "
                        f"{PLACEHOLDER_SURAH}, got {e.surah}:{e.ayah}"
                    )
            elif not is_valid_reference(e.surah, e.ayah):
                raise ValueError(f"not a real verse reference: {e.surah}:{e.ayah}")
            key = (e.surah, e.ayah, e.category, e.tag)
            if key in seen:
                raise ValueError(f"duplicate entry: {e.surah}:{e.ayah} {e.category}")
            seen.add(key)
        return self

    @property
    def etag(self) -> str:
        """Changes whenever the content changes, not just the version."""
        body = self.model_dump_json().encode()
        return '"' + hashlib.sha256(body).hexdigest()[:32] + '"'


def load_library(path: Path = LIBRARY_PATH) -> Library:
    """Reads and validates the library; raises if it is invalid."""
    return Library.model_validate(json.loads(path.read_text(encoding="utf-8")))
