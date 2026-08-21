package main

import (
	"fmt"
	"os"

	"github.com/prefeitura-rio/go-cli-template/internal/cli"
)

func main() {
	if err := cli.Run(os.Args[1:], os.Stdout); err != nil {
		fmt.Fprintln(os.Stderr, err)
		os.Exit(1)
	}
}
