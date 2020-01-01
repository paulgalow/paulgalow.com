---
slug: how-to-check-for-internet-connectivity-node
title: "How to check for internet connectivity with vanilla Node.js"
date: "2019-12-31"
---

How often do you think about internet connectivity of your server-side applications? Most of the time I don't. I assume "the cloud" is just always online (I shouldn't). Recently I have been working on a CLI tool written in Node.js that will be used under unpredictable network conditions including intermittent connectivity. So the question came up: How to check if we are online?

## What does it mean to be "online"

A little bit of research brought me to a [Stack Overflow article](https://stackoverflow.com/questions/15270902/check-for-internet-connectivity-in-nodejs) where people recommend checking DNS resolution as a proxy for online connectivity. This might work in a predictable environment, one that you have control over. However, that is only one piece of the puzzle.

Think firewalls: DNS by default uses UDP on port 53 (although DNS over TLS is gaining traction). A typical HTTPS connection uses a TCP connection on port 443. So we could end up with a scenario where our DNS resolution succeeds but we still can't connect via HTTPS because port 443 on TCP might be blocked.

And what about connections that don't use HTTP(S)? Does our application even make use of HTTPS? In that case, we might be better served checking for a successful TCP connection.

What's more: Sometimes all we need is a connection to an internal server (perhaps on a local network). We might not even need internet connectivity in that case. Still, we might want to make sure, that internal server can be reached before any further action is taken.

Let's assume our application behaves perfectly fine even if the network is unavailable. We can provide valuable feedback to our users by narrowing down where exactly the connection is broken. Rather than producing a generic network error, we can gather more accurate information about where in the stack the problem might lie.

## Connecting to an HTTPS endpoint

For example: Let's check if the [Ecosia website](https://www.ecosia.org/) can be reached (if you haven't heard about them, Ecosia is a search engine that reinvests profits to plant trees). Our connection URL looks like this: `https://www.ecosia.org/`. How do we check if we can connect to this endpoint? By making an HTTPS request. Under the hood, this involves things like DNS resolution and a TCP connection (have a look at the [OSI model](https://en.wikipedia.org/wiki/OSI_model) for more information). If any of those fail our HTTPS connection will fail as well.

[Here is an example](https://gist.github.com/paulgalow/9957a5a42e87701a2d41c3f836599d81) of how to do that in Node.js. We are declaring a function to check an HTTP(S) connection and that takes a URL as input:

```js
const { parse } = require("url");

function checkHTTP(url) {
  return new Promise((resolve, reject) => {
    const { protocol } = parse(url);
    const lib = protocol === "https:" ? require("https") : require("http");

    const request = lib.get(url, response => {
      console.log(`HTTP Status Code:`, response.statusCode);
      resolve(response);
    });

    request.on("error", err => {
      console.error(
        `Error trying to connect via ${protocol.replace(":", "").toUpperCase()}`
      );
      reject(err);
    });
  });
}
```

We can then call this function as a Promise or using async/await:

```js
let isOnline;

checkHTTP("https://www.ecosia.org/")
  .then(() => (isOnline = true))
  .catch(() => (isOnline = false))
  .finally(() => console.log({ isOnline }));
```

If this check fails we can then dig down deeper into the networking stack to find out why. Perhaps our endpoint is offline? Let's rerun our check with a different domain, e.g. duckduckgo.com.

```js
checkHTTP("https://duckduckgo.com/")
  .then(() => (isOnline = true))
  .catch(() => (isOnline = false))
  .finally(() => console.log({ isOnline }));
```

No success? Perhaps there is a problem with DNS resolution. So let's see if we can make an HTTPS connection to a well known and highly-available DNS resolver's IP, e.g. Cloudflare's [1.1.1.1](https://1.1.1.1/dns/).

```js
checkHTTP("https://1.1.1.1")
  .then(() => (isOnline = true))
  .catch(() => (isOnline = false))
  .finally(() => console.log({ isOnline }));
```

## Making a TCP connection

Still failing? Let's try if we can make a TCP connection on a different port than 443 to rule out a firewall issue.

[Here is an example](https://gist.github.com/paulgalow/d33599630f139e600fd5a39a2dfec1bc) of how you can establish a TCP connection. We are declaring a function that takes a host and a port as inputs. A host can be a fully qualified domain name or an IP address. If no inputs are provided, it will default to **"1.1.1.1"** for the host and `53` (DNS) for the port. Note: DNS typically runs over UDP but DNS resolvers often also support TCP.

```js
const { createConnection } = require("net");

function checkTCP(host = "1.1.1.1", port = 53) {
  return new Promise((resolve, reject) => {
    const client = createConnection({ host, port }, () => {
      console.log(`TCP connection established on port ${port}`);
      client.end();
      resolve();
    });

    client.setTimeout(3000);

    client.on("timeout", err => {
      console.error(`TCP connection on port ${port} timed out`);
      client.destroy();
      reject(err);
    });

    client.on("error", err => {
      console.error(`Error trying to connect via TCP on port ${port}`);
      reject(err);
    });
  });
}
```

Again, we can call this function as a Promise or using async/await:

```js
let isOnline;

checkTCP()
  .then(() => (isOnline = true))
  .catch(() => (isOnline = false))
  .finally(() => console.log({ isOnline }));
```

I find checkTCP() to be useful when I am working with non-web protocols, such as SSH (typically port 22), SMTP (ports 25, 465 or 587) or RTMP (1935).

Of course, we will not be able to check for every eventuality but we might be able to detect the most common network issues this way.

Hope this helps you to get around some of those nasty issues as well.
