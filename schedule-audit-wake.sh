#!/bin/bash
# schedule-audit-wake.sh — Schedule a macOS wake event for tonight's audit window
# Run this once each evening (or add to your routine) to ensure the Mac wakes up.
# Requires sudo. Usage: sudo ./schedule-audit-wake.sh
#
# Sets a wake event for 10:25 PM tonight so the launchd audit job at 10:30 PM fires.
# The caffeinate in run-audit-auto.sh keeps the Mac awake during each audit run.
# Between runs, the Mac may sleep again — StartCalendarInterval will fire on next wake.

set -euo pipefail

# Calculate tonight at 22:25
TONIGHT=$(date -v22H -v25M -v0S "+%m/%d/%Y %H:%M:%S")

echo "Scheduling wake for: $TONIGHT"
sudo pmset schedule wake "$TONIGHT"
echo "Done. Verify with: pmset -g sched"
