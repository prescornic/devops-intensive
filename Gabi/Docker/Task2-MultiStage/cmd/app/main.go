package main

import (
	"encoding/json"
	"log"
	"net/http"
	"os"
	"runtime"
	"time"
)

type HealthResponse struct {
	Status    string `json:"status"`
	Timestamp string `json:"timestamp"`
}

type InfoResponse struct {
	Hostname    string `json:"hostname"`
	Platform    string `json:"platform"`
	GoVersion   string `json:"go_version"`
	Environment string `json:"environment"`
}

func main() {
	port := getEnv("APP_PORT", "8080")

	http.HandleFunc("/", func(w http.ResponseWriter, r *http.Request) {
		w.WriteHeader(http.StatusOK)
		_, _ = w.Write([]byte("Hello from Multi-Stage Docker!"))
	})

	http.HandleFunc("/health", func(w http.ResponseWriter, r *http.Request) {
		w.Header().Set("Content-Type", "application/json")
		response := HealthResponse{
			Status:    "healthy",
			Timestamp: time.Now().UTC().Format(time.RFC3339),
		}
		_ = json.NewEncoder(w).Encode(response)
	})

	http.HandleFunc("/info", func(w http.ResponseWriter, r *http.Request) {
		hostname, _ := os.Hostname()
		w.Header().Set("Content-Type", "application/json")
		response := InfoResponse{
			Hostname:    hostname,
			Platform:    runtime.GOOS + "/" + runtime.GOARCH,
			GoVersion:   runtime.Version(),
			Environment: getEnv("APP_ENV", "production"),
		}
		_ = json.NewEncoder(w).Encode(response)
	})

	log.Printf("Starting server on port %s", port)
	log.Fatal(http.ListenAndServe(":"+port, nil))
}

func getEnv(key, fallback string) string {
	value := os.Getenv(key)
	if value == "" {
		return fallback
	}
	return value
}