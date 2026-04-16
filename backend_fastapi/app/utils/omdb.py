import json
import os
import urllib.parse
import urllib.request
from typing import Optional


def _omdb_key() -> Optional[str]:
    key = os.getenv("OMDB_API_KEY")
    if key:
        key = key.strip()
    return key or None


def fetch_poster_url_by_title(title: str, year: Optional[int] = None) -> Optional[str]:
    """
    Fetch poster URL from OMDb by title.
    Returns None if no key, not found, or poster unavailable.
    """
    key = _omdb_key()
    if not key:
        return None

    params = {"t": title, "apikey": key}
    if year:
        params["y"] = str(year)

    url = "http://www.omdbapi.com/?" + urllib.parse.urlencode(params)
    try:
        with urllib.request.urlopen(url, timeout=6) as resp:
            data = json.loads(resp.read().decode("utf-8"))
    except Exception:
        return None

    if not isinstance(data, dict) or data.get("Response") != "True":
        return None

    poster = data.get("Poster")
    if not poster or poster == "N/A":
        return None

    return str(poster)

