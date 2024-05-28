#!/bin/bash

cd ../../../test-network || exit 1

export PATH=${PWD}/../bin:${PWD}:$PATH
export FABRIC_CFG_PATH=$PWD/../config/
export FABRIC_CA_CLIENT_HOME=${PWD}/organizations/peerOrganizations/org1.example.com/

USERNAME="$1"

{
    fabric-ca-client register --id.name ${USERNAME} --id.secret ${USERNAME} --id.type client --id.affiliation org1 --id.attrs 'abac.creator=true:ecert' --tls.certfiles "${PWD}/organizations/fabric-ca/org1/tls-cert.pem"

    fabric-ca-client enroll -u "https://${USERNAME}:${USERNAME}@localhost:7054" --caname ca-org1 -M "${PWD}/organizations/peerOrganizations/org1.example.com/users/${USERNAME}@org1.example.com/msp" --tls.certfiles "${PWD}/organizations/fabric-ca/org1/tls-cert.pem"

    cp "${PWD}/organizations/peerOrganizations/org1.example.com/msp/config.yaml" "${PWD}/organizations/peerOrganizations/org1.example.com/users/${USERNAME}@org1.example.com/msp/config.yaml"
} &>/dev/null

echo "Created and enrolled identity for user: ${USERNAME}"
