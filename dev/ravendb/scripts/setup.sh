#!/bin/bash

set -x
set -eu ## exit on error or missing var
set -a ## export all shell vars

DATA_DIR=${DATA_DIR:-/data}
CONFIG_DIR=${CONFIG_DIR:-/config}
CERTS_DIR=${CERTS_DIR:-/certs}
LICENSE_DIR=${LICENSE_DIR:-/license}

CERTIFICATE_PFX=${CERTS_DIR}/tls.pfx
CERTIFICATE_PASSWORD_DATA=$(cat ${CERTS_DIR}/password.txt)
CERTIFICATE_FINGERPRINT_DATA=$(cat ${CERTS_DIR}/fingerprint.txt)

TRUSTED_CA_CERTIFICATE=${CERTS_DIR}/trusted-ca.crt
TRUSTED_FINGERPRINT_DATA=$(cat ${CERTS_DIR}/trusted-fingerprint.txt 2>/dev/null) || true

PUBLIC_SERVER_DOMAIN=${SERVICE_NAME}.${NAMESPACE}.svc.cluster.local
PUBLIC_SERVER_HOSTNAME=${POD_NAME}.${PUBLIC_SERVER_DOMAIN}

{
cat <<EOF
{
    "Setup.Mode": "None",
    "DataDir": "${DATA_DIR}/RavenData",
    "Security.Certificate.Path": "${CERTIFICATE_PFX}",
    "Security.Certificate.Password": "${CERTIFICATE_PASSWORD_DATA}",
    "ServerUrl": "https://0.0.0.0:443",
    "ServerUrl.Tcp": "tcp://0.0.0.0:38888",
    "PublicServerUrl": "https://${PUBLIC_SERVER_HOSTNAME}",
    "PublicServerUrl.Tcp": "tcp://${PUBLIC_SERVER_HOSTNAME}:38888",
    "Logs.Mode": "Information",
    "License.Path": "${LICENSE_DIR}/license.json",
    "License.Eula.Accepted": true,
EOF

if [ -n "${TRUSTED_FINGERPRINT_DATA}" ]; then
    echo "    \"Security.WellKnownCertificates.Admin\": [\"${CERTIFICATE_FINGERPRINT_DATA}\", \"${TRUSTED_FINGERPRINT_DATA}\"]"
else
    echo "    \"Security.WellKnownCertificates.Admin\": [\"${CERTIFICATE_FINGERPRINT_DATA}\"]"
fi

echo '}'
} > ${CONFIG_DIR}/config.json

if [ -e ${TRUSTED_CA_CERTIFICATE} ]; then
    cp ${TRUSTED_CA_CERTIFICATE} /usr/local/share/ca-certificates/ravendb-trusted-ca.crt
    update-ca-certificates --verbose
fi
