#!/usr/bin/env bash
#
# Render one chart for one named CI case, and assert the render actually
# produced objects.
#
# The floor is the point of this script. Four tools in this pipeline exit 0 on
# input they did not validate:
#
#   helm lint       template `fail` action    -> reports level=INFO, exits 0
#   kube-linter     empty / zero-object file  -> exits 0, prints nothing
#   kyverno apply   unparsable policy         -> exits 0, applies 0 rules
#   kyverno apply   unsupported policy field  -> exits 0, applies 0 rules, silent
#
# So a gate that checks only $? reproduces the class of bug it is meant to
# catch. Every render here is followed by a floor on the object count.
#
# Usage: render-chart.sh <chart> <case> <min-objects> <out-file>

set -euo pipefail

chart=$1
case_name=$2
min_objects=$3
out=$4

chart_dir="charts/${chart}"
if [ ! -d "$chart_dir" ]; then
  echo "::error::no such chart directory: ${chart_dir}"
  exit 1
fi

# A scalar rather than an array of flags: there is only ever one values file per
# case, and an empty array tripped `set -u` on bash 3.2.
values_file=""
case "$case_name" in
  defaults)
    # charts/studio has no default database host — the chart is not installable
    # without one, so a bare render fails schema validation. Each chart may ship
    # its own minimum file to make the defaults case renderable.
    if [ -f "${chart_dir}/ci/lint-values.yaml" ]; then
      values_file="${chart_dir}/ci/lint-values.yaml"
    fi
    ;;
  *)
    values_file=".github/ci-values/${chart}-${case_name}.yaml"
    if [ ! -f "$values_file" ]; then
      echo "::error::no values file for case '${case_name}': ${values_file}"
      exit 1
    fi
    ;;
esac

# Required for charts with subcharts: without it the subchart's objects are
# silently absent from the render.
helm dependency build "$chart_dir" >/dev/null

if [ -n "$values_file" ]; then
  helm template "$chart" "$chart_dir" -f "$values_file" > "$out"
else
  helm template "$chart" "$chart_dir" > "$out"
fi

objects=$(grep -c '^kind:' "$out" || true)
echo "${chart} [${case_name}]: ${objects} objects rendered (floor ${min_objects})"

if [ "$objects" -lt "$min_objects" ]; then
  echo "::error::${chart} [${case_name}] rendered ${objects} objects, expected at least ${min_objects}."
  echo "::error::Either a template stopped emitting an object, or this floor needs updating alongside the chart change."
  exit 1
fi
