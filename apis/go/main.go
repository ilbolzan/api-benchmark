package main

import (
	"fmt"
	"net/http"
)

func helloHandler(w http.ResponseWriter, r *http.Request) {
	fmt.Fprintf(w, "Hello Go")
}

func main() {
	http.HandleFunc("/api/hello", helloHandler)
	http.ListenAndServe(":8080", nil)
} 