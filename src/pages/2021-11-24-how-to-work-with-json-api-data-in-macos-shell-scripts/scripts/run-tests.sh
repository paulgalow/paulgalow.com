#!/bin/bash
##!/bin/sh

# getJsonValue() {
#   # $1: JSON string to parse, $2: JSON key to look up
#   #osascript -l 'JavaScript' -e "($1.$2);"
#   #osascript -l 'JavaScript' -e "JSON.parse($1.$2);"
#   #osascript -l 'JavaScript' -e "JSON.parse(\`$1\`).$2;"
#   #osascript -l 'JavaScript' -e "JSON.parse(\`$(awk -v awk_var="$1" '{ print awk_var }')\`).$2;"
#   #osascript -l 'JavaScript' -e "JSON.parse(\`$(printf "%s" "$1" | awk '{ print $0 }')\`).$2;"
#   #export JSON_ENV=$(printf "%s" "$1") && osascript -l 'JavaScript' -e "JSON.parse(\`$(awk 'BEGIN{print ENVIRON["JSON_ENV"]}')\`).$2;"
#   #osascript -l 'JavaScript' -e "JSON.parse(\`$(JSON_ENV=$(printf "%s" "$1") awk 'BEGIN{print ENVIRON["JSON_ENV"]}')\`).$2;"
#   #osascript -l 'JavaScript' -e "JSON.parse(\`$(echo -n "$1")\`).$2;"
#   #osascript -l 'JavaScript' -e "console.log(JSON.parse(\`$1\`).$2);"
#   #osascript -l 'JavaScript' -e "JSON.parse(\`$(printf "%s" "$1")\`).$2;"
#   #osascript -l 'JavaScript' -e "JSON.parse($.NSString.alloc.initWithDataEncoding($.NSData.alloc.initWithBase64EncodedStringOptions(ObjC.wrap('$(echo -n "$1" | base64)'), 0), $.NSUTF8StringEncoding).js).$2;"
#   #ENV_JSON="${1}" osascript -l 'JavaScript' -e 'let app = Application.currentApplication(); app.includeStandardAdditions = true; JSON.parse(app.systemAttribute("ENV_JSON"))'.$2;
#   #/System/Library/Frameworks/JavaScriptCore.framework/Versions/Current/Helpers/jsc -e "print(JSON.parse(\`$1\`).$2);"
#   #osascript -l 'JavaScript' -e "JSON.parse($.NSString.alloc.initWithDataEncoding($.NSData.alloc.initWithBase64EncodedStringOptions(ObjC.wrap('$(printf "%s" "$1" | base64)'), 0), $.NSUTF8StringEncoding).js).$2;"

#   # jsonB64="$(printf "%s" "$1" | base64)"
#   # json=$(osascript -l 'JavaScript' -e "$.NSString.alloc.initWithDataEncoding($.NSData.alloc.initWithBase64EncodedStringOptions(ObjC.wrap('$jsonB64'), 0), $.NSUTF8StringEncoding).js")
#   # osascript -l 'JavaScript' -e "JSON.parse(\`$json\`).$2;"

#   jsonB64="$(printf '%s' "$1" | base64)"
#   osascript -l 'JavaScript' -e "JSON.parse($.NSString.alloc.initWithDataEncoding($.NSData.alloc.initWithBase64EncodedStringOptions(ObjC.wrap('$jsonB64'), 0), $.NSUTF8StringEncoding).js).$2;"
# }

# getJsonValue() {
# 	# $1: JSON string to parse, $2: JSON key to look up

# 	OSASCRIPT_ENV_JSON="$1" osascript -l 'JavaScript' << OSASCRIPT_JXA_EOF
# const app = Application.currentApplication()
# app.includeStandardAdditions = true
# JSON.parse(app.doShellScript('printenv OSASCRIPT_ENV_JSON', {alteringLineEndings: false})).$2
# OSASCRIPT_JXA_EOF
# }

# getJsonValue() {
#   # $1: JSON string to parse, $2: JSON key to look up
#   JSON="$1" osascript -l 'JavaScript' \
#     -e "const app = Application.currentApplication();" \
#     -e "app.includeStandardAdditions = true;" \
#     -e "JSON.parse(app.doShellScript('printenv JSON', {alteringLineEndings: false})).$2"
# }

# getJsonValue() {
#   # $1: JSON string to parse, $2: JSON key to look up
#   JSON="$1" osascript -l 'JavaScript' \
#     -e "JSON.parse($.NSProcessInfo.processInfo.environment.objectForKey('JSON').js).$2"
# }

# getJsonValue() {
#   # $1: JSON string to parse, $2: JSON key to look up
#   JSON="$1" osascript -l 'JavaScript' \
#     -e 'const env = $.NSProcessInfo.processInfo.environment.objectForKey("JSON").js' \
#     -e "JSON.parse(env).$2"
# }

# getJsonValue() {
#   osascript -l 'JavaScript' - "$1" "$2" << 'EOF'
#     function run(argv) {
#       return JSON.parse(argv[0])[argv[1]] }
# EOF
# }

getJsonValue() {
  osascript -l 'JavaScript' -e 'run = argv => JSON.parse(argv[0])[argv[1]]' "$1" "$2"
}

runTests() {
  for test in tests/*.json; do
    getJsonValue "$(cat "$test")" 'value'
  done
}

runTests