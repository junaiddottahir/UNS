"""Builds app/assets/data/surahs.json from the fawazahmed0 Quran API.

Usage (from the repo root):
    python3 tools/quran/build_surahs.py

Keeps each surah's names and verse count exactly as the API's info.json
gives them, so the Quran tab lists surahs offline. Never edit by hand.
"""

import json
import urllib.request
from pathlib import Path

URL = "https://cdn.jsdelivr.net/gh/fawazahmed0/quran-api@1/info.min.json"
OUT = Path(__file__).resolve().parents[2] / "app/assets/data/surahs.json"


def main() -> None:
    with urllib.request.urlopen(URL) as r:
        chapters = json.load(r)["chapters"]
    if [c["chapter"] for c in chapters] != list(range(1, 115)):
        raise SystemExit("unexpected chapter list")
    surahs = [
        {
            "number": c["chapter"],
            "name": c["name"],
            "englishName": c["englishname"],
            "arabicName": c["arabicname"],
            "revelation": c["revelation"],
            "ayahs": len(c["verses"]),
        }
        for c in chapters
    ]
    if sum(s["ayahs"] for s in surahs) != 6236:
        raise SystemExit("verse counts don't total 6,236")
    OUT.write_text(json.dumps(surahs, ensure_ascii=False, indent=1) + "\n")
    print(f"wrote {len(surahs)} surahs to {OUT}")


if __name__ == "__main__":
    main()
