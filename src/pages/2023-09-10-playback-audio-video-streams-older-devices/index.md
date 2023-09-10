---
slug: transcode-internet-radio-video-streams-mp3
title: "Transcode Internet radio and video streams to HTTP MP3 streams with racoder"
date: "2023-09-10"
---

![A retro-futuristic radio](./radio-midjourney.png)

In my household, we've enjoyed listening to spoken-word radio for years. Our favorite station is [BBC Radio 4 Extra](https://www.bbc.co.uk/sounds/play/live:bbc_radio_four_extra), a no-news, no-music program dedicated solely to the BBC's spoken-word archive. Interestingly, our "radio" of choice is rather atypical for this purpose: it's a small handheld DECT phone by the German company AVM called "FRITZ!Fon C4". Although it's somewhat dated and no longer available for purchase, is has served us well. One of its unique features is the ability to play back Internet radio streams. However, this feature recently hit a snag.

Earlier this year, the [BBC switched their streams](https://www.bbc.co.uk/sounds/help/questions/recent-changes-to-bbc-sounds/shoutcast-closure) from MP3 (Shoutcast) to a more modern AAC-based HLS and MPEG-DASH infrastructure. As a result, our FRITZ!Fon C4 could no longer play the station. I initially considered buying a new device but couldn't find one that met all my requirements. So, I decided to build a converter.

## Introducing racoder

[racoder](https://github.com/paulgalow/racoder) is a lightweight Node.js web server that leverages the powerful [FFmpeg](https://ffmpeg.org/) library to transcode internet radio and video streams into HTTP MP3 streams. It supports a variety of input stream formats, including HLS, MPEG-DASH, and RTMP – essentially, anything that FFmpeg can handle.

One of the key design considerations for racoder is efficiency. It only transcodes and consumes bandwidth when a consumer is actively using it. The server runs in a Docker container with just 256 MB of RAM and has minimal CPU usage. It's ideal for small, private deployments. It's not ideal for scale: each incoming request spawns a separate FFmpeg instance, consuming approximately an additional 20 MB of RAM and some network bandwidth per active stream.

If you are interested in deploying racoder, I've provided example configurations for Docker Compose and fly.io in the project's [GitHub repository](https://github.com/paulgalow/racoder). Pre-built images are available on [Docker Hub](https://hub.docker.com/repository/docker/paulgalow/racoder/general) and the [GitHub Container Registry](https://github.com/paulgalow/racoder/pkgs/container/racoder/versions?filters%5Bversion_type%5D=tagged).
