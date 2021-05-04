#!/bin/bash

if [ $# -ne 2 ]; then
    echo Usage: $0 NAMESPACE RELEASE_NAME
    exit 1
fi

set -eu ## exit on error or missing var
set -a ## export all shell vars

NAMESPACE=$1
HELM_RELEASE_NAME=$2

SERVICE_NAME=${HELM_RELEASE_NAME}-$(grep ^name: Chart.yaml |cut -f2- -d' ') ## same from {{ include "ravendb.fullname" . }}
PUBLIC_SERVER_DOMAIN=${SERVICE_NAME}.${NAMESPACE}.svc.cluster.local

CERTS_DIR=${CERTS_DIR:-certs}

CA_CONF=scripts/ca.conf
TLS_CONF=scripts/tls.conf

CA_CERTIFICATE=${CERTS_DIR}/ca.crt
CA_CERTIFICATE_KEY=${CERTS_DIR}/ca.key
CERTIFICATE=${CERTS_DIR}/tls.crt
CERTIFICATE_KEY=${CERTS_DIR}/tls.key
CERTIFICATE_REQ=${CERTS_DIR}/tls.csr
CERTIFICATE_PFX=${CERTS_DIR}/tls.pfx
CERTIFICATE_BUNDLE=${CERTS_DIR}/tls-bundle.crt
CERTIFICATE_PASSWORD=${CERTS_DIR}/password.txt
CERTIFICATE_PASSWORD_DATA=${CERTIFICATE_PASSWORD_DATA:-$(cat ${CERTS_DIR}/password.txt 2>/dev/null)} || true
CERTIFICATE_FINGERPRINT=${CERTS_DIR}/fingerprint.txt

mkdir -p $CERTS_DIR

if ! [ -e ${CA_CERTIFICATE} ]; then
    openssl req -nodes -new -x509 \
        -days 3650 \
        -config ${CA_CONF} \
        -subj "/CN=ca.${PUBLIC_SERVER_DOMAIN}" \
        -keyout ${CA_CERTIFICATE_KEY} \
        -out ${CA_CERTIFICATE}
fi

if [ -v CA_ONLY ]; then
    exit
fi

if ! [ -e ${CERTIFICATE} ]; then
    openssl genrsa 4096 > ${CERTIFICATE_KEY}

    openssl req -new \
        -config ${TLS_CONF} \
        -reqexts CA \
        -extensions CA \
        -subj "/CN=*.${PUBLIC_SERVER_DOMAIN}" \
        -key ${CERTIFICATE_KEY} \
        -out ${CERTIFICATE_REQ}

    openssl x509 -req -days 3650 \
        -extfile ${TLS_CONF} \
        -extensions CA \
        -in ${CERTIFICATE_REQ} \
        -CA ${CA_CERTIFICATE} \
        -CAkey ${CA_CERTIFICATE_KEY} \
        -set_serial $(date +%s) \
        -out ${CERTIFICATE}
fi

if ! [ -e ${CERTIFICATE_PFX} ]; then

    #cat ${CERTIFICATE} > ${CERTIFICATE_BUNDLE}
    #echo >> ${CERTIFICATE_BUNDLE}
    #cat ${CA_CERTIFICATE} >> ${CERTIFICATE_BUNDLE}
    #if [ -v EXTRA_CA_CERTIFICATES ]; then
    #    for ca in ${EXTRA_CA_CERTIFICATES}; do
    #        cat ${ca} >> ${CERTIFICATE_BUNDLE}
    #    done
    #fi

    if [ -z "${CERTIFICATE_PASSWORD_DATA}" ]; then
        read -p "New Certificate Password: " CERTIFICATE_PASSWORD_DATA
        if [ -e ${CERTIFICATE_PASSWORD} ]; then
            mv -vf ${CERTIFICATE_PASSWORD} ${CERTIFICATE_PASSWORD}.old
        fi
    fi

    echo -n "${CERTIFICATE_PASSWORD_DATA}" > ${CERTIFICATE_PASSWORD}

    openssl x509 -noout -fingerprint -sha1 -inform pem -in ${CERTIFICATE} | cut -f2 -d= | tr -d : | tr [A-Z] [a-z] > ${CERTIFICATE_FINGERPRINT}

    openssl pkcs12 -export \
        -inkey ${CERTIFICATE_KEY} \
        -password pass:${CERTIFICATE_PASSWORD_DATA} \
        -in ${CERTIFICATE} \
        -out ${CERTIFICATE_PFX}
fi
