FROM alpine:3 AS build

ARG IS_GHA=""

RUN apk add --no-cache --update \
  autoconf \
  automake \
  binutils \
  cmake \
  file \
  fortify-headers \
  g++ \
  gcc \
  libatomic \
  libc-dev \
  make \
  musl-dev \
  nasm \
  yasm \
  libgcc \
  libstdc++ \
  bash \
  coreutils \
  curl \
  openssl-dev \
  openssl-libs-static \
  zlib-dev \
  zlib-static \
  bzip2-dev \
  bzip2-static \
  libtool \
  diffutils \
  patch \
  python3 \
  rust \
  cargo \
  xxd

RUN apk add --no-cache \
  --repository http://dl-cdn.alpinelinux.org/alpine/edge/testing/ \
  cargo-c

RUN bash -c 'mkdir -p /app/{packages,workspace}'

RUN bash -c 'touch /app/packages/{nasm,yasm,cmake,zlib,bzip2,openssl}.done'

WORKDIR /app
COPY ./build-ffmpeg /app/build-ffmpeg

ENV IS_GHA "$IS_GHA"

RUN SKIPINSTALL=yes /app/build-ffmpeg --build --full-static

FROM alpine:3

COPY --from=build /app/workspace/bin/ffmpeg /usr/bin/ffmpeg
COPY --from=build /app/workspace/bin/ffprobe /usr/bin/ffprobe

CMD         ["--help"]
ENTRYPOINT  ["/usr/bin/ffmpeg"]
