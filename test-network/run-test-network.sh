#!/bin/bash

./network.sh down && ./network.sh up createChannel -s couchdb && cd addOrg3 && ./addOrg3.sh up -s couchdb && cd .. && ./network.sh deployCC -ccn basic -ccp ../asset-transfer-basic/chaincode-go -ccl go