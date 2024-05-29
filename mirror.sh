#!/bin/bash

echo Download repositories...
./helm-mirror repo/ prometheus-community https://prometheus-community.github.io/helm-charts &
./helm-mirror repo/ autoscaler https://kubernetes.github.io/autoscaler &
./helm-mirror repo/ jetstack https://charts.jetstack.io &
./helm-mirror repo/ velero https://vmware-tanzu.github.io/helm-charts &
./helm-mirror repo/ ingress-nginx https://kubernetes.github.io/ingress-nginx &
./helm-mirror repo/ grafana https://grafana.github.io/helm-charts &
./helm-mirror repo/ elastic https://helm.elastic.co &
./helm-mirror repo/ harbor https://helm.goharbor.io &
./helm-mirror repo/ prometheus-msteams https://prometheus-msteams.github.io/prometheus-msteams/ &
./helm-mirror repo/ ot-helm https://ot-container-kit.github.io/helm-charts/ &

wait

echo Download karpenter from OCI...
mkdir -p repo/karpenter
for version in 0.35.{0,1,2,4,5} 0.36.{0..2} 0.37.0; do
  if ! [ -s repo/karpenter/karpenter-${version}.tgz ]; then
    helm fetch oci://public.ecr.aws/karpenter/karpenter  --version $version --destination repo/karpenter
  fi
done
helm repo index repo/karpenter
