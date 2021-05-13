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
    popd
else
    git clone $REPO_URL
    pushd $REPO_DIR
fi

for branch in $BRANCHES; do
    if git show-ref --verify --quiet refs/$branch; then
        git checkout $branch
        break
    fi
done
