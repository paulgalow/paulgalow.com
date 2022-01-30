#!/bin/sh

getJsonValue() {
  # $1: JSON string to parse, $2: JSON key to look up
  JSON="$1" osascript -l 'JavaScript' \
    -e 'const app = Application.currentApplication()' \
    -e 'app.includeStandardAdditions = true' \
    -e "JSON.parse(app.doShellScript('printenv JSON', {alteringLineEndings: false})).$2"
}

data=$(curl -sS 'https://itunes.apple.com/search?term=steely+dan+pretzel+logic&entity=album')
releaseDate=$(getJsonValue "$data" "results[0].releaseDate")
echo "$releaseDate" # Returns: '1974-01-01T08:00:00Z'