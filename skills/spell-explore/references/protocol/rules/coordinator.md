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
- the user also chooses the number of rounds at this point — the round count (lock this name): the binding cap on the rounds the Coordinator runs, recorded in runtime/coordinator-state.md (`rounds-chosen: N`, `rounds-completed: 0`) and in the dossier; the choice stands for the project and the rounds auto-run per §6a;
- the Coordinator asks whether to add an exterior reviewer X for the panel's workerD —
  the overall-judgement reviewer runs on a different provider — configured once as
  `X_PROVIDER` / `X_MODEL` / `X_ACCESS`: `api` (a provider API env var — the key lives
  in the environment, never in a record) or `codex` (the local Codex CLI), or none
  (internal reviewers only). the Coordinator helps the user configure the choice (see
  modules/providers.md) and verifies that `X_MODEL` is not the same provider family as
  the primary's — a one-line check, non-negotiable — and records the choice and its
  fallback expectations in the dossier: workerD falls back to an internal reviewer
  when the exterior is unavailable or shares the primary's provider family, and the
  reduced diversity is recorded with a confidence downgrade; the choice stands for the
  project;
- the Coordinator asks the runner-mode: whether to automatically run the lean code
  runner at the beginning of each round starting from round 2 — `auto` (whenever
  pending lean work exists at a round start and the runner is not already active,
  the Coordinator resumes it without asking) or `manual` (the Coordinator asks
  run-or-postpone at each round start — the default; nothing else changes). the
  choice is recorded in the dossier and stands for the project;
- the Coordinator asks the user for the source-repository path — the local clone of the Spell-Explore repository that holds the canonical protocol — records it in runtime/coordinator-state.md (`protocol-src: <path>`) and in the dossier, and runs the protocol-integrity check: the repository's scripts/check-skill.sh with that path (a bounded read, not counted in the budget). when the installed protocol differs from the repository's, the Coordinator aligns the installed copy with the repository — running the repository's scripts/sync-skill.sh, re-running the check to verify it is clean, recording the aligned files in the dossier — and surfaces the drift and the alignment to the user;
- the Coordinator runs the environment preflight: the lean toolchain answers (lean
  --version), qmd-prover is available, and the agent-profile discovery resolves —
  the four subcoordinator profiles (Creator, Producer, Selector, Formalizer) and every
  worker profile the Coordinator may spawn are found and readable; it also checks
  that KIMI_CODE_EXPERIMENTAL_SECONDARY_MODEL is exported (the secondary-model
  worker tier needs it — when it is unset the tier runs on the default model; the
  exterior reviewer X needs no experimental flag, but its access must resolve: the
  provider env var present for api, or the Codex CLI installed for codex — and its
  provider family must differ from the primary's) and that the live
  config's [subagent] timeout_ms is 0 (the resumable roles — the four
  subcoordinators, the PIs, the lean code runner — could otherwise be force-killed
  as timed_out mid-round); both take effect only at kimi start, so when either is
  not in effect the Coordinator tells the user to restart kimi with the flag
  exported and the config applied. the results are recorded in the dossier and surfaced to the
  user; the Formalizer idles gracefully when the toolchain is missing — it stays
  alive and produces no green pieces and no error;
- the Coordinator instantiates the question-routes folder: question-routes.md, the
  copy of the reliable idea set, and the per-route subfolders as they appear (see
  §10), and writes the main question entry mirroring the locked goal.

The Coordinator does not create anything in this setup — no summaries, no reports, no
routes: it creates no content; it spawns only what the subcoordinators request. It
writes the goal and starts the machinery.

## 2. The fixed sequence the Coordinator enforces

The standard procedure of the project is a fixed sequence of stages:

    Creator → Producer → Selector

- the Creator produces the fresh summaries;
- the Producer turns fresh summaries into idea reports and then into routes;
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
formalization — requesting its workers from the Coordinator, monitoring its workers'
status, enforcing the time limits and the artifact rules, and solving issues inside its
territory. The Coordinator regulates the
subcoordinators themselves.

The Coordinator is the spawn broker: it polls runtime/requests/, validates each
request against the locked format (kind: spawn | resume | stop; requester: the
territory letter; round; per worker: label, profile, output path, and a pointer to its
job brief — never inline brief text), spawns the requested workers named by their
labels, appends the status line (spawned | resumed | stopped | rejected, with the
reason when rejected) to the request file, executes the resume and stop operations the
subcoordinators instruct, and keeps the worker registry (runtime/worker-registry.md:
request → task-ids → labels → output paths) current, so a session resume restores each
territory's live workers. the Coordinator also executes the mechanical rotations a phase brief authorizes: when all n idea files are in, it builds the per-worker rotation briefs at runtime/briefs/ — each a mechanical splice of the preceding worker's idea file and the locked summary format, never Coordinator-authored content — and resumes the workers. a request is never silently reinterpreted. the swarm exception stands: the Selector's decision swarm of 3, the Formalizer's working swarm of ~4, and the lean code runner's swarm of at most 3 are spawned and regulated by their owners, and the Coordinator does not broker them. the Coordinator is a pure relay: it never composes or edits a worker's job — job briefs are file pointers, relayed verbatim. when a request names workerD, the Coordinator executes the exterior invocation itself — the api call or `codex exec` with the worker-d-external prompt (modules/providers.md) — captures the reply (the api response text or codex stdout, delimited by standardized markers), persists it verbatim at the assigned path marked recovered from agent output, and reports the model identifier the provider actually returned to the Selector; a failed invocation is retried once within the window, then the Selector records the fallback to the internal reviewer. the Coordinator never composes or edits the exterior reviewer's job — the prompt is the worker-d-external profile's, relayed verbatim.

The Coordinator monitors:

- which stage each subcoordinator is in;
- whether the handoff dependencies are satisfied:
  - a fresh summary with its complement ready before the Producer starts;
  - a route ready before the Selector starts;
- whether any subcoordinator is stalled or conflicting;
- the queue depth: the number of queued route reviews, reported in the round close.

### context economy — the subcoordinators' bounded contexts

the subcoordinators are resumable and their contexts persist across phases, so a
context that carries full file contents grows with every phase and every later turn
re-reads it all — the dominant measured cost of the system (the token analysis). the
Coordinator enforces the economy rule on every subcoordinator:

- artifacts live in files; a subcoordinator reads the artifact it needs at the
  moment it needs it (Read) and never carries full file contents in its context
  across resumptions;
- resume packs and job briefs carry file pointers, never inline contents — a
  subcoordinator's resume pack records its territory status and the pending
  artifacts it is waiting on (paths), not the artifacts themselves;
- the Coordinator's resume prompt to a subcoordinator points at files ('verify and
  continue' on the expected outputs) — the resumed role re-reads from disk instead
  of trusting what it already holds;
- a subcoordinator that over-reads — pulling a whole qmd file, a whole dossier or
  whole reports into its context when a pointer would do — is corrected and the
  read pattern recorded in the dossier; the discipline is a cost rule, never a
  content rule: nothing may be skipped because it was not read.
- round-boundary bounded contexts: across round boundaries a subcoordinator's
  context is bounded like the Coordinator's (the round-close /compact of
  rules/timekeeping.md §7): at each round close a subcoordinator whose round duty
  is complete and that has no in-flight worker closes, and the Coordinator spawns
  it fresh at the next round's bounded start check from its resume pack
  (runtime/<role>-state.md, file pointers only) — never resume-by-ID across
  rounds. resume-by-ID stays the within-round fast path (e.g. the Selector's
  phase-to-phase resumption and the B/C/D panel pause). the in-flight exception:
  a subcoordinator with owned children in flight (the Formalizer's working swarm)
  does not close at the boundary — it yields children-in-flight and closes at the
  next natural boundary, and the Coordinator never TaskStops it. the fresh spawn
  loses nothing: the territory state lives in the files and the resume pack, and
  later turns stop re-reading the whole prior conversation.

Artifact guarantees the Coordinator enforces (shared with the subcoordinators): every
worker that produces an artifact is spawned — by the Coordinator at its
subcoordinator's request, or by its owner for a swarm — with the explicit output path
its subcoordinator assigns and must write its artifact there and confirm
the write in its final message; a worker that
cannot write — a read-only profile — includes the complete
artifact text in its final message and the responsible subcoordinator persists that
text verbatim at the assigned path, marked recovered from agent output; the exterior
workerD's reply is captured from the api response or codex stdout, delimited by
standardized markers, and persisted the same way (modules/providers.md). The
Coordinator checks that every artifact exists after each worker completes, never
starts the next phase or handoff on a missing artifact, and transfers documents
between stages only as files. Before accepting a subcoordinator's final message the
Coordinator verifies by file that every worker it directs has produced its artifact
at the assigned path; on a missing artifact it resumes the subcoordinator with
'artifact before handoff' and records the early return. before resuming any subcoordinator the Coordinator also checks whether its expected outputs already exist on disk: if they do, the resume prompt is 'verify and continue', never 'redo'. when a resume is rejected as 'already running', the Coordinator treats it as the signal that the role is self-regulating: it reads the role's latest output and the artifacts it owns, verifies by file (the expected outputs and the role's resume pack), waits for the role's self-completion, and never TaskStops a role that is actively producing artifacts. '0 active tasks' in the Coordinator's TaskList is never an all-clear by itself: the Coordinator also checks the worker registry's swarm rows and the roles' state files before declaring a phase idle. The Coordinator and the subcoordinators are responsible
for transferring documents between workers and subcoordinators.

### the Coordinator's own turn discipline

the Coordinator is a turn-based main agent; its turn ends are the moments the
pipeline can stall, so its own lifecycle carries the same contract the
subcoordinators' do (rules/worker-lifespans.md): every turn ends with a lifecycle
line — `children-in-flight (<task-ids>, <pending artifact paths>)` |
`awaiting-resume at <window>` | `round-closed` — stated in the final message and
written to runtime/coordinator-state.md, so any resumed prompt (auto-continue or
the user) resumes the round from a file, never from task-state inference. the
Coordinator never ends a turn that leaves the round mid-flight undriven:

- a narrated step is not a done step for the Coordinator's own turn: before ending
  any turn it verifies by file that every phase it declared done has its artifacts
  at the assigned paths, and lists its in-flight workers from TaskList;
- any worker of the current phase that is neither done (artifact present) nor
  running (TaskList) is a stalled worker: the Coordinator restarts it in the same
  turn, keeping its label (per §4), never leaving the stall for a later window;
- the clock watcher's presence is part of the turn discipline: before ending any
  turn that leaves the round mid-flight, the Coordinator verifies the watcher set
  is live — the `watcher-backstop` job present in CronList with the locked wake
  prompt and every not-yet-fired boundary/checkpoint one-shot still scheduled,
  or the fallback `sleep 600` task in TaskList (rules/timekeeping.md §6) — and
  re-creates/re-spawns any missing job in the same turn; a missing watcher is a
  stalled worker per §4 and is never left for a later window;
- if the round is mid-flight and nothing is in flight, the Coordinator either
  executes the current phase's pending spawn requests now (runtime/requests/ is a
  file queue — spawn before closing the turn) or writes `awaiting-resume at
  <window>` to runtime/coordinator-state.md with the exact next action; a turn that
  ends mid-round without a lifecycle line is an early return, recorded like any
  other.

All subcoordinators and all workers run in the background: every subagent is spawned
in the explicit background mode, never the blocking foreground; every resume (resume-by-ID) also runs in the explicit background mode. The subcoordinators,
the PIs, and the lean code runner are resumable: each runs its phase to completion
in one run and is resumed by the Coordinator for the next phase; a subcoordinator
never returns early — its final message comes only after every worker it directs has
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
PIs, and the lean code runner — re-spawning any that a resumed session lost — and any subcoordinator that
closed at the previous round's close per the round-boundary bounded context of
this §3 — with its
runtime/<role>-state.md resume pack (rules/worker-lifespans.md), and restoring each
territory's live workers from the worker registry — and it sweeps
formalizer/fragments/ for landed-but-unintegrated per-fragment files, handing them to
the lean code runner's next merge — and resolves any stall or conflict
it finds; the check is a bounded read that, like the
round-1 setup, is not counted in the 138-minute budget. It repeats the environment
preflight of §1 — the lean toolchain (lean --version), qmd-prover availability,
the agent-profile discovery (the four subcoordinator profiles and every worker profile the Coordinator may spawn resolve), and the
secondary-model flag and [subagent] timeout checks — and records
the results in the dossier, surfacing them to the user. It also repeats the protocol-integrity check of §1: running the recorded protocol-src through the repository's scripts/check-skill.sh (when protocol-src is missing — a project started before this check existed — the Coordinator asks the user for the path at this round start and records it), aligning the installed protocol with the repository — the repository's scripts/sync-skill.sh — when drift is found, re-running the check to verify it is clean, and recording the drifted and aligned files in the dossier. It also reads the accepted-route watch (formalizer/accepted-routes.md) and the stale-signal channel (runtime/stale-signals/): on a stale signal it delegates the stale marking — asking the Selector, or spawning a dedicated stale-worker when the Selector is working (mid-panel or in a window) — and sees the demotion through so the accepted route is, by the end of the round, no different from a stale route: the stale entry written per the stale-entry template, the fragments archived in the fragment region, the abstract superseded in question-routes.md, the defender PI retired (resume pack superseded, TaskStop), and the champion-route pointer updated when the staled route was the champion; it verifies the demotion by file and appends the signal's status line (received | delegated | done). the check also reads the
Coordinator's own lifecycle from runtime/coordinator-state.md: when it shows a
mid-round phase — children-in-flight or awaiting-resume at an unclosed window —
the Coordinator completes that phase first (verifies the artifacts at the pending
paths, restarts any missing worker from the worker registry, then advances) before
starting anything new; a resumed prompt therefore always resumes the round instead
of idling. the check also runs the lean-runner gate: when landed-but-unintegrated
per-fragment files exist under formalizer/fragments/ (or the runner is recorded
paused with pending units) and the runner is not already active, the Coordinator
decides per the runner-mode chosen at round 1 — in manual mode it asks the user —
run the lean code runner now, or postpone it to the next round; in auto mode it
automatically chooses 'run' without asking. on 'run' (manual or auto) it clears any
pause marker and resumes the runner in the background (once per
round, batched); on a manual 'postpone' it records `paused: round N` in the worker
registry and in the Formalizer's resume pack, and the runner is not resumed on any
trigger — the Formalizer re-requests it at the next round start, where the gate
applies again. the runner is never resumed
mid-round on a qmd file update: fragments that land during the round wait for the
next resumption.

## 4. Solving stalls and conflicts

When the Coordinator finds inconsistencies in the status, it solves them, in this
order:

1. restarting a stalled worker (the Coordinator re-spawns it, keeping its label);
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
rules/timekeeping.md. the clock loop is kept alive mechanically by the clock watcher
(rules/timekeeping.md §6): at round start the Coordinator creates the watcher set —
one-shot wakes at every binding window end and at the handoff checkpoints of the
0–20 and 45–63 windows, plus a recurring 10-minute backstop — self-arming by
construction, so the chain survives even when its own turn ended earlier or a wake
was missed; the atomic close deletes the backstop, cancels the pending one-shots,
and the next round creates its own set. In short:

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
and the lean code runner, resumed once per round at the round start (batched; run-or-postpone gate) — the Formalizer runs across
rounds and is not bound by the 138-minute budget), and any additional Producer report
workers.

Cut rule: a phase that reaches its window end is cut and its partial output recorded
— the same rule as the 10-minute lemma cut — and the round closes atomically at 138
min even if a phase is mid-flight. These windows are the binding per-phase limits;
changing any of them means the 138-minute budget no longer holds. A round close never
cuts the Formalizer's swarm. The project never runs autonomously across days: the auto-run is bounded by the round count chosen at round-1 setup and the stop conditions of §6a, and the user can stop it at any time.

## 6. The atomic round close

Every round ends with a single atomic round close written in one pass, containing:

- the fresh routes;
- the verdicts;
- the stale list with their fragments;
- the phase-time table;
- the decision list: the abstracts of the accepted routes; recycle / park for each
  unaccepted route; the user's nominations for which summaries or fragments to pair
  in the next round.

the round's clock watcher set is deleted as part of the close — the `watcher-backstop`
job and any not-yet-fired one-shot, each CronDelete'd (rules/timekeeping.md §6) — so
nothing fires after the round; the next round creates its own set.

The Coordinator presents to the user, together with the decision list, every accepted
route; the user sees the accepted route before it is marked a new version (the
Producer marks it a new version after the user sees it). The Coordinator also keeps
the user informed of substantive formalization news as it happens and at each round
close: a new green lemma, a new [Formalized] premise, a change in the goal node's
distance to the established base, or a significant fragment deposit — routine writes
are recorded only in the dossier. The user decides on each
unaccepted route: recycle it back to the Creator, or park it (the fragments are kept
but it is not auto-recycled); the decision is presented at the close and does not
block the next round's start — until the user decides, the route defaults to park,
recorded pending in the round-close record and applied as the user answers (a
recycle feeds the next round's Creator, a park leaves it out of the auto-recycle).
A round may deliver no accepted route; in that case the
round delivers the round-close record with the decision list.

### 6a. auto-continuation — the round ledger

The round count chosen at round-1 setup (§1) is the binding cap on the rounds the
Coordinator runs. The Coordinator keeps the round ledger in
runtime/coordinator-state.md — `rounds-chosen: N` (set at setup) and
`rounds-completed: n` (incremented at each atomic close) — and mirrors it in the
dossier. At each round close the Coordinator writes the close record and the
decision list, updates the ledger, and then continues or stops:

- when rounds remain — `rounds-completed < rounds-chosen` — and no stop condition
  applies, the Coordinator starts the next round in the same turn: it records the
  round start in the dossier, runs the bounded round-start check (§3), creates the
  clock watcher (rules/timekeeping.md §6), and ends the turn with the next round's
  lifecycle line. a close that leaves rounds unrun is never a `round-closed` final
  message — the next round resumes and runs like any other;
- a stop condition is one of: (1) the count is reached — the close is the final
  close and the Coordinator reports the project state to the user (the user may
  extend the count); (2) a milestone is reached — the Coordinator writes the
  manuscript and winds down through the Formalizer's close (§11); (3) the steering
  stop of §8 — two consecutive rounds of full-unanimity rejection, after which the
  project does not start a third such round on its own; (4) the user says stop at
  any time — the run ends at the next close.

The user's per-close decisions never block the next round's start: seeing accepted
routes, recycle/park, and the pairing nominations are presented at the close and
stay pending. an unaccepted route defaults to park until the user decides (recorded
pending in the round-close record; a later recycle feeds the next round's Creator, a
park leaves it out of the auto-recycle); accepted routes the user has not yet seen
are held — the Producer marks a new version only after the user has seen it, and a
held route is not revised by the next round's route writer.

Context compaction between rounds: at each close with rounds remaining, the
Coordinator asks the user to run `/compact` with the locked instruction of
rules/timekeeping.md §7 — relayed verbatim — together with the decision list. the
request is recorded `pending-compact` in the round-close record and is
non-blocking, exactly like the other per-close decisions: if the user does not
compact, the next round starts anyway, and the Coordinator re-asks at the next
close. compaction is safe because every artifact is a file and the round resumes
from runtime/coordinator-state.md — it only stops the next round's turns from
re-reading the whole prior conversation.

## 7. Round-2+ scheduling — carried work first

At the start of a round, any carried-over work is handled first: the Selector resumes
queued route reviews and the Producer distributes the round's fresh summaries.

The Coordinator tracks the queue depth — the number of queued route reviews —
reports it in the round close, and may hint the
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
dependency-graph.json reachable from the established base (kernel axioms + Mathlib
theorems + [Formalized] pieces), with `#print axioms goalTheorem` containing no
non-kernel axiom, and a full manuscript claim requires the hired set empty and the
reachability proven in Lean. The
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
challenge finishes before a handover starts. a staled accepted route — the accepted-route watch of rules/formalizer.md (two consecutive lean-runner batches with no green [acceptedR] piece) — is demoted with the same mechanics the handover uses to retire a replaced PI: the Coordinator marks the abstract superseded in question-routes.md (a new version of the living map; the subfolder and all versions stay recorded, never deleted), supersedes the route PI's resume pack (runtime/<title>-pi-state.md), TaskStops the PI, and — when the staled route was the champion route — updates the champion-route pointer. the demotion runs once, on the Formalizer's stale signal (rules/coordinator.md §3), and the staled route is from then on no different from a stale route: revivable only through its stale entry's revival trigger.

## 11. The Formalizer wind-down

The Formalizer is a mandated part of the project: it always runs across rounds, and it
winds down only when the project ends. The Coordinator sees that it finishes its
existing work before closing: no new reports come in, the decompose workers finish
their pairs, the working swarm completes transforming the decomposed fragments, and
the lean code runner processes the remaining qmd pieces. The Formalizer is not bound
by the 138-minute budget, and a round close never cuts its swarm.
