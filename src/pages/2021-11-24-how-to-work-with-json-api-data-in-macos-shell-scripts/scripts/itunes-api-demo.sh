#!/bin/sh

getJsonValue() {
  # $1: JSON string to parse, $2: JSON key to look up
  JSON="$1" osascript -l 'JavaScript' \
    -e 'const env = $.NSProcessInfo.processInfo.environment.objectForKey("JSON").js' \
    -e "JSON.parse(env).$2"
}

data=$(curl -sS 'https://itunes.apple.com/search?term=steely+dan+pretzel+logic&entity=album')
releaseDate=$(getJsonValue "$data" 'results[0].releaseDate')
echo "$releaseDate" # Returns: '1974-01-01T08:00:00Z'