#!/bin/bash

set -x

AWS_S3_BUCKET=${AWS_S3_BUCKET:-charts.getup.io}

aws "$@" s3 sync s3://${AWS_S3_BUCKET}/ repo/
