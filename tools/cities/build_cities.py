"""Builds app/assets/data/cities.json from GeoNames.

Usage (from the repo root):
    python3 tools/cities/build_cities.py

Downloads cities15000, admin1 codes and country info from GeoNames
(CC BY 4.0, https://www.geonames.org) into a temp folder.
"""

import io
import json
import re
import tempfile
import urllib.request
import zipfile
from pathlib import Path

BASE = "https://download.geonames.org/export/dump/"
OUT = Path(__file__).resolve().parents[2] / "app/assets/data/cities.json"

# Neighbourhoods, historical, abandoned and destroyed places.
SKIP_FEATURES = {"PPLX", "PPLH", "PPLQ", "PPLW"}
# Cities this large get English and Arabic alternate names for search.
ALT_MIN_POPULATION = 200_000


def fetch(name: str, tmp: Path) -> Path:
    path = tmp / name
    with urllib.request.urlopen(BASE + name) as r:
        path.write_bytes(r.read())
    return path


def main() -> None:
    with tempfile.TemporaryDirectory() as t:
        tmp = Path(t)
        with zipfile.ZipFile(fetch("cities15000.zip", tmp)) as z:
            cities_txt = z.read("cities15000.txt").decode("utf-8")
        admin1_txt = fetch("admin1CodesASCII.txt", tmp).read_text("utf-8")
        country_txt = fetch("countryInfo.txt", tmp).read_text("utf-8")

    admin1 = {}
    for line in admin1_txt.splitlines():
        parts = line.split("\t")
        admin1[parts[0]] = parts[1]

    countries = {}
    for line in country_txt.splitlines():
        if line.startswith("#") or not line.strip():
            continue
        parts = line.split("\t")
        countries[parts[0]] = parts[4]

    rows = []
    for line in io.StringIO(cities_txt):
        p = line.rstrip("\n").split("\t")
        if p[7] in SKIP_FEATURES:
            continue
        name, ascii_name, cc, pop = p[1], p[2], p[8], int(p[14])
        alts = []
        if pop >= ALT_MIN_POPULATION:
            names = [a for a in p[3].split(",") if a]
            latin = [
                a
                for a in names
                if re.fullmatch(r"[A-Za-z][A-Za-z .'-]{2,30}", a)
                and a.lower() != name.lower()
            ]
            arabic = [a for a in names if re.fullmatch(r"[؀-ۿ ]{2,30}", a)]
            alts = latin[:6] + arabic[:2]
        rows.append(
            [
                name,
                ascii_name if ascii_name != name else "",
                admin1.get(f"{cc}.{p[10]}", ""),
                cc,
                round(float(p[4]), 4),
                round(float(p[5]), 4),
                p[17],
                pop,
                "|".join(alts),
            ]
        )

    rows.sort(key=lambda r: -r[7])
    used = sorted({r[3] for r in rows})
    data = {
        "source": "GeoNames cities15000 (CC BY 4.0), https://www.geonames.org",
        "countries": {c: countries[c] for c in used if c in countries},
        "fields": ["name", "ascii", "region", "cc", "lat", "lng", "tz", "pop", "alt"],
        "cities": rows,
    }
    OUT.write_text(
        json.dumps(data, ensure_ascii=False, separators=(",", ":")), "utf-8"
    )
    print(f"Wrote {len(rows)} cities to {OUT} ({OUT.stat().st_size // 1024} KB)")


if __name__ == "__main__":
    main()
