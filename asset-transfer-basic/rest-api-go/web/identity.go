package web

import (
	"encoding/json"
	"fmt"
	"net/http"
	"os/exec"
)

// IdentityRequest represents the structure of the JSON object containing identity request data.
type IdentityRequest struct {
	Username string `json:"username"`
}

// Register and enroll an identity.
func Identity(w http.ResponseWriter, r *http.Request) {
	fmt.Println("Received Identity request")

	// Decode the JSON object
	var identityRequest IdentityRequest
	if err := json.NewDecoder(r.Body).Decode(&identityRequest); err != nil {
		http.Error(w, "Failed to parse request body", http.StatusBadRequest)
		return
	}

	// Command to execute the shell script
	cmd := exec.Command("/bin/bash", "../../test-network/registerEnrollIdentity.sh", identityRequest.Username)

	// Run the command and capture the output
	output, err := cmd.CombinedOutput()
	if err != nil {
		fmt.Println("Error executing script:", err)
		fmt.Println("Script output:", string(output)) // Log script output
		return
	}

	// Response struct
	response := IdentityRequest{
		Username: identityRequest.Username,
	}

	// Convert response to JSON
	jsonResponse, err := json.Marshal(response)
	if err != nil {
		http.Error(w, "Failed to encode response", http.StatusInternalServerError)
		return
	}

	w.Header().Set("Content-Type", "application/json")
	w.Write(jsonResponse)
}
