#!/bin/bash

if [ -z "$AWS_PROFILE" ]; then
    read -p "AWS profile name: " AWS_PROFILE
fi

export AWS_PROFILE

#rm -rf repo
./download.sh
./build.sh
./upload.sh
