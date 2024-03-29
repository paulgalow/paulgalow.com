---
slug: how-to-work-with-json-api-data-in-macos-shell-scripts
title: "How to work with JSON API data in macOS shell scripts without external dependencies"
date: "2021-11-24"
---

#### Update January 2022

Thanks to @Pico on [MacAdmins Slack](https://www.macadmins.org/), I have been made aware of another potential RCE attack vector and how to mitigate it. I have updated the shell snippet below and added some background.

#### tl;dr

You might want to try out this shell snippet to retrieve a value from HTTP API JSON responses.

⚠️ To avoid potential remote code execution, we are passing our raw input value as a command-specific environment variable to JXA.

```sh
#!/bin/sh

getJsonValue() {
  # $1: JSON string to parse, $2: JSON key to look up

  # $1 is passed as a command-specific environment variable so that no special
  # characters in valid JSON need to be escaped, and no code execution is
  # possible since the contents cannot be interpreted as code when retrieved
  # within JXA.

  # $2 is placed directly in the JXA code since it should not be coming from
  # user input or an arbitrary source where it could be set to intentionally
  # malicious contents.

  JSON="$1" osascript -l 'JavaScript' \
    -e 'const env = $.NSProcessInfo.processInfo.environment.objectForKey("JSON").js' \
    -e "JSON.parse(env).$2"
}

data=$(curl -sS '<http-api-url>')
myValue=$(getJsonValue "$data" '<json-key>')
echo "$myValue"
```

---

As we are progressing into a world of Cloud-based services connected by APIs, I'm finding more and more situations where I need to work with JSON data. One use case is using data from HTTP APIs for managing macOS clients. However, working with JSON data in shell scripts is usually cumbersome without using a third-party dependency like [jq](https://stedolan.github.io/jq/).

Don't get me wrong, jq is a great tool but it is an external dependency that needs to be deployed and managed if I am going to use it in a script for a fleet of Macs. And since the pre-installed scripting languages such as Python and Ruby seem to be on their way out of the default macOS installation, I'm not inclined to rely on those tools being present moving forward.

## Our goal: A shell snippet to easily and safely retrieve JSON values

And this snippet should not rely on external dependencies. This is where Apple's JavaScript for Automation (JXA) comes into play. I recommend checking out Matthew Warren's [blog post on JSON parsing without relying on third-party dependencies](https://www.macblog.org/posts/how-to-parse-json-macos-command-line/) as well as Armin Briegel's [_The unexpected return of JavaScript for Automation_](https://scriptingosx.com/2021/11/the-unexpected-return-of-javascript-for-automation/) for more information about JXA.

At the most basic level, all we are going to do is parse JSON data and return the key's value we are interested in. Since a shell script is our main execution context, we are handing off as much control as possible to our shell environment by passing and expanding shell variables into a JavaScript expression. We can then evaluate this expression using `osascript -l 'JavaScript'`.

So a minimal implementation would look something like this:

```sh
# ⚠️ Warning: This code snippet is not safe to use!
osascript -l 'JavaScript' -e "($1.$2)"
```

Here, all we are doing is implicitly returning a key's value (defined in `$2`) of whatever variable has been passed into the JavaScript execution context by our shell runtime (`$1`). We don't even need to use the `return` keyword or JXA's special `run()` function. JavaScript is flexible! Great. But there is a catch …

## 👾 Remote code execution vulnerability

JavaScript comes with a global built-in object named _JSON_ which has a method called [`JSON.parse()`](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/JSON/parse) that is designed to parse JSON strings.

So why would we need to use that if we can pass in JSON strings directly into our JavaScript execution context? One answer to that is _security_.

In fact, by not using `JSON.parse()` we are enabling a potential backdoor for a remote code execution attack. Because without it, any JavaScript code injected will be executed, not just JSON. Let me illustrate with a simple example:

Suppose we are calling an external API to get a user's full name:

```sh
# ⚠️ Warning: This code snippet is not safe to use!

getJsonValue() {
  # $1: JSON string to process, $2: Desired JSON key
  osascript -l 'JavaScript' -e "($1.$2)"
}

data=$(curl -sS 'https://jsonplaceholder.typicode.com/users/1')
fullName=$(getJsonValue "$data" 'name')

echo "$fullName" # Returns: 'Leanne Graham'
```

### ⚔️ The attack

So far, so good. Now, let's simulate a scenario in which an attacker has managed to intercept and replace our JSON response data with some _carefully crafted_ JavaScript code:

```sh{diff}
# ⚠️ Warning: This code snippet is not safe to use!

getJsonValue() {
  # $1: JSON string to process, $2: Desired JSON key
  osascript -l 'JavaScript' -e "($1.$2)"
}

- json=$(curl -sS 'https://jsonplaceholder.typicode.com/users/1')

# String sent by a rogue HTTP endpoint
+ json='{
+  get name() {
+    const app = Application.currentApplication();
+    app.includeStandardAdditions = true;
+    app.displayAlert("👾🔥🙈");
+  }
+}'

fullName=$(getJsonValue "$json" 'name')
echo "$fullName" # Custom JavaScript code is being executed instead 👾
```

In this scenario, our attacker would have the opportunity to _execute any arbitrary JavaScript code supported by JXA_. Here, all they are doing is displaying an alert, but you can easily imagine more nefarious purposes.

I have [recorded a short video](https://www.youtube.com/watch?v=jWbexKhkEn8) for illustration purposes.

<!-- markdownlint-disable MD033 -->
<video style="width: 100%" preload="metadata" controls muted loop>
  <source src="rce-exploit-demo-1600p-x265.mp4" type="video/mp4; codecs=hvc1">
  <source src="rce-exploit-demo-1600p-x264.mp4" type="video/mp4; codecs=avc1">
  <source src="rce-exploit-demo-1080p-x264.mp4" type="video/mp4; codecs=avc1">
  <p>Your browser doesn't support HTML5 video. Here is a <a href="https://www.youtube.com/watch?v=jWbexKhkEn8">link to the video</a> instead.</p>
</video>

### 🛡️ Remediation part I: Validating our JSON input

So how can we protect against this threat? That's where `JSON.parse()` comes into play. Using it, we make sure to parse valid JSON only. If the incoming string is not JSON, this method call will throw an error. Still, this is not enough to protect us from all scenarios as I will discuss below.

Since the value of our first expanded shell variable `$1` will likely be a multiline string (which is very common when working with JSON), we need to make sure we can handle those. JavaScript provides a special syntax using backticks (_`_) to create [template literals](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Template_literals). Using those, we can expand multiline strings into our JXA execution context without it throwing an error.

But aren't backticks special characters in shell scripts? Indeed. So we need to escape them (using backslashes) to ensure our shell runtime does not evaluate them as shell expressions.

Let's try our attack again, but this time we will be using `JSON.parse()` to validate our input:

```sh{diff}
# ⚠️ Update January 2022: This code snippet is still not safe to use!

getJsonValue() {
  # $1: JSON string to process, $2: Desired JSON key
-   osascript -l 'JavaScript' -e "($1.$2)"
+   osascript -l 'JavaScript' -e "JSON.parse(\`$1\`).$2"
}

# json=$(curl -sS 'https://jsonplaceholder.typicode.com/users/1')

# String sent by a rogue API endpoint
json='{
  get name() {
    const app = Application.currentApplication();
    app.includeStandardAdditions = true;
    app.displayAlert("👾🔥🙈");
  }
}'

fullName=$(getJsonValue "$json" 'name')
echo "$fullName" # Returns a JSON Parse error
```

We have successfully thwarted the attack. Here is the error returned:

```sh
execution error: Error: SyntaxError: JSON Parse error: Expected '}' (-2700)
```

Great. But wait, there is something else lurking under the surface …

### 👹 Remediation part II: Preventing unwanted shellcode execution

It turns out there is yet another attack vector for potential remote code execution. The culprit? Our shell expansion expression `$1`. Since this is evaluated before our JXA code (including `JSON.parse()`), an attacker could hijack what's being executed inside `JSON.parse()`.

@Pico on [MacAdmins Slack](https://www.macadmins.org/) informed me about this situation and went to great lengths to explain what was going on. More importantly, he also came up with a brilliant solution. 🙏

But first, let's explore the exploit. Suppose we have received a malicious "JSON" payload like the following one:

```json
[]`);
app = Application.currentApplication();
app.includeStandardAdditions = true;
app.displayAlert("👾🔥🙈");
(`
```

Using our JSON parsing snippet, this would evaluate to:

```sh
osascript \
  -l JavaScript \
  -e '
  JSON.parse(`[]`);
  app = Application.currentApplication();
  app.includeStandardAdditions = true;
  app.displayAlert("👾🔥🙈");
  (``).name;
  '
```

Yet again, we have a situation where our attacker could have injected malicious JXA code into our execution environment. This time, _before_ it even could reach `JSON.parse()`. But how to fix this? We need to hand over our shell input string to JXA somehow.

#### Environment variables to the rescue

Environment variables are a tried and tested method to safely hand over data from one execution environment to another. And this is exactly what we are going to use here. We could export our raw JSON input, but an even simpler and more tightly scoped solution is to use a command-specific environment variable.

By prepending our `osascript` command with the desired variable assignment, we can then safely retrieve that value from within the JXA execution context using Objective-C:

```js
const env = $.NSProcessInfo.processInfo.environment.objectForKey("JSON").js
```

Here, we are using Foundation's [`NSProcessInfo`](https://developer.apple.com/documentation/foundation/nsprocessinfo) class to retrieve our environment variable. JXA automatically imports _Foundation_, so we can directly access it using the global `$` object. There is no need to wrap our environment variable string as `NSString` before passing it to `NSProcessInfo`. According to [Apple's documentation](https://developer.apple.com/library/archive/releasenotes/InterapplicationCommunication/RN-JavaScriptForAutomation/Articles/OSX10-10.html#//apple_ref/doc/uid/TP40014508-CH109-SW19):

> Primitive JavaScript data types will be automatically converted to ObjC object types when passed as an argument to an ObjC method that is expecting an object type.

Some of you JXA veterans might object:

> "Why not use [`app.systemAttribute()`](https://developer.apple.com/library/archive/documentation/AppleScript/Conceptual/AppleScriptLangGuide/reference/ASLR_cmds.html#//apple_ref/doc/uid/TP40000983-CH216-SW45)? Isn't this API designed for retrieving environment variables?"

Yes, it is. But there is a problem: Multibyte strings, more specifically UTF-8 strings, like emojis or some non-ASCII characters. Unfortunately, `app.systemAttribute()` mangles those — and I like my Germän Umlaute 🧐.

So, our final solution looks like this:

```sh{diff}
#!/bin/sh

getJsonValue() {
  # $1: JSON string to parse, $2: JSON key to look up
-   osascript -l 'JavaScript' -e "JSON.parse(\`$1\`).$2"
+   JSON="$1" osascript -l 'JavaScript' \
+     -e 'const env = $.NSProcessInfo.processInfo.environment.objectForKey("JSON").js' \
+     -e "JSON.parse(env).$2"
}

data=$(curl -sS '<http-api-url>')
myValue=$(getJsonValue "$data" '<json-key>')
echo "$myValue"
```

`$1` is passed as a command-specific environment variable so that no special characters in valid JSON need to be escaped, and no code execution is possible since the contents cannot be interpreted as code when retrieved within JXA.

`$2` is placed directly in the JXA code since it should not be coming from user input or an arbitrary source where it could be set to intentionally malicious contents.

This should make it impossible for any raw input to be interpreted as code.

## Working with real-world HTTP JSON responses

Our example earlier was using a simple JSON object to illustrate the basic principle. However, in the real world, we typically encounter JSON responses that are more nested and sometimes convoluted. Let's use [Apple's iTunes Search API](https://developer.apple.com/library/archive/documentation/AudioVideo/Conceptual/iTuneSearchAPI/index.html#//apple_ref/doc/uid/TP40017632-CH3-SW1) as an example.

Suppose we are looking for the release date of Steely Dan's excellent album [_Pretzel Logic_](https://en.wikipedia.org/wiki/Pretzel_Logic). Using Apple's API, we might use the following HTTP call:

```sh
curl 'https://itunes.apple.com/search?term=steely+dan+pretzel+logic&entity=album'
```

And the API would respond with something like this (if nicely formatted):

```json{23}
{
  "resultCount": 1,
  "results": [
    {
      "wrapperType": "collection",
      "collectionType": "Album",
      "artistId": 59606,
      "collectionId": 1440489152,
      "amgArtistId": 5525,
      "artistName": "Steely Dan",
      "collectionName": "Pretzel Logic",
      "collectionCensoredName": "Pretzel Logic",
      "artistViewUrl": "https://music.apple.com/us/artist/steely-dan/59606?uo=4",
      "collectionViewUrl": "https://music.apple.com/us/album/pretzel-logic/1440489152?uo=4",
      "artworkUrl60": "https://is3-ssl.mzstatic.com/image/thumb/Music115/v4/cf/3f/c7/cf3fc739-3b30-2502-5963-200116007cd8/source/60x60bb.jpg",
      "artworkUrl100": "https://is3-ssl.mzstatic.com/image/thumb/Music115/v4/cf/3f/c7/cf3fc739-3b30-2502-5963-200116007cd8/source/100x100bb.jpg",
      "collectionPrice": 8.99,
      "collectionExplicitness": "notExplicit",
      "trackCount": 11,
      "copyright": "℗ 1974 UMG Recordings, Inc.",
      "country": "USA",
      "currency": "USD",
      "releaseDate": "1974-01-01T08:00:00Z",
      "primaryGenreName": "Rock"
    }
  ]
}
```

As we can see, the JSON response contains a _results_ key which has an array for its value, that itself contains a single object. That object then has our _releaseDate_ key that leads us to the value we are looking for.

So how can we get the value for _releaseDate_? Let's have a look:

```sh
getJsonValue() {
  # $1: JSON string to parse, $2: JSON key to look up
  JSON="$1" osascript -l 'JavaScript' \
    -e 'const env = $.NSProcessInfo.processInfo.environment.objectForKey("JSON").js' \
    -e "JSON.parse(env).$2"
}

data=$(curl -sS 'https://itunes.apple.com/search?term=steely+dan+pretzel+logic&entity=album')

releaseDate=$(getJsonValue "$data" 'results[0].releaseDate')
echo "$releaseDate" # Returns: '1974-01-01T08:00:00Z'
```

Here, we are targeting the results key's first and only object entry by using [JavaScript's bracket notation](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Array) `[0]`. Using dot notation, we can then drill down into this object to retrieve the value for its _releaseDate_ key.

## Bonus: JSON parsing using jsc

Craig Hockenberry [recently wrote about](https://furbo.org/2021/08/25/jsc-my-new-best-friend/) a built-in WebKit command-line tool that is part of the native JavaScript framework used by Safari and other WebKit consumers. Let's see if we can use this tool for our purposes as well. Here's our shell function implemented using _jsc_.

```sh
# ⚠️ Warning: This code snippet is not safe to use!

getJsonValue() {
  # $1: JSON string to process, $2: Desired JSON key
  # Will return 'undefined' if key cannot be found
  /System/Library/Frameworks/JavaScriptCore.framework/Versions/Current/Helpers/jsc \
  -e "print(JSON.parse(\`$1\`).$2)"
}

data=$(curl -sS 'https://itunes.apple.com/search?term=steely+dan+pretzel+logic&entity=album')

releaseDate=$(getJsonValue "$data" 'results[0].releaseDate')
echo "$releaseDate" # Returns: '1974-01-01T08:00:00Z'
```

It turns out we can! Be aware that _jsc_ will return `undefined` if a key cannot be found.

⚠️ Unfortunately, this solution suffers from the same shell expansion issue mentioned earlier. And I do not know of any way to retrieve environment values from within a _jsc_ environment. Another approach would be to Base64 encode our raw input string in our shell environment and decode it in _jsc_ land. Unfortunately I'm not aware of any easy built-in way to decode Base64 encoded strings since Web APIs like [`atob()`](https://developer.mozilla.org/en-US/docs/Web/API/atob) are apparently not implemented by _jsc_.

One benefit of using _jsc_ might be its limited attack surface: we are not running in a JXA environment with all its powerful scripting capabilities, but rather in a browser sandbox which is much more restrictive and isolated.

Also, I would hesitate to rely on this tool in production scripts since we are using a command-line tool somewhat hidden inside an Apple System Framework. Knowing Apple, APIs like that might change unexpectedly. So keep that in mind!

Have I missed anything? If so, please let me know!
