package ingestion

import (
	"encoding/json"
	"strings"
)

func jsonCompact(value any) string {
	if value == nil {
		return ""
	}
	bytes, err := json.Marshal(value)
	if err != nil {
		return ""
	}
	return string(bytes)
}

func normalizeJDBCPostgresDSN(jdbcURL, username, password, hostOverride string) string {
	const prefix = "jdbc:postgresql://"
	if !strings.HasPrefix(jdbcURL, prefix) {
		return ""
	}
	target := strings.TrimPrefix(jdbcURL, prefix)
	target = rewriteLocalJDBCHost(target, hostOverride)
	if strings.Contains(target, "?") {
		target += "&sslmode=disable"
	} else {
		target += "?sslmode=disable"
	}
	return "postgres://" + username + ":" + password + "@" + target
}

func rewriteLocalJDBCHost(target, hostOverride string) string {
	if hostOverride == "" {
		return target
	}
	hostPort, rest, ok := strings.Cut(target, "/")
	if !ok {
		hostPort = target
	}
	host, port, hasPort := strings.Cut(hostPort, ":")
	if host != "127.0.0.1" && host != "localhost" {
		return target
	}
	replacement := hostOverride
	if hasPort && !strings.Contains(hostOverride, ":") {
		replacement += ":" + port
	}
	if !ok {
		return replacement
	}
	return replacement + "/" + rest
}
