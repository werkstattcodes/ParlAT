#!/usr/bin/env bash
# Manual canary check for the parlament.gv.at search index (see issue #33).
#
# Same query and threshold as skip_if_api_index_degraded() in
# tests/testthat/helper-mock.R and .github/workflows/api-index-monitor.yaml:
# a closed historical window (Jan-Mar 2024) whose healthy count is 2526.
#
# Usage: bash tools/check_api_index.sh
# Exit code: 0 if healthy, 1 if degraded or unreachable.

set -u

THRESHOLD=2400
HEALTHY_REFERENCE=2526

count=$(curl -s --max-time 60 -X POST \
  "https://www.parlament.gv.at/Filter/api/filter/data/101?js=eval&page=1&pagesize=1" \
  -H "content-type: application/json;charset=UTF-8" \
  -H "origin: https://www.parlament.gv.at" \
  --data-raw '{"DATUM_VON":["2024-01-01T00:00:00.000Z","2024-03-01T00:00:00.000Z"]}' \
  | jq -r '.count // empty')

if [ -z "${count}" ]; then
  echo "DEGRADED: API unreachable or returned no count"
  exit 1
fi

if [ "${count}" -ge "${THRESHOLD}" ]; then
  echo "HEALTHY: canary count ${count} (reference ${HEALTHY_REFERENCE}, threshold ${THRESHOLD})"
  echo "The index has recovered - live tests will run again; issue #33 can be closed after the next green run."
  exit 0
else
  echo "DEGRADED: canary count ${count} (reference ${HEALTHY_REFERENCE}, threshold ${THRESHOLD})"
  echo "Live count-sensitive tests will keep skipping via skip_if_api_index_degraded()."
  exit 1
fi
