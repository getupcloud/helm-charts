#!/bin/bash

git clone https://github.com/linkerd/linkerd2.git
(
  echo Checkout release-2.10
  cd linkerd2
  git checkout -b release-2.10 remotes/origin/release/stable-2.10
)

for i in linkerd2/grafana/dashboards/*.json; do
  n=linkerd-$(basename ${i##*/} .json)
  f=templates/$n.yaml
  echo '{{ if .Values.linkerd.enabled -}}{{ `' > $f
  kubectl create configmap $n --from-file=$i --dry-run=client -o yaml >> $f
  echo '`}}{{- end }}' >> $f
done

rm -rf linkerd2
