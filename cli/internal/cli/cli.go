// Package cli implements the mycli command.
//
// The command logic lives in internal/cli so it can be tested without
// spawning a subprocess: Run receives its arguments and output writer as
// parameters instead of reading os.Args and writing to os.Stdout directly.
package cli

import (
	"flag"
	"fmt"
	"io"
)

// Run executes the CLI with the given arguments, writing its output to out.
// It returns an error that main turns into a non-zero exit status.
//
// Run is the single testable entry point of the command. The caller (main)
// owns process-level concerns: os.Args, os.Stdout, os.Exit.
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