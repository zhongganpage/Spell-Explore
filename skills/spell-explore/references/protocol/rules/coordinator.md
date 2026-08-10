# Coordinator — regulation rules

The Coordinator (locked name) is the initial agent and the one responsible for the
whole project: all the rounds that run and all the results obtained in the project. It
runs each round, coordinates the jobs, and keeps the project running at high quality.
It does not create anything itself. This file is the regulation the Coordinator
follows; it is written for the Coordinator agent to read and act on. Where a term is
marked locked, that exact term must be used.

## 1. Round-1 setup — before the clock starts

The round-1 setup happens before the round clock starts and is not counted in the
138-minute budget:

- at the beginning of the initial round, the Coordinator asks the user for the rough
  idea, and makes it the goal — writing it into the single locked goal file (goal.md
  at the project root, outside the dossier), with the precise statement and notation;
  workers cite the goal file and never edit it; the goal file is locked and the
  project never changes it;
- the user also chooses the number of rounds at this point;
- the Coordinator runs the environment preflight: the lean toolchain answers (lean
  --version), qmd-prover is available, and the agent-profile discovery resolves —
  the four subcoordinator profiles (Creator, Producer, Selector, Formalizer) are
  found and readable. the results are recorded in the dossier and surfaced to the
  user; the Formalizer idles gracefully when the toolchain is missing — it stays
  alive and produces no green pieces and no error;
- the Coordinator instantiates the question-routes folder: question-routes.md, the
  copy of the reliable idea set, and the per-route subfolders as they appear (see
  §10), and writes the main question entry mirroring the locked goal.

The Coordinator does not create anything in this setup — no summaries, no reports, no
routes. It writes the goal and starts the machinery.

## 2. The fixed sequence the Coordinator enforces

The standard procedure of the project is a fixed sequence of stages:

    Creator → Producer → Selector

- the Creator produces the fresh summaries;
- the Producer turns triples of fresh summaries into idea reports and then into routes;
- the Selector reviews each fresh route and decides whether it is accepted;
- each stage hands its output to the next stage, and only the Selector's accepted
  routes are presented to the user;
- the Formalizer and the feedback lanes (failures and rejections marked stale, mined
  again by the Creator's second phase) branch off this main sequence.

The Coordinator enforces the sequence: no stage starts before its handoff dependency
is satisfied, and no stage is skipped. Only the Selector's accepted routes reach the
user.

## 3. Status monitoring and handoff dependencies

The Coordinator regulates the subcoordinators (Creator, Producer, Selector,
Formalizer). Each subcoordinator regulates its own workers within its own territory —
the Creator within idea generation and archiving, the Producer within report and route
production, the Selector within review and acceptance, the Formalizer within
formalization — monitoring its workers' status, enforcing the time limits and the
artifact rules, and solving issues inside its territory. The Coordinator regulates the
subcoordinators themselves.

The Coordinator monitors:

- which stage each subcoordinator is in;
- whether the handoff dependencies are satisfied:
  - a fresh summary with its complement ready before the Producer starts;
  - a route ready before the Selector starts;
- whether any subcoordinator is stalled or conflicting;
- the queue depth: the number of queued summary triples (reports/queue.md) and the
  number of queued route reviews, reported in the round close.

Artifact guarantees the Coordinator enforces (shared with the subcoordinators): every
worker that produces an artifact is spawned with an explicit output path and must
write its artifact there and confirm the write in its final message; a worker that
cannot write — a read-only profile, or the external workerD — includes the complete
artifact text in its final message and the responsible subcoordinator persists that
text verbatim at the assigned path, marked recovered from agent output. The
Coordinator checks that every artifact exists after each worker completes, never
starts the next phase or handoff on a missing artifact, and transfers documents
between stages only as files. The Coordinator and the subcoordinators are responsible
for transferring documents between workers and subcoordinators.

All subcoordinators and all workers run in the background: every subagent is spawned
in the explicit background mode, never the blocking foreground. The subcoordinators,
the PIs, and the lean code runner are resumable: each runs its phase to completion
in one run and is resumed by the Coordinator for the next phase; a subcoordinator
never returns early — its final message comes only after every worker it spawned has
produced its artifact at the assigned path and the subcoordinator has verified the
write. Every other worker closes once its job is done. see rules/worker-lifespans.md
for the hold-open connections.

Everything is versioned — every fresh summary, idea report, route, review summary,
change list, stale entry, qmd file update, reliable idea set entry, fragment region
update, dependency graph update, question-routes.md, and the manuscript carries a
version (v1, v2, …); nothing is cited or built on without its version. The goal file
is excluded from this rule: it is locked and the project never changes it. The
Coordinator enforces that the version inventory stays current.

At the start of a round, the Coordinator reads the Knowledge State navigation index in
the dossier first — the conjectures registry, the obstructions register, and the
champion-route pointer — as every fresh worker does.

At the start of each round it performs the bounded Formalizer check before the round
clock starts: it reads the formalization status line in the Knowledge State index and
the live background state, verifies that the resumable workers are present and
working — the four subcoordinators (Creator, Producer, Selector, Formalizer), the
PIs, and the lean code runner — re-spawning any that a resumed session lost with its
runtime/<role>-state.md resume pack (rules/worker-lifespans.md) — and
resolves any stall or conflict it finds; the check is a bounded read that, like the
round-1 setup, is not counted in the 138-minute budget. It repeats the environment
preflight of §1 — the lean toolchain (lean --version), qmd-prover availability, and
the agent-profile discovery (the four subcoordinator profiles resolve) — and records
the results in the dossier, surfacing them to the user.

## 4. Solving stalls and conflicts

When the Coordinator finds inconsistencies in the status, it solves them, in this
order:

1. restarting a stalled worker;
2. reordering handoffs;
3. arbitrating between subcoordinators;
4. escalating to the user.

A stalled worker is one that has not produced its artifact within its binding window:
its phase is cut per §5 and its partial output recorded, then it is restarted or its
handoff is reordered so the pipeline moves. A Formalizer or lean code runner that a
resumed session lost is a stalled worker and is re-spawned first. Conflicts between
subcoordinators (for
example, a document claimed by two stages, or a fragment deposited in the wrong
place) are arbitrated by the Coordinator; if arbitration cannot settle the conflict,
the Coordinator escalates to the user. The Coordinator never leaves a stalled or
conflicting stage blocking the round.

## 5. The 138-minute timeline — announce, timestamp, cut, close

Each round has a hard budget of 2 hours and 18 minutes (138 minutes). Round timing is
mandated: the operational clock loop — announce the round start, timestamp each phase
boundary, poll at each window end, cut the overrun — is specified in
rules/timekeeping.md. In short:

- the round start is announced and written in the dossier before any agent spawns;
- phase start and end timestamps are recorded at each boundary in the phase-time
  table;
- at each window end the Coordinator polls the phase's workers (TaskList), stops the
  still-running ones (TaskStop), and records the cut with the partial output path;
- timestamps are never reconstructed after the fact.

The timeline (critical path, one route):

| window | phase | binding notes |
|---|---|---|
| 0–20 | Creator phase 1 | n idea-workers (0 ≤ n ≤ 8) think (≤10 min) and write their summaries (≤10 min); the fresh summaries are ready by ~20 min (the rotation hands all n ideas at once and the workers write in parallel) |
| 20–45 | Producer report worker | writes the idea report (25 min) |
| 45–63 | hygiene linter + examine worker | linter layer 1 (mechanical) ≈3 min, linter layer 2 (the format + assumptions, implications and grouping) ≈7 min, then the examine worker (cap 8 min) |
| 63–103 | Selector panel | workerA lists the evidence points by 78 min; workerB/C/D review from 63 min and pivot to the list when it arrives; exchange reports 93–103 min, and each writes its review summaries |
| 103–118 | PI rebuts and modifies the route; promoter in parallel | the promoter writes its nearest true version note in the same window |
| 118–138 | the swarm decides | decision swarm (20 min) + resumed BCD reviewers (20 min) |

rounds ≥ 3 variant: the Producer's phase-2 1-minute summary choice adds 1 minute at the round's 20-min mark; the windows after the choice shift +1 — 21–46 (report), 46–64 (gates), 64–104 (panel), 104–119 (PI + promoter), 119–139 (swarm + BCD), panel internals shifting with them (workerA's list by 79, B/C/D 64–94, exchange 94–104) — and the round total is 139 minutes. rounds 1–2 run the 138-minute variant above.

Off the critical path and in the background: the Creator's second phase, the
Formalizer (its decompose workers run per pair of reports and feed the working swarm,
and the lean code runner, resumed by the Coordinator on every qmd update — the Formalizer runs across
rounds and is not bound by the 138-minute budget), and any additional Producer report
workers.

Cut rule: a phase that reaches its window end is cut and its partial output recorded
— the same rule as the 10-minute lemma cut — and the round closes atomically at 138
min even if a phase is mid-flight. These windows are the binding per-phase limits;
changing any of them means the 138-minute budget no longer holds. A round close never
cuts the Formalizer's swarm. The project never runs autonomously across days.

## 6. The atomic round close

Every round ends with a single atomic round close written in one pass, containing:

- the fresh routes;
- the verdicts;
- the stale list with their fragments;
- the phase-time table;
- the decision list: the abstracts of the accepted routes; recycle / park for each
  unaccepted route; the user's nominations for which summaries or fragments to pair
  in the next round.

The Coordinator presents to the user, together with the decision list, every accepted
route; the user sees the accepted route before it is marked a new version (the
Producer marks it a new version after the user sees it). The Coordinator also keeps
the user informed of substantive formalization news as it happens and at each round
close: a new green lemma, a new [Formalized] premise, a change in the goal node's
distance to the acceptable set, or a significant fragment deposit — routine writes
are recorded only in the dossier. The user decides on each
unaccepted route: recycle it back to the Creator, or park it (the fragments are kept
but it is not auto-recycled). A round may deliver no accepted route; in that case the
round delivers the round-close record with the decision list.

## 7. Round-2+ scheduling — carried work first

At the start of a round, any carried-over work is handled first: the Selector resumes
queued route reviews and the Producer processes queued summary triples.

The Coordinator tracks the queue depth — the queued summary triples (reports/queue.md)
and the queued route reviews — reports it in the round close, and may hint the
Creator to lower n for the next round when the queue is deep, so the pipeline drains
before new material arrives. The depth is a measurement and a hint, never into the
votes.

In rounds ≥ 2, when the Selector has unfinished work, the Creator runs at the same
time: it runs phase 1, whose workers look for ideas not in the idea pool (the Creator
supplies them the Knowledge State index; they must find ideas that do not exist in the
pool, and not even ideas similar to the ones already archived), and phase 2 whenever
the pool has content — stale documents (summaries / reports / routes) from the other
subcoordinators, the reliable idea set, or the fragment region.

In rounds ≥ 2 the carried review owns the critical path: its panel, PI rebuttal and
swarm run in their windows first, while the Creator's phase 1 and the Producer's
report run in the background alongside it. A new route's review starts only if the
remaining budget fits a full review (75 min: panel 40 + PI 15 + swarm 20); otherwise
the round closes with the carried verdict and the new report queued.

There is no fixed limit on the number of routes in one round: the Selector reviews
each fresh route as it becomes ready, and the 138-minute budget is the only bound. In
practice two route reviews fit per round (the Selector runs two panels at a time,
63–103; the two PI rebuttals run in parallel, 103–118; the two decision swarms run
together in the same window, 118–138, as background workers), so a third route's
review is carried to the next round.

## 8. Measurements — tuned by data, never into the votes

After each round the Coordinator itself measures the system. The measurements are
recorded in the dossier and may feed back into the examine worker's rigor — never
into the votes, whose acceptance thresholds are fixed — so the taste of the system is
tuned by data. The acceptance thresholds never change: a route is accepted only if
≥2/3 of the swarm workers AND ≥2/3 of the BCD reviewers agree.

The Coordinator computes:

- the idea-yield: routes accepted vs agent-time spent;
- premature kills: the accepted routes are searched mechanically for fragment ids
  archived earlier — the stale entries and the fragment-region deposits carry ids —
  and each hit is classified killed-by-evidence or killed-by-opinion from the stale
  entry's fields (the failure reason states which, per the stale-entry format);
- the consistency of the panel verdicts.

These measurements never affect a vote and never alter an acceptance threshold; they
only feed the examine worker's rigor and the general tuning of the system.

when two consecutive rounds each end with every route rejected by full unanimity
(0/3 swarm and 0/3 BCD), the Coordinator produces a steering report: the distribution
of the load-bearing obstructions across the two rounds and the options for the user —
splitting the goal (specializing to provable subproblems), nominating pairings, or
pausing — and the project does not start a third such round on its own.

## 9. Acceptance, milestone, and the manuscript

Acceptance of a route: ≥2/3 of the swarm workers AND ≥2/3 of the BCD reviewers agree.
The acceptance numbers rank the quality of an accepted route: full consensus (3/3 +
3/3) is the strongest, lower counts are accepted but weaker.

Milestone: the milestone is Lean-led — the required condition is the goal node of
dependency-graph.json reachable from the [Formalized] or [Hired] assumptions. The
3/3 swarm + 3/3 BCD unanimity is the presentation bar for the manuscript, not the
reachability condition.

When the goal node is reachable with full consensus, the Coordinator writes a report
about it in PDF, called the manuscript (locked name); the manuscript carries a
version. When the reachability holds without the unanimity, the Coordinator reports
the formalization milestone to the user and asks how to proceed — write the
manuscript, or keep going.

## 10. question-routes maintenance

The Coordinator maintains a dedicated folder named question-routes in the project
folder. It holds:

- question-routes.md — the main question and, as each route is accepted, the abstract
  of that route; it is the living map of the main question and the current
  accepted-route abstracts, and it carries a version; each accepted-route entry also
  carries its current version and the current defender PI — the PI of the route's
  latest accepted version, named by its PI id and the route version;
- for every accepted route, all artifacts related to it — the summaries, the idea
  reports, the route with its versions, and the review reports — in a subfolder named
  by the title of that route;
- a copy of the full reliable idea set as a file in the question-routes folder,
  regenerated at each round close by a file copy from dossier/idea-pool/
  reliable-idea-set/ — never hand-maintained.

Accepted routes are not completely trustworthy and acceptance is not the end of a
route: a route may be challenged or revised in a later round. The Coordinator keeps
question-routes.md a living map — when an accepted route's abstract changes, the map
is updated as a new version; nothing is deleted, everything is versioned; superseded
versions stay recorded in the subfolder, never deleted.

The current-defender-PI pointer: the defender of a route is the PI of its latest
accepted version, and every future challenge to the route — any version — is answered
by that PI. The handover duty: when a revision of an accepted route is accepted and
the user has seen it, the Coordinator verifies that the new PI has archived the
accepted revision in question-routes/<title>/ as the new version, with the older
version marked superseded (old files never edited), marks the replaced PI's resume
pack (runtime/<title>-pi-state.md) superseded in the version records, TaskStops the
replaced PI task, and records the new defender — the new PI, named by its id and the
new version — in question-routes.md and the champion-route pointer. Same-title
serialization: no two reviews of the same route title run concurrently; an in-flight
challenge finishes before a handover starts.

## 11. The Formalizer wind-down

The Formalizer is a mandated part of the project: it always runs across rounds, and it
winds down only when the project ends. The Coordinator sees that it finishes its
existing work before closing: no new reports come in, the decompose workers finish
their pairs, the working swarm completes transforming the decomposed fragments, and
the lean code runner processes the remaining qmd pieces. The Formalizer is not bound
by the 138-minute budget, and a round close never cuts its swarm.
