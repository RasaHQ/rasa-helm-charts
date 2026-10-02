#!/usr/bin/env bash
#
# Require a Chart.yaml version bump from any push that changes a chart.
#
# WHY THIS IS NOT ALREADY COVERED BY ct
#
# ct.yaml sets `target-branch: main` alongside `check-version-increment: true`,
# so ct compares a changed chart against main -- not against the previous commit
# on the current branch. On a long-lived release/* branch that means: once the
# version is ahead of main, every subsequent commit passes the gate without a
# bump. That is the mechanism behind the studio 3.0.0-rc.37 overwrite, where two
# different trees were published under one version.
#
# This runs on push, not on pull_request, because the gap is per-push. A PR-time
# check cannot see the intermediate commits that each republished the same
# version.
#
# Usage: check-chart-version-bump.sh <before-sha> <after-sha>

set -euo pipefail

before=$1
after=$2

# A branch-creation push reports an all-zero before SHA; there is no previous
# state to compare against.
if [[ "$before" =~ ^0+$ ]]; then
  echo "::notice::Branch was just created — no previous commit to compare against."
  exit 0
fi

# A force-push can leave a before SHA that is no longer reachable.
if ! git cat-file -e "${before}^{commit}" 2>/dev/null; then
  echo "::notice::Before SHA ${before} is not in this history (force push?) — skipping."
  exit 0
fi

# Reads the version straight out of Chart.yaml at a given revision. Deliberately
# sed and not yq: yq is not guaranteed to be on the runner, and `version` is a
# flat top-level scalar.
chart_version() {
  git show "${1}:charts/${2}/Chart.yaml" 2>/dev/null \
    | sed -n 's/^version:[[:space:]]*//p' | head -1 | tr -d '"'
}

changed_charts=$(
  git diff --name-only "$before" "$after" -- 'charts/*' \
    | cut -d/ -f2 | sort -u
)

if [ -z "$changed_charts" ]; then
  echo "No chart directory changed between ${before} and ${after}."
  exit 0
fi

failed=()
for chart in $changed_charts; do
  old_version=$(chart_version "$before" "$chart")
  new_version=$(chart_version "$after" "$chart")

  if [ -z "$new_version" ]; then
    echo "${chart}: no Chart.yaml at ${after} — chart removed, nothing to check."
    continue
  fi

  if [ -z "$old_version" ]; then
    echo "${chart}: new chart at version ${new_version} — nothing to compare."
    continue
  fi

  if [ "$old_version" = "$new_version" ]; then
    echo "${chart}: still ${new_version}"
    failed+=("${chart} (${new_version})")
  else
    echo "${chart}: ${old_version} -> ${new_version}"
  fi
done

if [ "${#failed[@]}" -gt 0 ]; then
  echo "::error::Chart changed without a version bump: ${failed[*]}"
  echo "::error::Publishing this push would overwrite an already-released version with different content."
  echo "::error::Increment version in charts/<chart>/Chart.yaml — on a release/* branch that means the next -rc.X."
  exit 1
fi
