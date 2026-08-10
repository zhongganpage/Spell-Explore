# fresh summary — template

a fresh summary (lock this name) is a worker's write-up of an idea. it is produced by the
Creator's phase-1 or phase-2 workers, archived in the idea pool in the dossier, and later paired
by the Producer by complementarity — with another fresh summary, or with an obstruction and its
closest technique from the fragment region. it always carries a version. this file is the
template a worker fills in; the filled file becomes the artifact.

## who, when, where

- produced by: a Creator worker (phase 1 or phase 2), written in at most 10 minutes.
- before writing (phase 1): the worker thought freely for at most 10 minutes about new ideas
  around the locked goal — the locked goal file — with maximal freedom; in round ≥ 2 it also
  read the Knowledge State index and must find ideas that do not exist in the idea pool — not
  even ideas similar to the ones already archived.
- the rotation: before the summaries are written, the Creator rotates the n ideas — it hands the
  idea of each worker to the next worker (with n = 4, the idea of worker 1234 goes to worker
  4123) — and the worker learns from the idea it receives — a summary may incorporate what the
  worker learned, and should say so.
- where it lands: the idea pool in the dossier, archived by the Creator; nothing reads it as
  established until it is paired into an idea report.
- versioning: every fresh summary carries a version (v1, v2, …); nothing is cited or built on
  without its version.

## the format

the exploration is free-form — the persistence and verification protocols are not binding on
these workers — but the summary format is binding, and the whole write-up stays within 10
minutes.

### id

`<summary-id>` · round `<round>` · phase `<1 | 2>` · worker `<worker-id>` · version `<v1, v2, …>`

### idea

`<one precise statement of the idea, in the notation of the locked goal file; as short as
honesty allows>`

### connections

`<how the idea connects to the goal — what part of the locked goal's unproved structure it
touches; which pool ideas, reliable idea set entries, or fragment region pieces it builds on or
contradicts, each with its version>`

### conflicts

`<what the idea conflicts with: existing claims, archived summaries, the fragment region, the
reliable idea set, the dependency graph — name them with versions>`

### possible directions

`<what this idea opens up: the concrete directions a report worker could push; at least one,
each ending in a next step>`

### novelty check (round ≥ 2 only)

`<the idea was checked against the Knowledge State index: the nearest existing pool ideas, and
why this is not the same and not even similar to them>`

## rules that bind this artifact

- the worker writes the summary in at most 10 minutes and confirms the write in its final
  message; the Creator archives it in the idea pool before the next handoff.
- phase-2 summaries are produced the same way: the Creator receives a summary, report, or
  unsuccessful route, requests n idea-workers (0 ≤ n ≤ 8) from the Coordinator to search for good ideas and techniques in it and in the
  reliable idea set and the fragment region (at most 15 minutes), runs the same rotation, and
  the summaries are archived as fresh.
- a fresh summary is never treated as established: only an accepted route is presented to the
  user; everything before that is never established.
- when a paired report fails the examine, this summary is tagged with what was missing — the
  examine's sufficiency finding — so the next pairing deliberately fills the gap instead of
  repeating it.
- when its report is unsuccessful or its route is unaccepted, this summary is marked stale with
  a stale entry, and its fragments are archived in the fragment region.
