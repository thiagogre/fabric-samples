#!/bin/bash

./network.sh down && ./network.sh up createChannel -ca -s couchdb && cd addOrg3 && ./addOrg3.sh up -ca -s couchdb && cd .. && ./network.sh deployCC -ccn basic -ccp ../asset-transfer-basic/chaincode-go -ccl go