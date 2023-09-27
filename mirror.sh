#!/bin/bash

echo Download mirrors
./helm-mirror repo/ prometheus-community https://prometheus-community.github.io/helm-charts
./helm-mirror repo/ autoscaler https://kubernetes.github.io/autoscaler
./helm-mirror repo/ jetstack https://charts.jetstack.io
./helm-mirror repo/ velero https://vmware-tanzu.github.io/helm-charts
./helm-mirror repo/ ingress-nginx https://kubernetes.github.io/ingress-nginx
./helm-mirror repo/ grafana https://grafana.github.io/helm-charts
./helm-mirror repo/ elastic https://helm.elastic.co
./helm-mirror repo/ harbor https://helm.goharbor.io
./helm-mirror repo/ prometheus-msteams https://prometheus-msteams.github.io/prometheus-msteams/
./helm-mirror repo/ ot-helm https://ot-container-kit.github.io/helm-charts/
