#!/usr/bin/env bash
# Spell-Explore — scaffold a project folder from the protocol.
# usage: scripts/init-project.sh [target-dir]   (default: the current directory)
# runnable from Git Bash, from any cwd: SRC is computed from the script's own
# location (dirname of $0/..). refuses a target that is already scaffolded;
# never overwrites an existing file (cp -n); the config merge appends only the
# missing keys and never overwrites a present value.
set -euo pipefail

# --- locate the protocol root from the script's own position ------------------
SRC="$(cd "$(dirname "$0")/.." && pwd)"

# --- resolve the target --------------------------------------------------------
TARGET="${1:-$(pwd)}"
if [ ! -d "$TARGET" ]; then
  mkdir -p "$TARGET"
fi
TARGET="$(cd "$TARGET" && pwd)"

# --- (a) refuse an already-scaffolded target ----------------------------------
if [ -e "$TARGET/goal.md" ]; then
  echo "error: $TARGET/goal.md already exists — the project is already scaffolded. refusing." >&2
  exit 1
fi
if [ -e "$TARGET/protocol/goal.md" ]; then
  echo "error: $TARGET is the protocol source itself — scaffold a fresh project directory instead. refusing." >&2
  exit 1
fi

# --- (b) the directory skeleton ------------------------------------------------
mkdir -p \
  "$TARGET/.kimi-code/agents" \
  "$TARGET/dossier/idea-pool/fresh-summaries" \
  "$TARGET/dossier/idea-pool/reliable-idea-set" \
  "$TARGET/dossier/idea-pool/fragment-region" \
  "$TARGET/question-routes" \
  "$TARGET/reports" \
  "$TARGET/routes" \
  "$TARGET/stale" \
  "$TARGET/formalizer/lean" \
  "$TARGET/formalizer/fragments" \
  "$TARGET/formalizer/Integrator" \
  "$TARGET/runtime" \
  "$TARGET/runtime/requests" \
  "$TARGET/runtime/briefs"

# --- (c) copy the protocol files (cp -n: never overwrite) ----------------------
cp -n "$SRC/references/protocol/.kimi-code/agents/"*.md "$TARGET/.kimi-code/agents/"
cp -n "$SRC/references/protocol/dossier/"*.md "$TARGET/dossier/"
cp -n "$SRC/references/protocol/dossier/idea-pool/README.md" "$TARGET/dossier/idea-pool/README.md"
# both protocol question-routes.md files share the name; cp -n keeps the first
# (the living-map template from protocol/question-routes/) and skips the second.
cp -n "$SRC/references/protocol/question-routes/question-routes.md" "$TARGET/question-routes/"
cp -n "$SRC/references/protocol/templates/question-routes.md" "$TARGET/question-routes/"
cp -n "$SRC/references/protocol/reports/README.md" "$TARGET/reports/"
cp -n "$SRC/references/protocol/routes/README.md" "$TARGET/routes/"
cp -n "$SRC/references/protocol/stale/README.md" "$TARGET/stale/"
cp -n "$SRC/references/protocol/goal.md" "$TARGET/goal.md"
cp -n "$SRC/references/protocol/formalizer/lean/README.md" "$TARGET/formalizer/lean/"

# --- (d) the placeholders (created only if missing) -----------------------------
[ -e "$TARGET/formalizer/single.qmd" ] || \
  printf '%s\n' '# single qmd — the one qmd file of the project' > "$TARGET/formalizer/single.qmd"
[ -e "$TARGET/formalizer/qmd-index.md" ] || \
  printf '%s\n' '# qmd index — ids of existing lemmas / definitions / theorems in single.qmd' \
    '' \
    '| id | kind | location in single.qmd | status |' \
    '|---|---|---|---|' > "$TARGET/formalizer/qmd-index.md"
# dependency-graph.json is retired as the workflow source — visualization-only; the graph lives in formalizer/Integrator/ITG.lean + integration-report.md
[ -e "$TARGET/formalizer/dependency-graph.json" ] || \
  printf '%s\n' '{"nodes":[],"edges":[],"goal_node":null,"version":"v0"}' > "$TARGET/formalizer/dependency-graph.json"
[ -e "$TARGET/runtime/README.md" ] || cat > "$TARGET/runtime/README.md" <<'EOF'
# runtime — resume packs

this directory holds the resume packs: a versioned state file per long-lived
role — the five subcoordinators, the PIs, and the lean code runner — at
runtime/<role>-state.md, recording its current stage, its spawned workers with
their output paths, and the file pointers it needs to continue. background
tasks do not survive a process restart, so after a restart the Coordinator
re-spawns the role fresh and hands it the resume pack instead of resuming it
by ID. resume packs are versioned like every artifact (see
protocol/rules/worker-lifespans.md).
EOF
[ -e "$TARGET/runtime/worker-registry.md" ] || cat > "$TARGET/runtime/worker-registry.md" <<'EOF'
# worker registry — request → task-ids → labels → output paths

maintained by the Coordinator: every spawn request it services (runtime/requests/) is
recorded here with the task-ids it spawned, so a session resume restores each
territory's live workers (see protocol/rules/worker-lifespans.md).
EOF

# --- merge helpers (append only the missing keys, never overwrite) ---------------
merge_subagent_timeout() {
  if grep -q '^[[:space:]]*timeout_ms[[:space:]]*=' "$CONFIG"; then
    echo "  subagent.timeout_ms already present — left as-is (never overwrite)"
    return
  fi
  local sec
  sec="$(grep -n '^\[subagent\]$' "$CONFIG" | head -n1 | cut -d: -f1)"
  if [ -n "$sec" ]; then
    sed -i "${sec}a\\timeout_ms = 0    # the subcoordinators, the PIs, and the lean code runner are resumable — no timeout applies to them" "$CONFIG"
    echo "  added timeout_ms = 0 to the existing [subagent] section"
  else
    printf '\n[subagent]\ntimeout_ms = 0    # the subcoordinators, the PIs, and the lean code runner are resumable — no timeout applies to them\n' >> "$CONFIG"
    echo "  added a new [subagent] section with timeout_ms = 0"
  fi
}

merge_secondary_model() {
  local sec
  sec="$(grep -n '^\[secondary_model\]$' "$CONFIG" | head -n1 | cut -d: -f1)"
  if [ -z "$sec" ]; then
    printf '\n[secondary_model]\nmodel = "moonshot-cn/kimi-k2.6"    # the worker tier (idea, report, swarm, decompose, workerA) runs on the secondary model\n' >> "$CONFIG"
    echo "  added a new [secondary_model] section with model = \"moonshot-cn/kimi-k2.6\""
    return
  fi
  if awk -v s="$sec" 'NR>=s { if (/^\[/ && !/^\[secondary_model\]$/) exit; if (/^[[:space:]]*model[[:space:]]*=/) { f=1; exit } } END { exit !f }' "$CONFIG"; then
    echo "  secondary_model.model already present — left as-is (never overwrite)"
  else
    sed -i "${sec}a\\model = \"moonshot-cn/kimi-k2.6\"    # the worker tier (idea, report, swarm, decompose, workerA) runs on the secondary model" "$CONFIG"
    echo "  added model = \"moonshot-cn/kimi-k2.6\" to the existing [secondary_model] section"
  fi
}

validate_config() {
  local py=""
  if command -v python3 >/dev/null 2>&1; then
    py=python3
  elif command -v python >/dev/null 2>&1; then
    py=python
  fi
  if [ -n "$py" ]; then
    if "$py" -c "import tomllib,sys; tomllib.load(open(sys.argv[1],'rb'))" "$CONFIG" 2>/dev/null; then
      echo "  $CONFIG parses clean (python tomllib)"
    else
      echo "  warning: $CONFIG does not parse after the merge — fix it before starting kimi" >&2
    fi
  fi
}

# --- (e) the config block + optional merge ---------------------------------------
CONFIG="$HOME/.kimi-code/config.toml"
echo
echo "merge into $CONFIG (append only the missing keys, never overwrite):"
cat <<'EOF'

[subagent]
timeout_ms = 0    # the subcoordinators, the PIs, and the lean code runner are resumable — no timeout applies to them

[secondary_model]
model = "moonshot-cn/kimi-k2.6"    # the worker tier (idea, report, swarm, decompose, workerA) runs on the secondary model
EOF
echo
read -r -p "append the missing keys to $CONFIG? [y/N] " ans || ans=n
case "$ans" in
  y|Y|yes|YES)
    if [ ! -f "$CONFIG" ]; then
      echo "error: $CONFIG does not exist — start kimi once to create it, then re-run this script." >&2
    else
      merge_subagent_timeout
      merge_secondary_model
      validate_config
    fi
    ;;
  *) echo "skipped — merge the block above manually if you want it." ;;
esac

# --- (f) the checklist -----------------------------------------------------------
echo
echo "scaffolded $TARGET. next:"
echo "  1. export KIMI_CODE_EXPERIMENTAL_SECONDARY_MODEL=1"
echo "  2. verify lean --version (the lean code runner needs a working lean toolchain)"
echo "  3. run kimi in $TARGET and confirm the five subcoordinator profiles and every worker profile resolve: creator, producer, selector, formalizer, integrator, integrator-worker-1, integrator-worker-2, idea-worker, graph-worker, report-worker, route-worker, examine-worker, worker-a, reviewer-bcd, worker-d-external, promoter, swarm-worker, decompose-worker, lean-code-runner, lean-swarm-worker, pi"
