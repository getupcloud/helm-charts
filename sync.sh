#!/bin/bash

set -x

AWS_S3_BUCKET=${1:-getup-helm-mirror}
HELM_REPO_PREFIX=${2:-getupcloud}
shift 2

aws "$@" s3 sync repo/ s3://${AWS_S3_BUCKET}/${HELM_REPO_PREFIX}
