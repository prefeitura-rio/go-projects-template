package cli_test

import (
	"bytes"
	"strings"
	"testing"

	"github.com/prefeitura-rio/go-cli-template/internal/cli"
)

func TestRun_PrintsGreeting(t *testing.T) {
	var out bytes.Buffer

	if err := cli.Run([]string{"-name", "vitor"}, &out); err != nil {
		t.Fatalf("Run returned error: %v", err)
	}

	if got := out.String(); !strings.Contains(got, "hello, vitor!") {
		t.Errorf("output %q does not contain greeting", got)
	}
}

func TestRun_UsesDefaultName(t *testing.T) {
	var out bytes.Buffer

	if err := cli.Run(nil, &out); err != nil {
		t.Fatalf("Run returned error: %v", err)
	}

	if got := out.String(); !strings.Contains(got, "hello, world!") {
		t.Errorf("output %q does not contain default greeting", got)
	}
}
