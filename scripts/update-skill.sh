#!/usr/bin/env bash
# Spell-Explore — remote protocol update: the only step that talks to the GitHub
# remote. check-skill.sh / sync-skill.sh only compare local trees (repo vs the
# user-scope installed copy) and never look at the remote — so a protocol change
# pushed to GitHub is invisible to them until the clone itself is updated. this
# script closes that blind spot: it fetches the origin into the local clone of
# the Spell-Explore repository (protocol-src), fast-forwards the local branch
# when the published protocol has moved, and propagates the result into
# ~/.kimi-code/skills/spell-explore via scripts/sync-skill.sh.
# usage: scripts/update-skill.sh [--check]
#   --check   read-only freshness probe: fetch the origin and compare the local
#             branch with its upstream; prints "up to date" (exit 0) or the
#             pending commits (exit 1). fetches refs but never touches the
#             working tree and never syncs.
#   (default) fetch, fast-forward the local branch when behind (git pull
#             --ff-only — never --merge, never --reset), then run sync-skill.sh
#             to propagate into the user-scope copy. when already up to date it
#             still syncs, repairing any pre-existing drift.
# run from the source repository (protocol-src), like sync-skill.sh. refuses to
# run when the clone has uncommitted tracked changes (it never clobbers local
# edits) and when run from the installed skill copy itself.
set -euo pipefail

MODE="${1:-}"
if [ -n "$MODE" ] && [ "$MODE" != "--check" ]; then
  echo "error: unknown argument '$MODE' (expected --check or nothing)." >&2
  exit 2
fi

SRC="$(cd "$(dirname "$0")/.." && pwd)"
USER_SKILL="$HOME/.kimi-code/skills/spell-explore"

# refuse to run from the installed copy itself: the update flows repo -> user scope
if [ "$SRC" = "$USER_SKILL" ]; then
  echo "error: run this from the source repository, not from the installed skill copy." >&2
  exit 2
fi

# the source must be a git clone — unlike check-skill.sh this step needs the remote
if [ ! -d "$SRC/.git" ]; then
  echo "error: $SRC is not a git clone — update-skill.sh needs the repository's git history and remote." >&2
  exit 2
fi

# the upstream the local branch tracks (falls back to origin/main)
UPSTREAM="$(git -C "$SRC" rev-parse --abbrev-ref --symbolic-full-name @{u} 2>/dev/null || echo origin/main)"

# never clobber local edits: uncommitted tracked changes block the update.
# (untracked files are fine — git pull --ff-only refuses itself if they collide)
DIRTY="$(git -C "$SRC" status --porcelain --untracked-files=no)"
if [ -n "$DIRTY" ]; then
  echo "error: $SRC has uncommitted tracked changes — commit or stash them before updating:" >&2
  echo "$DIRTY" >&2
  exit 2
fi

echo "fetching $SRC from the remote..."
git -C "$SRC" fetch origin

BEHIND="$(git -C "$SRC" rev-list --count "HEAD..$UPSTREAM")"
if [ "$BEHIND" -eq 0 ]; then
  echo "up to date: local $(git -C "$SRC" rev-parse --short HEAD) == $UPSTREAM"
  if [ "$MODE" = "--check" ]; then
    exit 0
  fi
  # still propagate — repairs pre-existing drift in the user-scope copy
  exec "$SRC/scripts/sync-skill.sh"
fi

echo "behind: the local branch is $BEHIND commit(s) behind $UPSTREAM:"
git -C "$SRC" log --oneline "HEAD..$UPSTREAM" | sed 's/^/  /'
if [ "$MODE" = "--check" ]; then
  echo "update available — run scripts/update-skill.sh (without --check) to apply it." >&2
  exit 1
fi

echo "fast-forwarding the clone..."
git -C "$SRC" pull --ff-only
echo "now at $(git -C "$SRC" rev-parse --short HEAD)"
exec "$SRC/scripts/sync-skill.sh"
