package web

import (
	"encoding/json"
	"fmt"
	"net/http"

	"github.com/hyperledger/fabric-gateway/pkg/client"
)

// InvokeRequest representa a estrutura do objeto JSON que contém os dados da requisição de invocação.
type InvokeRequest struct {
	ChaincodeID string   `json:"chaincodeid"`
	ChannelID   string   `json:"channelid"`
	Function    string   `json:"function"`
	Args        []string `json:"args"`
}

// InvokeResponse representa a estrutura do objeto JSON que será retornado na resposta.
type InvokeResponse struct {
	TransactionID string `json:"transaction_id"`
	Result        string `json:"result"`
}

// Invoke handles chaincode invoke requests.
func (setup *OrgSetup) Invoke(w http.ResponseWriter, r *http.Request) {
	fmt.Println("Received Invoke request")

	// Decodificar o objeto JSON
	var invokeReq InvokeRequest
	if err := json.NewDecoder(r.Body).Decode(&invokeReq); err != nil {
		http.Error(w, "Failed to parse request body", http.StatusBadRequest)
		return
	}

	fmt.Printf("channel: %s, chaincode: %s, function: %s, args: %s\n", invokeReq.ChannelID, invokeReq.ChaincodeID, invokeReq.Function, invokeReq.Args)

	network := setup.Gateway.GetNetwork(invokeReq.ChannelID)
	contract := network.GetContract(invokeReq.ChaincodeID)
	txnProposal, err := contract.NewProposal(invokeReq.Function, client.WithArguments(invokeReq.Args...))
	if err != nil {
		http.Error(w, fmt.Sprintf("Error creating txn proposal: %s", err), http.StatusInternalServerError)
		return
	}
	txnEndorsed, err := txnProposal.Endorse()
	if err != nil {
		http.Error(w, fmt.Sprintf("Error endorsing txn: %s", err), http.StatusInternalServerError)
		return
	}
	txnCommitted, err := txnEndorsed.Submit()
	if err != nil {
		http.Error(w, fmt.Sprintf("Error submitting transaction: %s", err), http.StatusInternalServerError)
		return
	}

	// Response struct
	response := InvokeResponse{
		TransactionID: txnCommitted.TransactionID(),
		Result:        string(txnEndorsed.Result()), // Convertendo o slice de bytes para string
	}

	// parse to JSON
	jsonResponse, err := json.Marshal(response)
	if err != nil {
		http.Error(w, "Failed to encode response", http.StatusInternalServerError)
		return
	}

	w.Header().Set("Content-Type", "application/json")
	w.Write(jsonResponse)
}
