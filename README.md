# helm-charts

## Criar um novo chart

```
$ helm create myapp

## Altere seu novo chart a vontade

$ git add myapp
```

## Publicar no repositorio (charts.getup.io)

```
$ ./release.sh
```

Use as variaveis `AWS_PROFILE` e `AWS_S3_BUCKET` de acordo com a necessidade.

## Usar o repositorio

```
$ helm repo add getupcloud https://charts.getup.io/getupcloud
```

## Usar mirrors de outros repositorios (atualizados eventualmente):

```
$ helm repo add prometheus-community https://charts.getup.io/prometheus-community
$ helm repo add autoscaler https://charts.getup.io/autoscaler
$ helm repo add jetstack https://charts.getup.io/jetstack
$ helm repo add velero https://charts.getup.io/velero
$ helm repo add ingress-nginx https://charts.getup.io/ingress-nginx
$ helm repo add loki https://charts.getup.io/loki
$ helm repo add elastic https://charts.getup.io/elastic
$ helm repo add harbor https://charts.getup.io/harbor
```

