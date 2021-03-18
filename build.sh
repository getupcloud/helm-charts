#!/bin/bash

set -x

rm -rf repo
charts=( $(ls -1d */) )

helm package -d repo "${charts[@]}"
helm repo index repo/
