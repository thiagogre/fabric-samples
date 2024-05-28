#!/bin/bash

display_message() {
    local RED='\033[31m'
    local GREEN='\033[32m'
    local YELLOW='\033[33m'
    local BLUE='\033[34m'
    local RESET='\033[0m'

    local message_type="$1"
    local message="$2"

    # Define a single associative array containing color and label as a single string
    declare -A message_info
    message_info["ERROR"]="$RED [ERROR]"
    message_info["INFO"]="$YELLOW [INFO]"
    message_info["SUCCESS"]="$GREEN [SUCCESS]"

    local color_label=${message_info[$message_type]}
    # Extract everything before the first space
    local color="${color_label%% *}"
    # Extract everything after the first space
    local label="${color_label#* }"

    echo -e "${color}${label} ${message}${RESET}"
}

run_command() {
    local command="$1"
    display_message "INFO" "Running command: $command"
    eval $command
    if [ $? -ne 0 ]; then
        display_message "ERROR" "Command failed: $command"
        exit 1
    fi
}

create_identities() {
    cd ../asset-transfer-basic/rest-api-go/scripts || {
        display_message "ERROR" "Failed to change directory"
        exit 1
    }

    local users=("BackendClient" "UserTest")

    for user in "${users[@]}"; do
        ./registerEnrollIdentity.sh "$user" &>/dev/null
        display_message "SUCCESS" "Registered and enrolled: $user"
    done

    cd - >/dev/null || {
        display_message "ERROR" "Failed to return to previous directory"
        exit 1
    }
}

# Bring down the network, then bring it up with certificate authority, a channel and CouchDB
run_command "./network.sh down"
run_command "./network.sh up createChannel -ca -s couchdb"

# Add Org3
run_command "cd addOrg3 && ./addOrg3.sh up -ca -s couchdb && cd .."

# Deploy the chaincode
run_command "./network.sh deployCC -ccn basic -ccp ../asset-transfer-basic/chaincode-go -ccl go"

display_message "INFO" "Creating identities..."
create_identities
