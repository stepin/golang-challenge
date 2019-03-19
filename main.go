package main

import (
	"flag"
	"fmt"
	"log"
	"net/http"
	"strconv"
)

func main() {
	port := flag.Int("port", 8080, "HTTP port")

	http.HandleFunc("/", handler)

	addr := ":" + strconv.Itoa(*port)
	log.Printf("Server started on %s...", addr)
	log.Fatal(http.ListenAndServe(addr, nil))
}

func handler(w http.ResponseWriter, r *http.Request) {
	fmt.Fprintf(w, "TODO")
}
