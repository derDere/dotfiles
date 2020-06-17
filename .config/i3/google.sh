query=$(dmenu -p Google: < .)
if [ -n "$query" ]; then
    urlquery=$(python -c "$(printf "import urllib\nprint urllib.quote(\"$query\")\nexit()")")
    surf google.de/search?q=$urlquery
fi
