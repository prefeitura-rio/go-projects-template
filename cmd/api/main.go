// Command api starts the HTTP API server.
package main

import (
	"fmt"
	"log"
	"net/http"
	"os"

	"github.com/prefeitura-rio/go-projects-template/internal/http/handler"
)

func main() {
	port := os.Getenv("PORT")
	if port == "" {
		port = "8080"
	}

	mux := http.NewServeMux()
	mux.HandleFunc("/health", handler.Health())

	addr := fmt.Sprintf(":%s", port)
	log.Printf("server starting on %s", addr)

	if err := http.ListenAndServe(addr, mux); err != nil {
		log.Fatalf("server error: %v", err)
	}
}
