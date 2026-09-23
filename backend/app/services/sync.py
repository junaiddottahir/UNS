"""What signed-in users sync: prayer settings, alert choices, reciter,
language and tasbih history. Never location, mood, journal or voice
(invariant 5): unknown fields are rejected, not stored."""

from datetime import date, datetime
from typing import Literal

from pydantic import BaseModel, ConfigDict, Field

PrayerMethod = Literal[
    "muslimWorldLeague",
    "ummAlQura",
    "isna",
    "egyptian",
    "karachi",
    "dubai",
    "qatar",
    "kuwait",
    "moonsightingCommittee",
    "singapore",
    "turkey",
    "tehran",
]
AlertMode = Literal["off", "silent", "notification", "adhan"]
PrayerName = Literal["fajr", "dhuhr", "asr", "maghrib", "isha"]


class _Strict(BaseModel):
    model_config = ConfigDict(extra="forbid", frozen=True)


class PrayerSettings(_Strict):
    # Null: use the method suggested for the user's country.
    method: PrayerMethod | None = None
    asr: Literal["standard", "hanafi"] = "standard"
    highLatitude: Literal["middleOfNight", "seventhOfNight", "twilightAngle"] = (
        "middleOfNight"
    )


class PrayerAlert(_Strict):
    mode: AlertMode = "off"
    before: Literal[0, 10, 15, 30] = 0
    checkIn: bool = False


class AlertSettings(_Strict):
    sound: Literal["silent", "notification", "adhan"] = "adhan"
    prayers: dict[PrayerName, PrayerAlert] = Field(default_factory=dict)


class SyncedSettings(_Strict):
    prayer: PrayerSettings | None = None
    alerts: AlertSettings | None = None
    reciter: Literal["alafasy", "abdulBasit", "sudais"] | None = None
    language: Literal["en", "ar"] | None = None


class SettingsPut(_Strict):
    settings: SyncedSettings
    # When the user last changed them on their phone; newest wins.
    updated_at: datetime


class SettingsOut(BaseModel):
    settings: SyncedSettings | None
    updated_at: datetime | None


class TasbihDay(_Strict):
    day: date
    count: int = Field(ge=0, le=1_000_000)


class TasbihPut(_Strict):
    days: list[TasbihDay] = Field(max_length=400)


class TasbihOut(BaseModel):
    days: list[TasbihDay]


def merge_tasbih(stored: dict[date, int], incoming: list[TasbihDay]) -> dict[date, int]:
    """Per day, the higher count wins: a total only ever grows on the phone
    that counted it, so this never loses counts from one phone. (Counting on
    two phones the same day keeps the larger, not the sum.)"""
    merged: dict[date, int] = {}
    for d in incoming:
        best = max(d.count, stored.get(d.day, 0), merged.get(d.day, 0))
        if best != stored.get(d.day):
            merged[d.day] = best
    return merged
