// Package version exposes build-time version information.
//
// Version, Commit and BuildDate are injected at build time via ldflags, for
// example:
//
//	go build -ldflags "\
//	  -X github.com/prefeitura-rio/go-projects-template/internal/version.Version=1.0.0 \
//	  -X github.com/prefeitura-rio/go-projects-template/internal/version.Commit=$(git rev-parse HEAD) \
//	  -X github.com/prefeitura-rio/go-projects-template/internal/version.BuildDate=$(date -u +%Y-%m-%dT%H:%M:%SZ)" \
//	  ./cmd/api
package version

import (
	"fmt"
	"runtime"
)

var (
	// Version is the semantic version of the application (ldflags-injected).
	Version = "dev"
	// Commit is the git commit the binary was built from (ldflags-injected).
	Commit = "unknown"
	// BuildDate is the UTC timestamp of the build (ldflags-injected).
	BuildDate = "unknown"
	// GoVersion is the Go toolchain the binary was built with.
	GoVersion = runtime.Version()
	// Platform is the GOOS/GOARCH the binary was built for.
	Platform = fmt.Sprintf("%s/%s", runtime.GOOS, runtime.GOARCH)
)

// Info holds the complete build information, ready for JSON serialization.
type Info struct {
	Version   string `json:"version"`
	Commit    string `json:"commit"`
	BuildDate string `json:"build_date"`
	GoVersion string `json:"go_version"`
	Platform  string `json:"platform"`
}

// GetInfo returns the build information, suitable for logging or for exposing
// through an endpoint.
func GetInfo() Info {
	return Info{
		Version:   Version,
		Commit:    Commit,
		BuildDate: BuildDate,
		GoVersion: GoVersion,
		Platform:  Platform,
	}
}

// String returns a compact one-line version description.
func String() string {
	return fmt.Sprintf("%s (%s)", Version, Commit)
}
