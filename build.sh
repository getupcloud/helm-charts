#!/bin/bash

set -x

full=false
while [ $# -gt 0 ]; do
  case $1 in
    -f|--full) full=true; shift;;
  esac
done

if $full; then
  rm -rf repo
fi

charts=( $(ls -1d */) )

mkdir -p repo/getupcloud

helm package -d repo/getupcloud "${charts[@]}"
helm repo index repo/getupcloud

./helm-mirror repo/ prometheus-community https://prometheus-community.github.io/helm-charts
./helm-mirror repo/ autoscaler https://kubernetes.github.io/autoscaler
./helm-mirror repo/ jetstack https://charts.jetstack.io
./helm-mirror repo/ velero https://vmware-tanzu.github.io/helm-charts
./helm-mirror repo/ ingress-nginx https://kubernetes.github.io/ingress-nginx
./helm-mirror repo/ loki https://grafana.github.io/loki/charts
./helm-mirror repo/ elastic https://helm.elastic.co
./helm-mirror repo/ harbor https://helm.goharbor.io
