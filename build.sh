#!/bin/bash

log() {
  local heading="$1"
  shift
  local args="$@"
  printf "  \033[36m%10s\033[0m : \033[90m%s\033[0m\n" "$heading" "$args"
}

warn() {
  local heading="$1"
  shift
  local args="$@"
  printf "  \033[33m%10s\033[0m : \033[90m%s\033[0m\n" "$heading" "$args"
}

abort() {
  local args="$@"
  printf "\n  \033[31mERR!: $args\033[0m\n\n" && exit 1
}

latest_version() {
  git ls-remote -t git://github.com/nodejs/node \
    | awk '{print $2}' \
    | cut -d '/' -f 3 \
    | grep -v '\^' \
    | grep -v '-' \
    | grep -v 'heads' \
    | grep -v 'jenkins' \
    | sed 's/v//g' \
    | sort -u -k 1,1n -k 2,2n -k 3,3n -t . \
    | tail -n1
}

our_version() {
  cat Dockerfile | grep "ENV NODE_VERSION" | awk '{print $3}'
}

PUBLISH=0
LATEST=$(latest_version)
OURS=$(our_version)
TAG="evanlucas/node_debug"
TAG_LATEST=0

main() {
  if [[ "$LATEST" != "$OURS" ]]; then
    warn build outdated
    warn LATEST "$LATEST"
    warn CURRENT "$OURS"
  fi

  log build "$OURS"
  log build this may take a while...
  docker build -t "$TAG":"$OURS" .
  if [[ $? -ne 0 ]]; then
    abort "failed to build image"
  fi
  log build success "($TAG:$OURS)"

  if [[ "$PUBLISH" -eq 1 ]]; then
    log push "$TAG:$OURS"
    docker push "$TAG":"$OURS"
    log push success "$TAG:$OURS"

    if [[ "$TAG_LATEST" -ne 0 ]]; then
      # tag the version as latest
      # and then push latest
      local img_id=$(docker images | grep "$TAG" | grep "$OURS" | awk '{print $3}')
      log tag "$img_id -> latest"
      docker tag "$img_id" "$TAG:latest"
      log tag success latest
      docker push "$TAG:latest"
      log push success latest
    fi
  fi
}

while [[ $# > 0 ]]; do
  key="$1"

  case $key in
    -p|--publish)
      PUBLISH=1
      ;;
    -t|--tag)
      shift
      TAG="$1"
      ;;
    -l|--latest)
      TAG_LATEST=1
      ;;
    --print)
      latest_version
      exit 0
      ;;
  esac
  shift
done

main
