# ------------------------------------------------------------------------------
# Script file: generate-openssl-cert.sh
#
# Purpose:
#   - Define openssl certificate details & create openssl.crf file
#   - Automate creation instead of manually typing it interactively
#
# Usage:
#   ./datasets/scripts/certificates/generate-openssl-cert.sh
#
# Source:
#   https://blog.min.io/data-science-sql-server/
# ------------------------------------------------------------------------------

#!/usr/bin/env bash

source ./datasets/scripts/env/.datasets.env

# write everthing between "EOF" markers into a file called openssl.cnf

echo "Starts writing to [openssl.cnf] file." 
cat <<EOF | cat > openssl.cnf


[req] #Defines settings for the certificate request.
distinguished_name = GlobalMartCert
x509_extensions = v3_req
prompt = no #openSSL will use the config file instead of asking interactively for DN fields

[GlobalMartCert] 
C = EG                     #Country
ST = CAIRO                 #State
L = Cairo                  #Locality/City
O = GlobalMart             #Organization
OU = DETeam                #Organizational Unit
CN = minio.mycluster.local #CommanName 

[v3_req]
subjectAltName = @alt_names

[alt_names]
IP.1 = 127.0.0.1
DNS.1 = localhost
IP.2 = 192.168.117.128
DNS.2 = "${MINIO_POD}.${MINIO_SERVICE}.${NAMESPACE}.${CLUSTER_DOMAIN}"
EOF

echo "Finished writing to [openssl.cnf] file." 

echo "======================================================"
echo "Creating the openssl certificate"

openssl req -x509 -nodes -days 3605 -newkey rsa:2048 -keyout private.key -out public.crt -config openssl.cnf

