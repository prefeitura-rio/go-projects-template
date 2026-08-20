package mylibrary_test

import (
	"testing"

	"github.com/prefeitura-rio/go-library-template"
)

// The test lives in an external test package (package mylibrary_test) so it
// exercises only the exported API, exactly like a real consumer would.
func TestAdd(t *testing.T) {
	if got := mylibrary.Add(2, 3); got != 5 {
		t.Errorf("Add(2, 3) = %d, want 5", got)
	}
}