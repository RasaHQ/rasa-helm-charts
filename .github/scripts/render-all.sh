#!/usr/bin/env bash
#
# Render every CI case into <out-dir>, asserting each one's object floor.
#
# This file owns the case table. Floors were measured against rasa 3.0.0-rc.22
# and studio 3.0.0-rc.60 — the v3 charts this gate is pointed at. They are
# floors, not equalities: adding an object to a chart must not fail CI, but
# losing one must.
#
# Every case beyond `defaults` exists because the defaults render proves less
# than its object count suggests. Under defaults neither chart emits an Ingress,
# a NetworkPolicy, an HPA, a PodDisruptionBudget or a sibling ingestion
# Deployment — the templates are there, they just never run.
#
# Usage: render-all.sh <out-dir> [chart]
#        chart, when given, renders only that chart's cases.

set -euo pipefail

out_dir=$1
only_chart=${2:-}

# chart case min-objects
CASES=(
  "studio   defaults 12"
  "studio   full     19"
  "rasa     defaults 4"
  "rasa     full     13"
  "op-kits  defaults 6"
)

mkdir -p "$out_dir"

failed=()
rendered=0

for entry in "${CASES[@]}"; do
  # shellcheck disable=SC2086 # deliberate word splitting of the case table
  set -- $entry
  chart=$1
  case_name=$2
  floor=$3

  if [ -n "$only_chart" ] && [ "$chart" != "$only_chart" ]; then
    continue
  fi

  if .github/scripts/render-chart.sh "$chart" "$case_name" "$floor" \
      "${out_dir}/${chart}-${case_name}.yaml"; then
    rendered=$((rendered + 1))
  else
    failed+=("${chart}/${case_name}")
  fi
done

if [ "${#failed[@]}" -gt 0 ]; then
  echo "::error::render failed for: ${failed[*]}"
  exit 1
fi

# A filter that matches no case would otherwise leave an empty output directory
# and exit 0 — the same silent pass this whole gate exists to prevent.
if [ "$rendered" -eq 0 ]; then
  echo "::error::no cases rendered${only_chart:+ for chart ${only_chart}}. Check the case table in $0."
  exit 1
fi

echo "rendered ${rendered} case(s) into ${out_dir}"
