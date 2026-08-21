// Package cli implements the mycli command.
package cli

import (
	"flag"
	"fmt"
	"io"
)

// Run executes the CLI with the given arguments.
func Run(args []string, out io.Writer) error {
	fs := flag.NewFlagSet("mycli", flag.ContinueOnError)
	fs.SetOutput(out)

	name := fs.String("name", "world", "name to greet")

	if err := fs.Parse(args); err != nil {
		return err
	}

	fmt.Fprintf(out, "hello, %s!\n", *name)
	return nil
}
