# stale entries — protocol/stale/

Versioned stale entries live in the project folder (not in the dossier). stale
markings are produced by the Producer and the Selector; the marked items are
sent to the Creator, which processes them in its second phase.

## What is marked stale

- unsuccessful reports and their corresponding summaries. a report that does not
  pass the hygiene linter is stale immediately: it does not move on, and the
  round produces no route from it. a report that fails the examine is stale
  with the examine's sufficiency finding recorded.
- unaccepted routes (rejected by the panel), unless the user parks them — a
  parked route keeps its fragments but is not auto-recycled.

## What each stale entry records (three things)

1. the failure reason — sufficiency failed, or the panel findings that rejected it;
2. a revival trigger — "re-examine when <event>";
3. the fragments of the work — the sub-results that still hold, the obstruction,
   and the closest technique.

## Where the fragments go

- the fragments are archived in the fragment region (lock this name) of the idea
  pool in the dossier, so a future report builds on what survived instead of
  re-deriving it, and the Creator's second phase mines the fragments directly.
- when a report fails the examine, its source summaries are tagged with what was
  missing, so the next pairing deliberately fills the gap instead of repeating
  it.

## Who writes

- the Producer: stale reports and their corresponding summaries.
- the Selector: stale (unaccepted) routes.
- the Coordinator: the stale list with their fragments is part of the single
  atomic round close written at 138 min in rounds 1–2 (round 3: 139 min; from
  round 4: 149 min; the windows shift +1 — rules/selector.md §3,
  rules/timekeeping.md §4).

## Who reads

- the Creator: it receives the stale items and searches for good ideas and
  techniques in them, together with the reliable idea set and the fragment
  region (at most 15 min), then writes fresh summaries as in phase 1.
- the Producer: when a revival trigger fires, its fragment jumps the pairing
  queue; the goal-frontier score counts revival-triggered and
  obstruction-touching fragments higher, and rewards ideas that would hire new
  assumptions.
- the Coordinator: the premature-kill measurement — stale or unaccepted items
  whose fragments later end up inside an accepted route, and whether they were
  killed by evidence or by opinion. the findings feed the examine worker's
  rigor, never the votes, whose acceptance thresholds are fixed.

## Rules

- versioned: every stale entry carries a version (v1, v2, …); nothing is cited
  or built on without its version.
