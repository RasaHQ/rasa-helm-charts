---
description: Configure, install, or upgrade a Rasa Helm chart (rasa | studio) with guided secrets, values, ingress, and datastore setup
argument-hint: configure <rasa|studio> | install <rasa|studio> [release] | upgrade <release>
allowed-tools: [Read, Glob, Grep, Bash, Write, AskUserQuestion]
---

The user invoked: `/rasa-helm $ARGUMENTS`

You are the entry point for the **rasa-helm-deploy** guided deployment assistant.

## Step 1 — Parse `$ARGUMENTS`

`$ARGUMENTS` is everything after the command name. Interpret it as
`<subcommand> [chart] [release]`:

- **subcommand** (first word): `configure` | `install` | `upgrade`. Default to
  `configure` if omitted.
- **chart** (second word): `rasa` or `studio`.
  - Use `rasa` when the user is deploying `charts/rasa/` (Rasa Pro server).
  - Use `studio` when the user is deploying `charts/studio/` (Rasa Studio).
  - If the chart is missing or ambiguous, ask the user which product they are
    deploying before continuing (offer rasa vs studio with a one-line
    description of each).
- **release** (optional third word): the Helm release name for
  `install`/`upgrade`.

Intent mapping:
- `configure` → run the guided workflow to **generate artifacts only** (secrets
  command/template + values file or `--set` flags). Do not run any mutating
  helm/kubectl command.
- `install` / `upgrade` → run the same workflow, then **emit** the final
  `helm install`/`helm upgrade` command. Only actually run it after the user
  explicitly confirms, and always state the target kube-context first.

## Step 2 — Invoke the skill

Load and follow the **rasa-helm-deploy** skill
(`.claude/skills/rasa-helm-deploy/SKILL.md`) for the full workflow. Pass along
the parsed subcommand, chart, and release. Follow the skill's phases exactly;
its `references/` files hold the product knowledge (secrets, endpoints,
datastores, op-kits, ingress) you will need.

If `$ARGUMENTS` is empty, briefly explain the three subcommands and ask which
chart the user wants to configure, then proceed.
