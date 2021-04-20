#!/bin/bash

if ! [ -d linkerd2 ]; then
   git clone https://github.com/linkerd/linkerd2.git
    echo Checkout release-2.10
    pushd linkerd2
    git checkout -b release-2.10 remotes/origin/release/stable-2.10
    popd
else
    echo Pulling release-2.10
    pushd linkerd2
    git pull
    popd
fi

rm -rf dashboards/linkerd
mkdir -p dashboards/linkerd

for i in linkerd2/grafana/dashboards/*.json; do
  sed -e 's,<script.*</script>,,g' $i > dashboards/linkerd/linkerd-${i##*/}
done

#rm -rf linkerd2
