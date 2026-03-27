#!/bin/bash
# run-audit-loop.sh — Runs audit + fix cycle every 2 hours overnight
# Usage: ./run-audit-loop.sh
# Stop: Ctrl+C or kill the process
#
# This script runs in auto mode so Claude can both find AND fix issues.
# Each cycle: audit → fix → commit fixes → wait 2 hours → repeat

set -uo pipefail

INTERVAL_SECONDS=7200  # 2 hours
PROJECT_DIR="$(cd "$(dirname "$0")" && pwd)"

cd "$PROJECT_DIR"

echo "============================================"
echo " Unit Overnight Audit Loop"
echo " Interval: every $((INTERVAL_SECONDS / 3600)) hours"
echo " Started:  $(date)"
echo " Project:  $PROJECT_DIR"
echo " Press Ctrl+C to stop"
echo "============================================"
echo ""

CYCLE=1

while true; do
  TIMESTAMP="$(date +%Y-%m-%d_%H%M)"
  REPORT="audit-report-${TIMESTAMP}.md"

  echo "──────────────────────────────────────────"
  echo "Cycle $CYCLE — Starting at $(date)"
  echo "Report: $REPORT"
  echo "──────────────────────────────────────────"

  # Build the prompt with the report filename injected
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

  # Run the audit in auto mode with up to 3 retries on failure
  MAX_RETRIES=3
  ATTEMPT=1
  EXIT_CODE=1

  while [ $ATTEMPT -le $MAX_RETRIES ] && [ $EXIT_CODE -ne 0 ]; do
    if [ $ATTEMPT -gt 1 ]; then
      echo "  Retry $ATTEMPT/$MAX_RETRIES after 60s cooldown..."
      sleep 60
    fi

    claude --dangerously-skip-permissions -p "$AUDIT_PROMPT" > "$REPORT" 2>&1
    EXIT_CODE=$?
    ATTEMPT=$((ATTEMPT + 1))
  done

  if [ $EXIT_CODE -eq 0 ]; then
    echo "✓ Cycle $CYCLE completed successfully at $(date)"
  else
    echo "✗ Cycle $CYCLE failed after $MAX_RETRIES attempts (exit $EXIT_CODE) at $(date)"
  fi

  echo "  Report: $REPORT"
  echo ""

  CYCLE=$((CYCLE + 1))

  echo "Sleeping $((INTERVAL_SECONDS / 3600)) hours until next cycle..."
  echo "Next run: $(date -v+${INTERVAL_SECONDS}S 2>/dev/null || date -d "+${INTERVAL_SECONDS} seconds" 2>/dev/null || echo "in $((INTERVAL_SECONDS / 3600)) hours")"
  echo ""

  sleep $INTERVAL_SECONDS
done
