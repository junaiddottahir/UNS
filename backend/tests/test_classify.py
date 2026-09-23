import json
import logging
from types import SimpleNamespace

import anthropic
import httpx2
import pytest
from fastapi.testclient import TestClient

from app.main import app
from app.services.classifier import (
    MODEL,
    Classification,
    ClassifierUnavailable,
    ClaudeClassifier,
    parse_classification,
)
from app.services.rate_limit import RateLimiter

PRIVATE = "work has been overwhelming and I can't switch off at night"


def _text(payload: object) -> list:
    return [SimpleNamespace(type="text", text=json.dumps(payload))]


class FakeMessages:
    def __init__(self, response=None, error: Exception | None = None) -> None:
        self.response = response
        self.error = error
        self.calls: list[dict] = []

    async def create(self, **kwargs):
        self.calls.append(kwargs)
        if self.error:
            raise self.error
        return self.response


def _client(messages: FakeMessages) -> SimpleNamespace:
    return SimpleNamespace(messages=messages)


class FakeClassifier:
    def __init__(self, result=None, error: Exception | None = None) -> None:
        self.result = result or Classification(category="anxiety", risk=False)
        self.error = error
        self.texts: list[str] = []

    async def classify(self, text: str) -> Classification:
        self.texts.append(text)
        if self.error:
            raise self.error
        return self.result


@pytest.fixture
def client():
    with TestClient(app) as c:
        app.state.classifier = FakeClassifier()
        app.state.classify_limiter = RateLimiter(limit=20, window_seconds=60)
        yield c


# --- parsing the model's answer -------------------------------------------


def test_parse_valid() -> None:
    got = parse_classification(_text({"category": "anxiety", "risk": False}))
    assert got == Classification(category="anxiety", risk=False)


def test_unexpected_category_becomes_unknown_but_keeps_risk() -> None:
    got = parse_classification(_text({"category": "despair", "risk": True}))
    assert got == Classification(category="unknown", risk=True)


@pytest.mark.parametrize("raw", ["not json", "[1, 2]", ""])
def test_garbage_becomes_unknown(raw: str) -> None:
    got = parse_classification([SimpleNamespace(type="text", text=raw)])
    assert got == Classification(category="unknown", risk=False)


# --- the Claude call ------------------------------------------------------


async def test_sends_only_the_text_with_the_fixed_schema() -> None:
    messages = FakeMessages(
        SimpleNamespace(
            stop_reason="end_turn",
            content=_text({"category": "loneliness", "risk": False}),
        )
    )
    got = await ClaudeClassifier(_client(messages)).classify(PRIVATE)
    assert got.category == "loneliness"

    [call] = messages.calls
    assert call["model"] == MODEL == "claude-sonnet-5"
    assert call["messages"] == [{"role": "user", "content": PRIVATE}]
    assert "metadata" not in call  # no user identifiers
    assert "temperature" not in call  # Sonnet 5 rejects sampling params
    schema = call["output_config"]["format"]["schema"]
    assert set(schema["properties"]["category"]["enum"]) == {
        "sadness", "anxiety", "anger", "loneliness", "gratitude",
        "hope", "humility", "arrogance", "greed", "unknown",
    }  # fmt: skip
    assert call["output_config"]["effort"] == "low"


async def test_a_refusal_is_unknown_not_an_error() -> None:
    messages = FakeMessages(SimpleNamespace(stop_reason="refusal", content=[]))
    got = await ClaudeClassifier(_client(messages)).classify("hello")
    assert got == Classification(category="unknown", risk=False)


async def test_api_failure_is_unavailable_without_the_text() -> None:
    error = anthropic.APIConnectionError(
        request=httpx2.Request("POST", "https://api.anthropic.com/v1/messages")
    )
    messages = FakeMessages(error=error)
    with pytest.raises(ClassifierUnavailable) as caught:
        await ClaudeClassifier(_client(messages)).classify(PRIVATE)
    assert PRIVATE not in str(caught.value)


# --- the route ------------------------------------------------------------


def test_classify(client: TestClient) -> None:
    r = client.post("/v1/classify", json={"text": f"  {PRIVATE}  "})
    assert r.status_code == 200
    assert r.json() == {"category": "anxiety", "risk": False}
    assert app.state.classifier.texts == [PRIVATE]


@pytest.mark.parametrize(
    "body",
    [{"text": "   "}, {"text": ""}, {"text": "x" * 1001}, {}, {"text": 5}],
)
def test_bad_input_is_rejected_without_echoing_it(
    client: TestClient, body: dict
) -> None:
    r = client.post("/v1/classify", json=body)
    assert r.status_code == 422
    assert r.json()["error"]["code"] == "invalid_request"
    assert "xxxx" not in r.text


def test_extra_fields_like_user_ids_are_not_used(client: TestClient) -> None:
    r = client.post("/v1/classify", json={"text": "sad", "user_id": "u1"})
    assert r.status_code == 200
    assert app.state.classifier.texts == ["sad"]


def test_rate_limited(client: TestClient) -> None:
    app.state.classify_limiter = RateLimiter(limit=2, window_seconds=60)
    codes = [
        client.post("/v1/classify", json={"text": "sad"}).status_code for _ in range(3)
    ]
    assert codes == [200, 200, 429]
    assert (
        client.post("/v1/classify", json={"text": "sad"}).json()["error"]["code"]
        == "rate_limited"
    )


def test_unavailable(client: TestClient) -> None:
    app.state.classifier = FakeClassifier(error=ClassifierUnavailable("x"))
    r = client.post("/v1/classify", json={"text": "sad"})
    assert r.status_code == 503
    assert r.json()["error"]["code"] == "unavailable"
    app.state.classifier = None
    assert client.post("/v1/classify", json={"text": "sad"}).status_code == 503


def test_text_is_never_logged(
    client: TestClient, caplog: pytest.LogCaptureFixture
) -> None:
    caplog.set_level(logging.DEBUG)
    client.post("/v1/classify", json={"text": PRIVATE})
    app.state.classifier = FakeClassifier(error=ClassifierUnavailable("x"))
    client.post("/v1/classify", json={"text": PRIVATE})
    assert PRIVATE not in caplog.text


def test_rate_limiter_window() -> None:
    now = [0.0]
    limiter = RateLimiter(limit=2, window_seconds=60, clock=lambda: now[0])
    assert limiter.allow("a") and limiter.allow("a")
    assert not limiter.allow("a")
    assert limiter.allow("b")
    now[0] = 60.0
    assert limiter.allow("a")


def test_no_credentials_means_503_not_a_crash(
    monkeypatch: pytest.MonkeyPatch,
) -> None:
    monkeypatch.delenv("ANTHROPIC_API_KEY", raising=False)
    monkeypatch.delenv("ANTHROPIC_AUTH_TOKEN", raising=False)
    with TestClient(app) as c:
        r = c.post("/v1/classify", json={"text": "sad"})
    assert r.status_code == 503
    assert r.json()["error"]["code"] == "unavailable"
