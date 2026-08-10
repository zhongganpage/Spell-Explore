#!/usr/bin/env bash
# Spell-Explore — sync the protocol into the packaged skill (references/) and
# into the user-scope skill copy (~/.kimi-code/skills/spell-explore) that Kimi
# Code discovers. both copies stay identical to the source.
# usage: scripts/sync-skill.sh. run from anywhere; SRC is computed from the
# script's own location. ends with a diff check — protocol vs the packaged
# copy — and exits non-zero if any difference remains.
set -euo pipefail

SRC="$(cd "$(dirname "$0")/.." && pwd)"
SKILL_DIR="$SRC/skills/spell-explore"
USER_SKILL="$HOME/.kimi-code/skills/spell-explore"

# 1. mirror protocol -> skill references/protocol (rm -rf, then cp -r)
rm -rf "$SKILL_DIR/references/protocol"
cp -r "$SRC/protocol" "$SKILL_DIR/references/protocol"
echo "mirrored protocol -> $SKILL_DIR/references/protocol"

# 2. planning-ideas-no-push.md and construction-plan.md, copied only if they differ
rm -f "$SKILL_DIR/references/planning-idea.md"  # stale old spec name
for f in planning-ideas-no-push.md construction-plan.md; do
  if [ -f "$SRC/$f" ]; then
    if [ ! -f "$SKILL_DIR/references/$f" ] || ! cmp -s "$SRC/$f" "$SKILL_DIR/references/$f"; then
      cp "$SRC/$f" "$SKILL_DIR/references/$f"
      echo "updated $SKILL_DIR/references/$f"
    fi
  fi
done

# 3. ship the scripts/ next to the skill (the SKILL.md references them relative to the skill dir)
rm -rf "$SKILL_DIR/scripts"
cp -r "$SRC/scripts" "$SKILL_DIR/scripts"
echo "mirrored scripts -> $SKILL_DIR/scripts"

# 4. mirror the skill -> ~/.kimi-code/skills/spell-explore (rm -rf references, then re-copy)
mkdir -p "$USER_SKILL"
rm -rf "$USER_SKILL/references" "$USER_SKILL/scripts"
cp -r "$SKILL_DIR/references" "$USER_SKILL/references"
cp -r "$SKILL_DIR/scripts" "$USER_SKILL/scripts"
cp "$SKILL_DIR/SKILL.md" "$USER_SKILL/SKILL.md"
echo "mirrored skill -> $USER_SKILL"

# 5. diff check: protocol vs the packaged copy
echo
echo "diff -rq protocol vs packaged copy:"
if diff -rq "$SRC/protocol" "$SKILL_DIR/references/protocol"; then
  echo "clean: protocol == skills/spell-explore/references/protocol"
else
  echo "differences remain above — fix and re-run" >&2
  exit 1
fi
