#!/bin/bash

function createOrg() {
  local org="${1:-org1}"

  # TODO: FIX THIS DUPLICATION
  declare -A ca_ports
  ca_ports["org1"]="7054"
  ca_ports["org2"]="8054"
  ca_ports["org3"]="11054"
  local ca_port=${ca_ports[$org]}

  infoln "Enrolling the CA admin"
  mkdir -p "organizations/peerOrganizations/${org}.example.com/"

  export FABRIC_CA_CLIENT_HOME=${PWD}/organizations/peerOrganizations/${org}.example.com/

  set -x
  fabric-ca-client enroll -u "https://admin:adminpw@localhost:${ca_port}" --caname "ca-${org}" --tls.certfiles "${PWD}/organizations/fabric-ca/${org}/ca-cert.pem"
  { set +x; } 2>/dev/null

  echo "NodeOUs:
  Enable: true
  ClientOUIdentifier:
    Certificate: cacerts/localhost-${ca_port}-ca-${org}.pem
    OrganizationalUnitIdentifier: client
  PeerOUIdentifier:
    Certificate: cacerts/localhost-${ca_port}-ca-${org}.pem
    OrganizationalUnitIdentifier: peer
  AdminOUIdentifier:
    Certificate: cacerts/localhost-${ca_port}-ca-${org}.pem
    OrganizationalUnitIdentifier: admin
  OrdererOUIdentifier:
    Certificate: cacerts/localhost-${ca_port}-ca-${org}.pem
    OrganizationalUnitIdentifier: orderer" >"${PWD}/organizations/peerOrganizations/${org}.example.com/msp/config.yaml"

  # Since the CA serves as both the organization CA and TLS CA, copy the org's root cert that was generated by CA startup into the org level ca and tlsca directories

  # Copy org's CA cert to org's /msp/tlscacerts directory (for use in the channel MSP definition)
  mkdir -p "${PWD}/organizations/peerOrganizations/${org}.example.com/msp/tlscacerts"
  cp "${PWD}/organizations/fabric-ca/${org}/ca-cert.pem" "${PWD}/organizations/peerOrganizations/${org}.example.com/msp/tlscacerts/ca.crt"

  # Copy org's CA cert to org's /tlsca directory (for use by clients)
  mkdir -p "${PWD}/organizations/peerOrganizations/${org}.example.com/tlsca"
  cp "${PWD}/organizations/fabric-ca/${org}/ca-cert.pem" "${PWD}/organizations/peerOrganizations/${org}.example.com/tlsca/tlsca.${org}.example.com-cert.pem"

  # Copy org's CA cert to org's /ca directory (for use by clients)
  mkdir -p "${PWD}/organizations/peerOrganizations/${org}.example.com/ca"
  cp "${PWD}/organizations/fabric-ca/${org}/ca-cert.pem" "${PWD}/organizations/peerOrganizations/${org}.example.com/ca/ca.${org}.example.com-cert.pem"

  infoln "Registering peer0"
  set -x
  fabric-ca-client register --caname "ca-${org}" --id.name peer0 --id.secret peer0pw --id.type peer --tls.certfiles "${PWD}/organizations/fabric-ca/${org}/ca-cert.pem"
  { set +x; } 2>/dev/null

  infoln "Registering user"
  set -x
  fabric-ca-client register --caname "ca-${org}" --id.name user1 --id.secret user1pw --id.type client --tls.certfiles "${PWD}/organizations/fabric-ca/${org}/ca-cert.pem"
  { set +x; } 2>/dev/null

  infoln "Registering the org admin"
  set -x
  fabric-ca-client register --caname "ca-${org}" --id.name "${org}admin" --id.secret "${org}adminpw" --id.type admin --tls.certfiles "${PWD}/organizations/fabric-ca/${org}/ca-cert.pem"
  { set +x; } 2>/dev/null

  infoln "Generating the peer0 msp"
  set -x
  fabric-ca-client enroll -u "https://peer0:peer0pw@localhost:${ca_port}" --caname "ca-${org}" -M "${PWD}/organizations/peerOrganizations/${org}.example.com/peers/peer0.${org}.example.com/msp" --tls.certfiles "${PWD}/organizations/fabric-ca/${org}/ca-cert.pem"
  { set +x; } 2>/dev/null

  cp "${PWD}/organizations/peerOrganizations/${org}.example.com/msp/config.yaml" "${PWD}/organizations/peerOrganizations/${org}.example.com/peers/peer0.${org}.example.com/msp/config.yaml"

  infoln "Generating the peer0-tls certificates, use --csr.hosts to specify Subject Alternative Names"
  set -x
  fabric-ca-client enroll -u "https://peer0:peer0pw@localhost:${ca_port}" --caname "ca-${org}" -M "${PWD}/organizations/peerOrganizations/${org}.example.com/peers/peer0.${org}.example.com/tls" --enrollment.profile tls --csr.hosts "peer0.${org}.example.com" --csr.hosts localhost --tls.certfiles "${PWD}/organizations/fabric-ca/${org}/ca-cert.pem"
  { set +x; } 2>/dev/null

  # Copy the tls CA cert, server cert, server keystore to well known file names in the peer's tls directory that are referenced by peer startup config
  cp "${PWD}/organizations/peerOrganizations/${org}.example.com/peers/peer0.${org}.example.com/tls/tlscacerts/"* "${PWD}/organizations/peerOrganizations/${org}.example.com/peers/peer0.${org}.example.com/tls/ca.crt"
  cp "${PWD}/organizations/peerOrganizations/${org}.example.com/peers/peer0.${org}.example.com/tls/signcerts/"* "${PWD}/organizations/peerOrganizations/${org}.example.com/peers/peer0.${org}.example.com/tls/server.crt"
  cp "${PWD}/organizations/peerOrganizations/${org}.example.com/peers/peer0.${org}.example.com/tls/keystore/"* "${PWD}/organizations/peerOrganizations/${org}.example.com/peers/peer0.${org}.example.com/tls/server.key"

  infoln "Generating the user msp"
  set -x
  fabric-ca-client enroll -u "https://user1:user1pw@localhost:${ca_port}" --caname "ca-${org}" -M "${PWD}/organizations/peerOrganizations/${org}.example.com/users/User1@${org}.example.com/msp" --tls.certfiles "${PWD}/organizations/fabric-ca/${org}/ca-cert.pem"
  { set +x; } 2>/dev/null

  cp "${PWD}/organizations/peerOrganizations/${org}.example.com/msp/config.yaml" "${PWD}/organizations/peerOrganizations/${org}.example.com/users/User1@${org}.example.com/msp/config.yaml"

  infoln "Generating the org admin msp"
  set -x
  fabric-ca-client enroll -u "https://${org}admin:${org}adminpw@localhost:${ca_port}" --caname "ca-${org}" -M "${PWD}/organizations/peerOrganizations/${org}.example.com/users/Admin@${org}.example.com/msp" --tls.certfiles "${PWD}/organizations/fabric-ca/${org}/ca-cert.pem"
  { set +x; } 2>/dev/null

  cp "${PWD}/organizations/peerOrganizations/${org}.example.com/msp/config.yaml" "${PWD}/organizations/peerOrganizations/${org}.example.com/users/Admin@${org}.example.com/msp/config.yaml"
}

function createOrderer() {
  infoln "Enrolling the CA admin"
  mkdir -p organizations/ordererOrganizations/example.com

  export FABRIC_CA_CLIENT_HOME=${PWD}/organizations/ordererOrganizations/example.com

  set -x
  fabric-ca-client enroll -u https://admin:adminpw@localhost:9054 --caname ca-orderer --tls.certfiles "${PWD}/organizations/fabric-ca/ordererOrg/ca-cert.pem"
  { set +x; } 2>/dev/null

  echo 'NodeOUs:
  Enable: true
  ClientOUIdentifier:
    Certificate: cacerts/localhost-9054-ca-orderer.pem
    OrganizationalUnitIdentifier: client
  PeerOUIdentifier:
    Certificate: cacerts/localhost-9054-ca-orderer.pem
    OrganizationalUnitIdentifier: peer
  AdminOUIdentifier:
    Certificate: cacerts/localhost-9054-ca-orderer.pem
    OrganizationalUnitIdentifier: admin
  OrdererOUIdentifier:
    Certificate: cacerts/localhost-9054-ca-orderer.pem
    OrganizationalUnitIdentifier: orderer' >"${PWD}/organizations/ordererOrganizations/example.com/msp/config.yaml"

  # Since the CA serves as both the organization CA and TLS CA, copy the org's root cert that was generated by CA startup into the org level ca and tlsca directories

  # Copy orderer org's CA cert to orderer org's /msp/tlscacerts directory (for use in the channel MSP definition)
  mkdir -p "${PWD}/organizations/ordererOrganizations/example.com/msp/tlscacerts"
  cp "${PWD}/organizations/fabric-ca/ordererOrg/ca-cert.pem" "${PWD}/organizations/ordererOrganizations/example.com/msp/tlscacerts/tlsca.example.com-cert.pem"

  # Copy orderer org's CA cert to orderer org's /tlsca directory (for use by clients)
  mkdir -p "${PWD}/organizations/ordererOrganizations/example.com/tlsca"
  cp "${PWD}/organizations/fabric-ca/ordererOrg/ca-cert.pem" "${PWD}/organizations/ordererOrganizations/example.com/tlsca/tlsca.example.com-cert.pem"

  infoln "Registering orderer"
  set -x
  fabric-ca-client register --caname ca-orderer --id.name orderer --id.secret ordererpw --id.type orderer --tls.certfiles "${PWD}/organizations/fabric-ca/ordererOrg/ca-cert.pem"
  { set +x; } 2>/dev/null

  infoln "Registering the orderer admin"
  set -x
  fabric-ca-client register --caname ca-orderer --id.name ordererAdmin --id.secret ordererAdminpw --id.type admin --tls.certfiles "${PWD}/organizations/fabric-ca/ordererOrg/ca-cert.pem"
  { set +x; } 2>/dev/null

  infoln "Generating the orderer msp"
  set -x
  fabric-ca-client enroll -u https://orderer:ordererpw@localhost:9054 --caname ca-orderer -M "${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp" --tls.certfiles "${PWD}/organizations/fabric-ca/ordererOrg/ca-cert.pem"
  { set +x; } 2>/dev/null

  cp "${PWD}/organizations/ordererOrganizations/example.com/msp/config.yaml" "${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/config.yaml"

  infoln "Generating the orderer-tls certificates, use --csr.hosts to specify Subject Alternative Names"
  set -x
  fabric-ca-client enroll -u https://orderer:ordererpw@localhost:9054 --caname ca-orderer -M "${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/tls" --enrollment.profile tls --csr.hosts orderer.example.com --csr.hosts localhost --tls.certfiles "${PWD}/organizations/fabric-ca/ordererOrg/ca-cert.pem"
  { set +x; } 2>/dev/null

  # Copy the tls CA cert, server cert, server keystore to well known file names in the orderer's tls directory that are referenced by orderer startup config
  cp "${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/tls/tlscacerts/"* "${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/tls/ca.crt"
  cp "${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/tls/signcerts/"* "${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/tls/server.crt"
  cp "${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/tls/keystore/"* "${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/tls/server.key"

  # Copy orderer org's CA cert to orderer's /msp/tlscacerts directory (for use in the orderer MSP definition)
  mkdir -p "${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts"
  cp "${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/tls/tlscacerts/"* "${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem"

  infoln "Generating the admin msp"
  set -x
  fabric-ca-client enroll -u https://ordererAdmin:ordererAdminpw@localhost:9054 --caname ca-orderer -M "${PWD}/organizations/ordererOrganizations/example.com/users/Admin@example.com/msp" --tls.certfiles "${PWD}/organizations/fabric-ca/ordererOrg/ca-cert.pem"
  { set +x; } 2>/dev/null

  cp "${PWD}/organizations/ordererOrganizations/example.com/msp/config.yaml" "${PWD}/organizations/ordererOrganizations/example.com/users/Admin@example.com/msp/config.yaml"
}
