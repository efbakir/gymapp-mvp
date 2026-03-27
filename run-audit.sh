#!/bin/bash
# run-audit.sh — Overnight autonomous app audit
# Usage: ./run-audit.sh

set -euo pipefail

TIMESTAMP="$(date +%Y-%m-%d_%H%M)"
REPORT="audit-report-${TIMESTAMP}.md"

echo "Starting Unit overnight audit at $(date)"
echo "Report will be written to: ${REPORT}"

claude -p \
  --output-format text \
  --allowedTools "Bash(xcodebuild *),Bash(xcrun simctl *),Bash(find *),Bash(rg *),Bash(ls *),Bash(mkdir *),Bash(plutil *),Bash(/usr/libexec/PlistBuddy *),View,Read" \
  "$(cat audit-prompt.md)" \
  > "${REPORT}" 2>&1

echo "Audit complete at $(date). Report: ${REPORT}"

