// Command mycli is the entry point for the CLI. It keeps process-level
// concerns (os.Args, os.Stdout, exit codes) here and delegates all logic to
// internal/cli.
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