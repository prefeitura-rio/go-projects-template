// Package version exposes build-time version information.
package version

import (
	"fmt"
	"runtime"
)

var (
	// Version is the semantic application version.
	Version = "dev"
	// Commit is the source commit.
	Commit = "unknown"
	// BuildDate is the build timestamp.
	BuildDate = "unknown"
	// GoVersion is the Go toolchain version.
	GoVersion = runtime.Version()
	// Platform is the target platform.
	Platform = fmt.Sprintf("%s/%s", runtime.GOOS, runtime.GOARCH)
)

// Info holds build information.
type Info struct {
	Version   string `json:"version"`
	Commit    string `json:"commit"`
	BuildDate string `json:"build_date"`
	GoVersion string `json:"go_version"`
	Platform  string `json:"platform"`
}

// GetInfo returns build information.
func GetInfo() Info {
	return Info{
		Version:   Version,
		Commit:    Commit,
		BuildDate: BuildDate,
		GoVersion: GoVersion,
		Platform:  Platform,
	}
}

// String returns a compact version description.
func String() string {
	return fmt.Sprintf("%s (%s)", Version, Commit)
}
