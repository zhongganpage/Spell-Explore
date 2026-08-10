# round-close record — template

every round ends with a single atomic round close written in one pass, at 138 minutes, even if a
phase is mid-flight: the fresh routes, the verdicts, and the stale list with their fragments,
together with a phase-time table, and the decision list. timestamps are never reconstructed
after the fact: the round start is announced and written in the dossier before any agent spawns,
and phase start and end timestamps are recorded at each boundary, as the round runs. this file
is the template the Coordinator fills in at the close.

## who, when, where

- written by: the Coordinator, in one pass, at the round's end — never piecemeal, never after
  the fact.
- the round clock: the round-1 setup — the Coordinator asking the user for the rough idea and
  writing the locked goal file — happens before the round clock starts and is not counted in
  the budget. the round itself is 138 minutes.
- where it lives: the project folder, versioned; it is the round's record and the user's
  decision document. a round may deliver no accepted route — in that case the round delivers
  this round-close record with the decision list.

## the format

### round `<n>` — close

- round start: `<announced timestamp, written in the dossier before any agent spawned>` ·
  round end: `<138-min boundary timestamp>`
- routes in this round: `<the fresh routes delivered, and any carried-over work handled first
  at the start>`

### fresh routes

`<for each fresh route in this round: title, version, its paired summaries, and its place in
the review sequence>`

### verdicts

- accepted: `<title + version, with the acceptance counts — swarm x/3, BCD x/3. acceptance =
  ≥2/3 of the swarm workers AND ≥2/3 of the BCD reviewers; the counts rank the route — full
  consensus (3/3 + 3/3) is the strongest>`
- unaccepted: `<title + version, with the counts and the failure reason>`
- carried over: `<queued route reviews and queued summary triples that carry to the next round —
  handled first at the next round's start; a new route's review starts only if the remaining
  budget fits a full review (75 min: panel 40 + PI 15 + swarm 20)>`

### stale list with fragments

`<for every item marked stale this round: the stale entry id, source item + version, failure
reason, revival trigger, and the fragments deposited in the fragment region — the sub-results
that hold, the obstruction, the closest technique, and the promoter's nearest true version note
when the route was rejected. the close lists them; the full stale entries live in stale/>`

### phase-time table

| phase | window | start (recorded at the boundary) | end (recorded at the boundary) | cut? | partial output |

the windows are the binding per-phase limits of the 138-minute timeline (critical path, one
route):

- 0–20 the Creator's phase-1 workers think (≤10 min) and write their fresh summaries (≤10 min),
  ready by ~20 — the rotation hands all n ideas at once and the workers write in parallel;
- 20–45 the Producer's report worker writes the idea report (25 min);
- 45–63 the hygiene linter and the examine worker decide sufficiency — layer 1 (mechanical)
  ≈3 min, layer 2 (the format + assumptions, implications and grouping) ≈7 min, then the
  examine worker (cap 8 min);
- 63–103 the Selector's panel — workerA lists the evidence points by 78 min, workerB/C/D review
  from 63 min and pivot to the list when it arrives, exchange reports 93–103;
- 103–118 the PI rebuts and modifies the route, with the promoter writing its nearest true
  version note in the same window;
- 118–138 the swarm decides, with the resumed BCD reviewers voting alongside.

rounds ≥ 3 variant: the Producer's 1-minute summary choice shifts the windows after 20 by +1 (21–46, 46–64, 64–104, 104–119, 119–139), total 139 minutes.
off the critical path and in the background: the Creator's second phase, the Formalizer (not
bound by the 138-minute budget — a round close never cuts the swarm), and any additional
Producer report workers. a phase that reaches its window end is cut and its partial output
recorded — the same rule as the 10-minute lemma cut. changing any window means the
2-hour-and-18-minute budget no longer holds.

### decision list

- accepted routes: `<for each: title, version, and the abstract — of the full route or of the
  accepted core — presented to the user before it is marked a new version; question-routes.md is
  updated with the abstract>`
- current defenders: `<for each accepted route: its current defender PI — the PI of the latest
  accepted version, named by its id and the route version; when a revision is accepted, the new
  PI (the Producer phase-2 route writer) writes the new version and marks the old superseded, the
  Coordinator TaskStops the replaced PI, and the new defender is recorded in question-routes.md and the champion-route pointer>`
- unaccepted routes: `<for each: recycle it back to the Creator, or park it (the fragments are
  kept but it is not auto-recycled) — the user decides. a round may deliver none>`
- user nominations: `<which summaries or fragments the user nominates to pair in the next
  round>`

## rules that bind this artifact

- the round closes atomically at 138 min in one pass, even when a phase is mid-flight; the
  round-close record with the decision list is delivered even when no route was accepted.
- the project never runs autonomously across days.
- the Coordinator's measurements — idea-yield (routes accepted vs agent-time spent), premature
  kills, and the consistency of the panel verdicts — are recorded in the dossier and may feed
  the examine worker's rigor, never the votes, whose acceptance thresholds are fixed.
- when the round reaches a milestone — all 3 swarm workers and all 3 BCD reviewers accept, and
  the accepted routes together achieve the locked goal — operationally, the goal node of
  dependency-graph.json reachable from the [Formalized] or [Hired] assumptions — the
  Coordinator writes a report about
  it in PDF, called the manuscript (lock this name), and the project winds down through the
  Formalizer's close.
