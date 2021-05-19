#!/bin/bash

debug=false
full=false
no_mirror=false

while [ $# -gt 0 ]; do
  case $1 in
    -d|--debug) debug=true;;
    -f|--full) full=true;;
    -n|--no-mirror) no_mirror=true;;
    -h|--help|help) echo "Usage: $0 [-f|--full] [-n|--no-mirror]"; exit 0;;
    *) echo "Usage: $0 [-f|--full] [-n|--no-mirror]"; exit 1
  esac
  shift
done

$debug && set -x

if $full; then
  rm -rf repo
fi

charts=( $(ls -d */ | grep -vwE '^(dev|repo|git)/$') ) # exclude dirs dev/ and repo/

mkdir -p repo/getupcloud

echo Downloading git repos
./git-download.sh https://github.com/CrunchyData/postgres-operator.git v4.6.2 && charts+=( git/postgres-operator/installers/helm/ )

echo Charts sources: ${charts[*]}

echo Creating charts: repo/getupcloud
helm package -d repo/getupcloud "${charts[@]}"
echo Creating index: repo/getupcloud
helm repo index repo/getupcloud
cp index.html repo/

$no_mirror && exit

echo Download mirrors
./helm-mirror repo/ prometheus-community https://prometheus-community.github.io/helm-charts
./helm-mirror repo/ autoscaler https://kubernetes.github.io/autoscaler
./helm-mirror repo/ jetstack https://charts.jetstack.io
./helm-mirror repo/ velero https://vmware-tanzu.github.io/helm-charts
./helm-mirror repo/ ingress-nginx https://kubernetes.github.io/ingress-nginx
./helm-mirror repo/ loki https://grafana.github.io/loki/charts
./helm-mirror repo/ elastic https://helm.elastic.co
./helm-mirror repo/ harbor https://helm.goharbor.io
./helm-mirror repo/ prometheus-msteams https://prometheus-msteams.github.io/prometheus-msteams/
./helm-mirror repo/ ot-helm https://ot-container-kit.github.io/helm-charts/

