FROM $DOCKER_IMAGE_PARENT
LABEL maintainer="Mozilla Release Engineering <release+docker@mozilla.com>"

RUN apk add --no-cache gcc g++ libc-dev make cmake boost boost-dev

VOLUME /builds/worker/checkouts
