#!/bin/bash
# run-audit-auto.sh — Overnight audit+fix with auto mode
# Runs only between 10 PM and 10 AM. Exits silently outside that window.
# Called by launchd every 2 hours.

set -uo pipefail

cd "$(dirname "$0")"

HOUR=$(date +%H)
# Run only between 22:00–09:59 (10 PM to 10 AM)
if [ "$HOUR" -ge 10 ] && [ "$HOUR" -lt 22 ]; then
  echo "$(date): Skipping — outside overnight window (10 PM – 10 AM)"
  exit 0
fi

TIMESTAMP="$(date +%Y-%m-%d_%H%M)"
REPORT="audit-report-${TIMESTAMP}.md"

echo "$(date): Starting audit cycle — report: $REPORT"

AUDIT_PROMPT="You are running an automated overnight audit+fix cycle for the Unit iOS app.

## Phase 1: Audit
Follow the full audit process in audit-prompt.md (read it first).

## Phase 2: Fix
After completing the audit, fix every issue you found:
- Fix all design system violations (raw colors -> AppColor.*, raw fonts -> AppFont.*, etc.)
- Fix compass alignment issues (remove banned UI patterns)
- Fix edge case bugs
- Do NOT change app architecture or add new features — only fix violations and bugs

## Phase 3: Report
Write the audit report to ${REPORT}.

## Phase 4: Commit
After fixing, stage all changed .swift files and commit with message:
  Auto-audit fixes — ${TIMESTAMP}
  followed by a 2-3 line summary of what was fixed.
  End with: Co-Authored-By: Claude Opus 4.6 <noreply@anthropic.com>

Do NOT push to remote. Only commit locally."

# Retry up to 3 times on API errors
MAX_RETRIES=3
ATTEMPT=1
EXIT_CODE=1

while [ $ATTEMPT -le $MAX_RETRIES ] && [ $EXIT_CODE -ne 0 ]; do
  if [ $ATTEMPT -gt 1 ]; then
    echo "  Retry $ATTEMPT/$MAX_RETRIES after 60s cooldown..."
    sleep 60
  fi

  caffeinate -i claude --dangerously-skip-permissions -p "$AUDIT_PROMPT" > "$REPORT" 2>&1
  EXIT_CODE=$?
  ATTEMPT=$((ATTEMPT + 1))
done

if [ $EXIT_CODE -eq 0 ]; then
  echo "$(date): Audit cycle completed successfully — $REPORT"
else
  echo "$(date): Audit cycle failed after $MAX_RETRIES attempts (exit $EXIT_CODE)"
fi

exit $EXIT_CODE
