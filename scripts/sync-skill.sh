#!/usr/bin/env bash
# Spell-Explore — sync the packaged skill (skills/spell-explore) into the
# user-scope skill copy (~/.kimi-code/skills/spell-explore) that Kimi Code
# discovers, keeping both identical to the canonical protocol. in the current
# layout the packaged skill copy IS the protocol source (the top-level
# protocol/ tree is superseded and gitignored); the script also supports the
# older layout where protocol/ sits at the repo root.
# usage: scripts/sync-skill.sh. run from the source repository; SRC is computed
# from the script's own location. ends with a diff check — packaged skill vs
# the user-scope copy — and exits non-zero if any difference remains.
set -euo pipefail

SRC="$(cd "$(dirname "$0")/.." && pwd)"
SKILL_DIR="$SRC/skills/spell-explore"
USER_SKILL="$HOME/.kimi-code/skills/spell-explore"

# refuse to run from the installed copy itself: the sync flows repo -> user scope
if [ "$SRC" = "$USER_SKILL" ]; then
  echo "error: run this from the source repository, not from the installed skill copy." >&2
  exit 1
fi

# --- locate the protocol source -------------------------------------------------
# the packaged skill keeps the protocol at references/protocol/ (current layout);
# the older source-repo layout kept it at protocol/ (a sibling of scripts/).
# resolve whichever exists, mirroring init-project.sh's resolution.
if [ -d "$SRC/protocol" ]; then
  PROTO="$SRC/protocol"
elif [ -d "$SKILL_DIR/references/protocol" ]; then
  PROTO="$SKILL_DIR/references/protocol"
else
  echo "error: cannot locate the protocol (neither $SRC/protocol nor $SKILL_DIR/references/protocol)." >&2
  exit 1
fi

# 1. mirror protocol -> skill references/protocol. when the protocol already
#    lives at the packaged path (current layout) it is the canonical copy and
#    there is nothing to mirror — never rm -rf the source.
if [ "$PROTO" != "$SKILL_DIR/references/protocol" ]; then
  rm -rf "$SKILL_DIR/references/protocol"
  cp -r "$PROTO" "$SKILL_DIR/references/protocol"
  echo "mirrored protocol -> $SKILL_DIR/references/protocol"
else
  echo "protocol is canonical at $SKILL_DIR/references/protocol (current layout) — no mirror"
fi

# 2. the top-level docs, copied only if they differ.
#    (planning-ideas-no-push.md is gitignored — kept locally; absent sources are skipped)
rm -f "$SKILL_DIR/references/planning-idea.md"  # stale old spec name
for f in planning-ideas-no-push.md construction-plan.md; do
  if [ -f "$SRC/$f" ]; then
    if [ ! -f "$SKILL_DIR/references/$f" ] || ! cmp -s "$SRC/$f" "$SKILL_DIR/references/$f"; then
      cp "$SRC/$f" "$SKILL_DIR/references/$f"
      echo "updated $SKILL_DIR/references/$f"
    fi
  fi
done
for f in USER-GUIDE.md LICENSE; do
  if [ -f "$SRC/$f" ]; then
    if [ ! -f "$SKILL_DIR/$f" ] || ! cmp -s "$SRC/$f" "$SKILL_DIR/$f"; then
      cp "$SRC/$f" "$SKILL_DIR/$f"
      echo "updated $SKILL_DIR/$f"
    fi
  fi
done

# 3. ship the scripts/ next to the skill (the SKILL.md references them relative to the skill dir)
rm -rf "$SKILL_DIR/scripts"
cp -r "$SRC/scripts" "$SKILL_DIR/scripts"
echo "mirrored scripts -> $SKILL_DIR/scripts"

# 4. mirror the skill -> ~/.kimi-code/skills/spell-explore
mkdir -p "$USER_SKILL"
rm -rf "$USER_SKILL/references" "$USER_SKILL/scripts"
cp -r "$SKILL_DIR/references" "$USER_SKILL/references"
cp -r "$SKILL_DIR/scripts" "$USER_SKILL/scripts"
for f in SKILL.md USER-GUIDE.md LICENSE; do
  if [ -f "$SKILL_DIR/$f" ]; then
    cp "$SKILL_DIR/$f" "$USER_SKILL/$f"
  fi
done
echo "mirrored skill -> $USER_SKILL"

# 5. diff check: the packaged skill vs the user-scope copy
echo
echo "diff -rq packaged skill vs user-scope copy:"
ok=1
diff -rq "$SKILL_DIR/references" "$USER_SKILL/references" || ok=0
for f in SKILL.md USER-GUIDE.md LICENSE; do
  if [ -f "$SKILL_DIR/$f" ]; then
    diff -q "$SKILL_DIR/$f" "$USER_SKILL/$f" || ok=0
  fi
done
if [ "$ok" -eq 1 ]; then
  echo "clean: packaged skill == user-scope copy"
else
  echo "differences remain above — fix and re-run" >&2
  exit 1
fi
