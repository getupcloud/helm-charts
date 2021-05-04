set -aexu

rm -rf certs-1 certs-2
CERTIFICATE_PASSWORD_DATA=raven
CERTS_DIR=certs-1 CA_ONLY=1 scripts/gen-certificate.sh raven1 raven1
CERTS_DIR=certs-2 CA_ONLY=1 scripts/gen-certificate.sh raven2 raven2
CERTS_DIR=certs-1 scripts/gen-certificate.sh raven1 raven1
CERTS_DIR=certs-2 scripts/gen-certificate.sh raven2 raven2

cat certs-1/ca.crt certs-2/ca.crt >> certs-1/ca-bundle.crt
cat certs-1/ca.crt certs-2/ca.crt >> certs-2/ca-bundle.crt

helm upgrade --install raven1 . --create-namespace -n raven1 \
    --set tls.pfx=certs-1/tls.pfx \
    --set tls.password=certs-1/password.txt \
    --set tls.fingerprint=certs-1/fingerprint.txt \
    --set tls.trustedCA=certs-2/ca-bundle.crt \
    --set tls.trustedFingerprint=certs-2/fingerprint.txt \

helm upgrade --install raven2 . --create-namespace -n raven2 \
    --set tls.pfx=certs-2/tls.pfx \
    --set tls.password=certs-2/password.txt \
    --set tls.fingerprint=certs-2/fingerprint.txt \
    --set tls.trustedCA=certs-1/ca-bundle.crt \
    --set tls.trustedFingerprint=certs-1/fingerprint.txt \
    --set replicaCount=3
