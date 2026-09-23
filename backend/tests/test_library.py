import json
from pathlib import Path

import pytest
from fastapi.testclient import TestClient
from pydantic import ValidationError

from app.main import app
from app.services.library import Library, load_library
from app.services.quran_structure import AYAH_COUNTS, is_valid_reference


@pytest.fixture
def client():
    with TestClient(app) as c:  # runs startup, which loads the library
        yield c


def _library(placeholder: bool, *refs: tuple[int, int], **extra) -> dict:
    return {
        "version": "t1",
        "placeholder": placeholder,
        "entries": [
            {"surah": s, "ayah": a, "category": "hope", "tag": "comfort", **extra}
            for s, a in refs
        ],
    }


def test_quran_structure() -> None:
    assert len(AYAH_COUNTS) == 114
    assert sum(AYAH_COUNTS) == 6236
    assert is_valid_reference(1, 7)
    assert is_valid_reference(114, 6)
    assert not is_valid_reference(1, 8)
    assert not is_valid_reference(115, 1)
    assert not is_valid_reference(0, 1)


def test_get_library_serves_the_placeholder(client: TestClient) -> None:
    r = client.get("/v1/library")
    assert r.status_code == 200
    body = r.json()
    assert body["placeholder"] is True
    assert body["version"] == "placeholder-1"
    # One entry per category and tag, all on the non-existent surah 0.
    assert len(body["entries"]) == 27
    assert {e["surah"] for e in body["entries"]} == {0}
    assert {e["category"] for e in body["entries"]} == {
        "sadness", "anxiety", "anger", "loneliness", "gratitude",
        "hope", "humility", "arrogance", "greed",
    }  # fmt: skip
    # References and tags only: no text of any kind.
    assert all(set(e) == {"surah", "ayah", "category", "tag"} for e in body["entries"])
    assert r.headers["etag"]
    assert "max-age" in r.headers["cache-control"]


def test_etag_revalidation(client: TestClient) -> None:
    etag = client.get("/v1/library").headers["etag"]
    r = client.get("/v1/library", headers={"If-None-Match": etag})
    assert r.status_code == 304
    assert r.content == b""
    assert r.headers["etag"] == etag
    stale = client.get("/v1/library", headers={"If-None-Match": '"old"'})
    assert stale.status_code == 200


def test_etag_follows_content() -> None:
    a = Library.model_validate(_library(False, (1, 1)))
    b = Library.model_validate(_library(False, (1, 2)))
    assert a.etag != b.etag
    assert a.etag == Library.model_validate(_library(False, (1, 1))).etag


def test_real_library_accepts_real_references() -> None:
    lib = Library.model_validate(_library(False, (1, 7), (114, 6)))
    assert len(lib.entries) == 2


@pytest.mark.parametrize(
    ("data", "problem"),
    [
        (_library(False, (1, 8)), "not a real verse"),
        (_library(False, (0, 1)), "not a real verse"),
        (_library(True, (2, 255)), "placeholder library must only use surah 0"),
        (_library(False, (1, 1), (1, 1)), "duplicate"),
        (_library(False, (1, 1), text="..."), "Extra inputs"),
    ],
)
def test_invalid_libraries_are_rejected(data: dict, problem: str) -> None:
    with pytest.raises(ValidationError, match=problem):
        Library.model_validate(data)


def test_unknown_category_or_tag_is_rejected() -> None:
    bad = _library(False, (1, 1))
    bad["entries"][0]["category"] = "boredom"
    with pytest.raises(ValidationError):
        Library.model_validate(bad)
    bad = _library(False, (1, 1))
    bad["entries"][0]["tag"] = "joke"
    with pytest.raises(ValidationError):
        Library.model_validate(bad)


def test_invalid_file_stops_loading(tmp_path: Path) -> None:
    path = tmp_path / "library.json"
    path.write_text(json.dumps(_library(False, (200, 1))))
    with pytest.raises(ValidationError):
        load_library(path)


def test_errors_use_the_standard_shape(client: TestClient) -> None:
    r = client.get("/v1/nope")
    assert r.status_code == 404
    assert r.json() == {"error": {"code": "not_found", "message": "Not Found"}}
