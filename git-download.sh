#!/bin/bash

set -xeu

REPO_URL=$1
REPO_DIR=${REPO_URL##*/}
REPO_DIR=${REPO_DIR%.git}
REFS=${2:-remotes/origin/main remotes/origin/master}

mkdir -p git
cd git

if [ -d "$REPO_DIR" ]; then
    rm -rf "$REPO_DIR"
fi

git clone $REPO_URL
cd "$REPO_DIR"

for ref in $REFS; do
    ref=$(git show-ref $ref | head -n1 | cut -f2 -d' ')
    if [ -n "$ref" ]; then
        git checkout $ref
        break
    fi
done
