#!/usr/bin/env bash
#
# Assert a rendered manifest satisfies the restricted Pod Security Standard.
#
# `kyverno apply` exits 1 on a policy violation, which is the easy half. The
# hard half is that it also exits 0 when it validated nothing at all:
#
#   - an unparsable policy file      -> 0 rules applied, exit 0
#   - an unsupported policy field    -> 0 rules applied, exit 0, no warning
#   - a manifest with no pod-shaped  -> 0 passes, exit 0
#     objects (op-kits renders only CRs)
#
# So this checks three things, not one: the exit code, that the policy
# contributed rules, and that those rules actually evaluated something.
#
# Usage: pod-security-scan.sh <rendered-manifest>

# No `-e`: the kyverno exit code is load-bearing and must be captured.
set -uo pipefail

manifest=$1
policy=".github/policies/restricted-pss.yaml"

if [ ! -s "$manifest" ]; then
  echo "::error::${manifest} is missing or empty — nothing to scan."
  exit 1
fi

output=$(kyverno apply "$policy" --resource "$manifest" 2>&1)
status=$?
echo "$output"

# "Applying 3 policy rule(s) to 12 resource(s)..." — autogen expands the single
# authored rule into pod-controller variants, so this is 3 and not 1.
rules=$(grep -oE 'Applying [0-9]+ policy rule' <<<"$output" | grep -oE '[0-9]+' | head -1)
passes=$(grep -oE 'pass: [0-9]+' <<<"$output" | grep -oE '[0-9]+' | head -1)
failures=$(grep -oE 'fail: [0-9]+' <<<"$output" | grep -oE '[0-9]+' | head -1)

if [ -z "$rules" ] || [ "$rules" -eq 0 ]; then
  echo "::error::Kyverno applied 0 policy rules. The policy was dropped, not satisfied."
  echo "::error::Check ${policy} parses and that every field it uses is supported by this CLI version."
  exit 1
fi

# Evaluated, not passed. Checking the pass count alone misreports a manifest
# whose pods ALL violate the standard: that is pass: 0, fail: n, which is a real
# finding and must not be described as "evaluated nothing".
evaluated=$(( ${passes:-0} + ${failures:-0} ))
if [ "$evaluated" -eq 0 ]; then
  echo "::error::Kyverno evaluated 0 pods in ${manifest}. A green result here means nothing."
  echo "::error::Either the render emitted no pod-shaped objects, or the match block no longer matches them."
  exit 1
fi

if [ "$status" -ne 0 ]; then
  echo "::error::${manifest} violates the restricted Pod Security Standard — see the failures above."
  exit "$status"
fi

echo "${manifest}: ${rules} rules applied, ${passes} pods passed the restricted Pod Security Standard."
