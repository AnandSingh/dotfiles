#!/usr/bin/env bash
# Print one random quote for the eww HUD. Offline (local file), no flaky quote API.
d="$(dirname "$(readlink -f "$0")")"
shuf -n1 "$d/../quotes.txt" 2>/dev/null || echo "Stay curious."
