FROM nvidia/cuda:11.1-devel-ubuntu20.04 AS build

ENV DEBIAN_FRONTEND noninteractive
ENV NVIDIA_VISIBLE_DEVICES all
ENV NVIDIA_DRIVER_CAPABILITIES compute,utility,video

RUN apt-get update \
    && apt-get -y --no-install-recommends install build-essential curl ca-certificates \
    && apt-get clean; rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /usr/share/doc/* \
    && update-ca-certificates

WORKDIR /app
COPY ./build-ffmpeg /app/build-ffmpeg

RUN SKIPINSTALL=yes /app/build-ffmpeg --build --full-static

# Check shared library
RUN ! ldd /app/workspace/bin/ffmpeg
RUN ! ldd /app/workspace/bin/ffprobe
# RUN ! ldd /app/workspace/bin/ffplay

FROM ubuntu:20.04

ENV NVIDIA_VISIBLE_DEVICES all
ENV NVIDIA_DRIVER_CAPABILITIES compute,utility,video

# Copy ffmpeg
COPY --from=build /app/workspace/bin/ffmpeg /usr/bin/ffmpeg
COPY --from=build /app/workspace/bin/ffprobe /usr/bin/ffprobe
# COPY --from=build /app/workspace/bin/ffplay /usr/bin/ffplay

CMD         ["--help"]
ENTRYPOINT  ["/usr/bin/ffmpeg"]