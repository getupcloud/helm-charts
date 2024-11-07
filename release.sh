#!/bin/bash

if [ "$(git diff --stat)" != '' ]; then
  git diff --stat
  echo
  echo Please, commit first
  exit 1
fi

if git status charts | grep /templates/; then
  echo
  echo Remove stale files from templates dir
  exit 1
fi

[ -e .env ] && . .env
if [ -z "$AWS_PROFILE" ]; then
    read -p "AWS profile name: " AWS_PROFILE
fi

export AWS_PROFILE

./download.sh
./build.sh "$@"
./upload.sh
