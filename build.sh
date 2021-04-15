#!/bin/bash

set -x

rm -rf repo
mkdir -p repo/getupcloud
charts=( $(ls -1d */) )

helm package -d repo/getupcloud "${charts[@]}"
helm repo index repo/getupcloud
