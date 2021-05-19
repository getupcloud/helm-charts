#!/bin/bash

set -xeu
REPO_URL=$1
REPO_DIR=${REPO_URL##*/}
REPO_DIR=${REPO_DIR%.git}
BRANCHES=${2:-remotes/origin/main remotes/origin/master}

mkdir -p git
cd git

if [ -d $REPO_DIR ]; then
    pushd $REPO_DIR
    git switch -
    git pull --all
else
    git clone $REPO_URL
    pushd $REPO_DIR
fi

for branch in $BRANCHES; do
    ref=$(git show-ref --tags --heads $branch | head -n1 | cut -f2 -d' ')
    if [ -n "$ref" ]; then
        git checkout $ref
        break
    fi
done
