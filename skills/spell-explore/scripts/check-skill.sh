#!/usr/bin/env bash
# Spell-Explore — protocol-integrity check (read-only): compares the canonical
# spell-explore skill in the source repository — the local clone of the GitHub
# repo the user maintains — against the user-scope installed copy
# (~/.kimi-code/skills/spell-explore) that Kimi Code discovers and the
# Coordinator operates from. never writes; aligning is the repository's
# scripts/sync-skill.sh job. exits 0 when identical, 1 on drift (the drifted
# files are printed), 2 on usage/error.
# usage: scripts/check-skill.sh [<source-repo-dir>]   (or SPELL_EXPLORE_SRC)
set -euo pipefail

SRC_ARG="${1:-${SPELL_EXPLORE_SRC:-}}"
if [ -z "$SRC_ARG" ]; then
  echo "error: pass the source repository path, or set SPELL_EXPLORE_SRC." >&2
  exit 2
fi
SRC="$(cd "$SRC_ARG" && pwd)"
USER_SKILL="$HOME/.kimi-code/skills/spell-explore"

# the source repository can never be the installed copy itself
if [ "$SRC" = "$USER_SKILL" ]; then
  echo "error: the source repository cannot be the installed skill copy." >&2
  exit 2
fi

# --- current layout: the packaged skill at <repo>/skills/spell-explore is canonical
if [ -d "$SRC/skills/spell-explore" ]; then
  if diff -rq "$SRC/skills/spell-explore" "$USER_SKILL" >&2; then
    echo "clean: installed protocol == $SRC/skills/spell-explore"
    exit 0
  else
    echo "drift: the installed protocol differs from $SRC/skills/spell-explore — align with $SRC/scripts/sync-skill.sh" >&2
    exit 1
  fi
fi

# --- old (superseded) layout: protocol/ at the repo root
if [ -d "$SRC/protocol" ]; then
  ok=1
  diff -rq "$SRC/protocol" "$USER_SKILL/references/protocol" >&2 || ok=0
  if [ -f "$SRC/skills/spell-explore/SKILL.md" ]; then
    cmp -s "$SRC/skills/spell-explore/SKILL.md" "$USER_SKILL/SKILL.md" || ok=0
  fi
  for f in planning-ideas-no-push.md construction-plan.md; do
    if [ -f "$SRC/$f" ]; then
      cmp -s "$SRC/$f" "$USER_SKILL/references/$f" || ok=0
    fi
  done
  for f in USER-GUIDE.md LICENSE; do
    if [ -f "$SRC/$f" ]; then
      cmp -s "$SRC/$f" "$USER_SKILL/$f" || ok=0
    fi
  done
  diff -rq "$SRC/scripts" "$USER_SKILL/scripts" >&2 || ok=0
  if [ "$ok" -eq 1 ]; then
    echo "clean: installed protocol == $SRC (old layout)"
    exit 0
  fi
  echo "drift: the installed protocol differs from $SRC — align with $SRC/scripts/sync-skill.sh" >&2
  exit 1
fi

echo "error: cannot locate the spell-explore skill in $SRC (neither skills/spell-explore nor protocol/)." >&2
exit 2
