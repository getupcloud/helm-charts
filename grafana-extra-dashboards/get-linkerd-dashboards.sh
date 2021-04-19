#!/bin/bash

git clone https://github.com/linkerd/linkerd2.git
(
  echo Checkout release-2.10
  cd linkerd2
  git checkout -b release-2.10 remotes/origin/release/stable-2.10
)

rm -rf dashboards/linkerd
mkdir -p dashboards/linkerd

for i in linkerd2/grafana/dashboards/*.json; do
  cp -vf $i dashboards/linkerd/linkerd-${i##*/}
done
#rm -rf linkerd2
