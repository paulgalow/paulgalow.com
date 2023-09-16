---
slug: transcode-internet-radio-video-streams-mp3
title: "Transcode Internet radio and video streams to HTTP MP3 streams with racoder"
date: "2023-09-10"
---

![A retro-futuristic radio](./radio-midjourney.png)

In my household, we've been listening to spoken-word radio for years. Our favorite station is [BBC Radio 4 Extra](https://www.bbc.co.uk/sounds/play/live:bbc_radio_four_extra), a no-news, no-music program devoted entirely to the BBC's spoken-word archive. Interestingly, our "radio" of choice is rather atypical for this purpose: it's a small hand-held DECT phone from the German company AVM called "FRITZ!Fon C4". It's a bit outdated and no longer available, but it has served us well. One of its unique features is the ability to play back Internet radio streams. However, this feature has recently hit a snag.

Earlier this year, the [BBC switched its streams](https://www.bbc.co.uk/sounds/help/questions/recent-changes-to-bbc-sounds/shoutcast-closure) from MP3 (Shoutcast) to a more modern AAC-based HLS and MPEG-DASH infrastructure. As a result, our FRITZ!Fon C4 could no longer play the station. At first I thought about buying a new device, but I couldn't find one that met all my requirements. So I decided to build a converter.

## Introducing racoder

[racoder](https://github.com/paulgalow/racoder) is a lightweight Node.js web server that leverages the powerful [FFmpeg](https://ffmpeg.org/) to transcode Internet radio and video streams into HTTP MP3 streams. It supports a variety of input stream formats, including HLS, MPEG-DASH, and RTMP – essentially, anything that FFmpeg can handle.

One of the key design considerations for racoder is efficiency. It only transcodes and consumes bandwidth when a consumer is actively using it. The server runs in a Docker container with as little as 256 MB of RAM and has minimal CPU usage. It's ideal for small, private deployments. It's not ideal for scale: each incoming request spawns a separate FFmpeg instance, consuming about 20 MB of additional RAM and some network bandwidth per active stream.

If you're interested in deploying racoder, I've provided sample configurations for Docker Compose and fly.io in the project's [GitHub repository](https://github.com/paulgalow/racoder). Pre-built images for various architectures are available on [Docker Hub](https://hub.docker.com/repository/docker/paulgalow/racoder/general) and the [GitHub Container Registry](https://github.com/paulgalow/racoder/pkgs/container/racoder/versions?filters%5Bversion_type%5D=tagged). Deploy using Docker Compose on a small home server like a Raspberry Pi or host it (for free) on fly.io.
