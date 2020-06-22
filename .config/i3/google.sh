query=$(dmenu -p Google: < .)
if [ -n "$query" ]; then
    urlquery=$(python -c "$(printf "import urllib\nprint urllib.quote(\"$query\")\nexit()")")
    surf https://google.com/search?q=$urlquery
fi
