# Core loop — Creator → Producer → hygiene linter → examine → route

this file specifies the core loop of the round, in the construction plan's build order
(§5, step 2): the Creator (two independent phases) → the Producer (pairing + report) → the
hygiene linter (two layers) → the examine worker → the route with its title and PI. it
covers the first three windows of the 138-minute timeline (148 minutes from round 4) — 0–20, 20–45, 45–63 — and the
stale loop that feeds the Creator's second phase. the Selector, the Formalizer, and the
Coordinator's regulation are specified in their own files; this file only defines the
handoffs into them.

the full round timeline (binding per-phase limits; the Selector windows belong to the
Selector's rules):

| window | phase | binding notes |
|---|---|---|
| 0–20 | Creator phase 1 | n idea-workers (0 ≤ n ≤ 8) think (≤10 min) + summaries (≤10 min); fresh summaries ready ~20 |
| 20–45 | Producer report writers (25 min) | assigned fresh summaries → idea report |
| 45–63 | hygiene linter (layer 1 ≈3 min, layer 2 ≈7 min) + examine worker (cap 8 min) | linter first, then examine; fail → stale |
| 63–103 / 63–108 | Selector panel (40 / 45 min) | rounds 1–3 / from round 4: workerA lists by 78/83; B/C/D review 63–93/63–98; exchange 93–103/98–108 |
| 103–118 / 108–126 | PI rebuts (15 / 18 min) + change list; promoter in parallel | both feed the swarm |
| 118–138 / 126–148 | swarm (20 / 22 min) + resumed BCD (20 / 22 min) | accept ≥2/3 swarm AND ≥2/3 BCD; milestone = 3/3 + 3/3 + goal achieved |

## 0. binding rules that apply to the whole loop

- the round clock is hard: 2 hours and 18 minutes (138 minutes) total in rounds 1–2;
  round 3 runs 2 hours and 19 minutes (139 minutes) — the Producer's phase-2 writer
  spends 1 minute choosing its summary at the round's 20-min mark (§2.2) — and the
  windows after the choice shift +1: 21–46 (report), 46–64 (gates), 64–104 (panel),
  104–119 (PI + promoter), 119–139 (swarm + BCD); the panel internals shift with them
  (workerA's list by 79, B/C/D 64–94, exchange 94–104). from round 4 the round is
  extended +10 min: 148 minutes base, 149 minutes with the Producer's +1 shift (panel
  64–109, PI 109–127, swarm 127–149; workerA's list by 84, B/C/D 64–99, exchange
  99–109). the windows above are the binding per-phase limits; changing any of them
  means the round budget no longer holds.
- a phase that reaches its window end is cut and its partial output recorded — the same
  rule as the 10-minute lemma cut — and the round closes atomically at 138 min in rounds
  1–2, 139 min in round 3, and 149 min from round 4 even if a
  phase is mid-flight. a cut partial report is recorded, versioned, and does not move on
  to the linter.
- round timing is mandated: the round start is announced and written in the dossier before
  any agent spawns, phase start and end timestamps are recorded at each boundary in the
  phase-time table, and timestamps are never reconstructed after the fact. the round-1
  setup — the Coordinator asking for the rough idea and writing the locked goal file —
  happens before the round clock starts and is not counted in the budget.
- all subcoordinators run in the background, and the workers also work in the background:
  every subagent is spawned in the explicit background mode, never the blocking foreground.
- the subcoordinators, the PIs, and the lean code runner are resumable: each runs its
  phase to completion in one run and is resumed by the Coordinator for the next phase; a
  subcoordinator never returns early — its final message comes only after every worker it
  directs has produced its artifact at the assigned path and the subcoordinator has
  verified the write. the exception: the Creator's phase runs may end once their spawn requests are filed — the rotation and summary collection are Coordinator-owned (rules/worker-lifespans.md). every other worker closes once its job is done. see
  rules/worker-lifespans.md for the hold-open connections.
- everything is versioned: every fresh summary, idea report, route, stale entry, reliable
  idea set entry and fragment region update carries a version (v1, v2, …); nothing is
  cited or built on without its version. the locked goal file is the exception: it is
  locked and the project never changes it.
- artifacts are files, and the subcoordinators guarantee them: every worker that produces
  an artifact is spawned — by the Coordinator at its subcoordinator's request, or by its
  owner for a swarm — with the explicit output path its
  subcoordinator assigns and must write its artifact there and confirm the write in its
  final message; a worker that cannot write — a read-only
  profile — includes the complete artifact text in its final
  message and the responsible subcoordinator persists that text verbatim at the assigned
  path, marked "recovered from agent output"; the exterior workerD's reply is captured
  from the api response or codex stdout, delimited by standardized markers
  (modules/providers.md). subcoordinators check that every artifact
  exists after each worker completes, never start the next phase or handoff on a missing
  artifact, and transfer documents between stages only as files.
- the idea pool has a fixed well-known location in the dossier (resolved through the
  Knowledge State index after a split). it holds the fresh summaries, the reliable idea
  set with its [Formalized] markers, and the fragment region. no worker may delete
  anything in the idea pool: for workers it is append-only.
- the standard procedure of the project is a fixed sequence of stages: Creator → Producer
  → Selector. the Formalizer and the feedback lanes (failures and rejections marked stale,
  mined again by the Creator's second phase) branch off this main sequence.

file layout this loop writes to (construction plan §1): fresh summaries, the reliable idea
set and the fragment region live in the dossier's idea pool (`dossier/idea-pool/`); idea
reports in `reports/`; routes in `routes/`; stale entries in `stale/` — all versioned
files in the project folder, not the dossier.

## 1. the Creator

### 1.1 the subcoordinator

the Creator's job is to create ideas and archive. it does not create new ideas itself: it
regulates its own workers within its domain — idea generation and archiving — requesting
them from the Coordinator, monitoring their status, enforcing the time limits and the
artifact rules, and solving issues inside its territory. it is resumable. across round boundaries its context is bounded like the Coordinator's (rules/coordinator.md §3, the round-boundary bounded context): it closes at the round close and is spawned fresh at the next round from its resume pack (runtime/creator-state.md, file pointers only) — never resume-by-ID across rounds; resume-by-ID stays the within-round rotation path.

the Creator has two phases, which are independent and may run at the same time:

- phase 1 — new-idea generation around the locked goal (window 0–20, on the critical path);
- phase 2 — mining of the pool and the graph (off the critical path, in the background).

in rounds ≥ 2, when the Selector has unfinished work, the Creator runs at the same time:
it runs phase 1, whose workers look for ideas not in the idea pool, and phase 2 whenever
the idea pool has content — stale documents (summaries / reports / routes) from the other
subcoordinators, the reliable idea set, or the fragment region.

### 1.2 phase 1 — the think-and-rotate (window 0–20)

- at the start of the phase the Creator requests n idea-workers (0 ≤ n ≤ 8; the Creator
  chooses n per phase, and the two phases are independent; 4 is the standard phase-1
  size in rounds 1–2, and from round 3 the standard phase-1 size is n = 2; the
  freedom stays) from the Coordinator — called workers (lock this
  name: every subagent of a subcoordinator is called worker) — to actively think about
  new ideas (with maximal freedom) around the goal — the locked goal file — with maximal
  time length 10 min. the request is a file at runtime/requests/ naming the workers by their labels (c-1 idea-worker, c-2 miner, c-3 graph-worker), with their output paths and a pointer to each one's job brief at runtime/briefs/, which the Creator writes. the workers read the locked goal file and think; they may follow or
  not follow the persistence and verification protocols: their exploration is free-form,
  bound only by the time limits and the summary format.
- when all n idea files are in, the rotation is Coordinator-owned and mechanical: the
  Coordinator builds the per-worker rotation briefs at runtime/briefs/ — each carrying
  the preceding worker's idea (the idea of worker i goes to worker i+1, wrapping
  around; with n = 4 this is idea of worker 1234 given to worker 4123) — and resumes
  the workers (resume-by-ID, context preserved), who learn from the idea they receive
  and write a summary. the Coordinator holds all n idea-workers open from thinking
  through the rotation to the summaries — no idea-worker closes mid-rotation — and the
  Creator, resumed after the summaries land, verifies them before archiving. the rotation hands all n ideas
  at once and the workers write in parallel, so all n fresh summaries are ready by ~20
  min. with n = 0 the phase produces nothing.
- the workers have at most 10 min to write their summaries down. in the idea summaries,
  the workers point out the connection, the conflicts and the possible directions.
- the Creator then archives the summaries properly in the idea pool in the dossier, and
  these summaries are called the fresh summaries (lock this name).
- the fresh summary format (construction plan §4): id · idea · connections · conflicts ·
  possible directions · (round ≥ 2: novelty-checked vs the pool). each fresh summary is
  versioned and lives in `dossier/idea-pool/fresh-summaries/`.
- starting from round 2, the phase-1 workers know what is in the idea pool — the Creator
  supplies them the Knowledge State index — and must find ideas that do not exist in the
  pool, and not even ideas similar to the ones already archived. in round 1 there is no
  such constraint: the pool is empty, and the workers are free.
- handoff: whenever the Creator has a fresh summary ready, it hands it to the Producer as
  a file (see §2); the Producer distributes it with the round's split and processes it. the Creator never starts
  the handoff on a missing artifact.

### 1.3 phase 2 — the mining and graph phase (off the critical path, in the background)

- trigger: from round ≥ 2, phase 2 runs whenever the idea pool has content — the stale
  material the subcoordinators send automatically (a received summary, a report or an
  unsuccessful route, see §5), the reliable idea set, or the fragment region. in round 1
  the pool is empty and no stale material arrives, so phase 2 does not run.
- the Creator first requests 4 workers in rounds 1–2 and 2 workers from round 3 from
  the Coordinator (the 0 ≤ n ≤ 8 freedom stays: the Creator may choose fewer when the
  pool is thin, and n = 0 produces nothing; 4 is the standard phase-2 size in rounds
  1–2, 2 from round 3),
  independent of the workers in phase 1: in rounds 1–2 the split is 2 graph workers and
  2 regular miners — the 2-graph/2-miner split is the standard n = 4 — and from round 3
  it is 1 graph worker and 1 regular miner. for other n the Creator scales it: at most 2
  graph workers (1 from round 3) when dependency-graph.json has nodes, at least 1 miner
  when n > 1, and a single worker mines. the mining is at most 15 minutes.
- the regular miners search for good ideas / techniques in the received summary /
  report / route, and in the reliable idea set and the fragment region in the dossier.
  they may also read the connection report — the report, not only the connections section
  of formalizer/qmd-index.md — as material for their fresh summaries: each mark's proof
  state (`route-ref` | `full-argument` | `open`, the Selector rule §7.1) tells them which
  connections are already argued — borrow the technique when mining around the connected
  statements, opening the route's files (routes/; question-routes/<title>/ for an accepted
  route; the stale entry for a rejected one) — and which are open: mine toward the gap.
- the graph workers activate when formalizer/dependency-graph.json has nodes; before
  that — an empty graph — they mine as regular workers. a graph worker proposes bridging
  lemmas: connections (proofs) between assumption nodes of the dependency graph that
  shrink the goal node's distance to the established base. it reads only
  dependency-graph.json (the assumption nodes, the green edges, the [Hired] flags, the
  goal node), the reliable idea set and the Knowledge State index, binds the persistence
  and verification protocols, and its output is a fresh summary in the normal format.
- then, as in phase 1, the rotation is Coordinator-owned: when all n idea files are in,
  the Coordinator builds the per-worker rotation briefs (each carrying the preceding
  worker's idea — the idea of worker i goes to worker i+1, wrapping around) and resumes
  the n workers (resume-by-ID, context preserved), who learn from the idea they receive
  and write a summary — at most 10 min, as in phase 1. the Coordinator holds the n
  phase-2 workers open through the rotation, as in phase 1; the Creator is resumed after
  the summaries land. with n = 0 the phase produces
  nothing.
- the Creator then archives the summaries properly in the idea pool in the dossier. these
  summaries are fresh: they are versioned like phase-1 output, live in the same
  `dossier/idea-pool/fresh-summaries/`, and enter the same pairing pool of the Producer.
- the persistence discipline binds the Creator's phase-2 workers (the miners and the
  graph workers alike): they read the dossier first, run the exploration loop (load →
  attack → record → update → next), and leave an attempts-log entry; a worker that cannot
  produce a good idea still returns a trial idea or a worked example instead of nothing
  (the minimum-output floor).
- failure-tagged summaries: when a report fails the examine, its source summaries are
  tagged with what was missing — the examine's sufficiency finding — so the next pairing
  deliberately fills the gap instead of repeating it. the tag is part of the summary
  record and is read by the Producer at pairing time.
- phase 2 is off the critical path and in the background: it runs at the same time as the
  Producer's report and the Selector's review, and is not counted inside the 0–20 /
  20–45 / 45–63 windows. a phase that reaches its own limits (15 min mining, 10 min
  summaries) is cut and its partial output recorded, like every other phase.

## 2. the Producer

### 2.1 the subcoordinator

the Producer does not produce anything: it regulates report and route production within
its domain — monitoring the report workers, enforcing time limits and artifact rules, and
solving issues inside its territory. it is resumable. across round boundaries its context is bounded like the Coordinator's (rules/coordinator.md §3, the round-boundary bounded context): it closes at the round close and is spawned fresh at the next round from its resume pack (runtime/producer-state.md, file pointers only) — never resume-by-ID across rounds.

- whenever the Creator has a fresh summary ready, the Creator hands it to the Producer.
- at the start of a round any carried-over work is handled first: the Producer distributes
  the round's fresh summaries.

### 2.2 pairing by complementarity

- the Producer distributes the fresh summaries to its report writers — two in rounds 1–2
  and whenever the phase-2 lane is closed, one from round 3 when the lane is open —
  splitting them as evenly as possible (differing by at most one): a writer's assigned set
  may be completed by an obstruction and its closest technique from the fragment region,
  so the report is directed rather than random, and the Producer requests a report worker
  from the Coordinator for each writer's assigned set.
- the Producer maintains a goal-frontier score for every pool idea — how much of the
  locked goal's unproved structure the idea touches, measured by term overlap with the
  goal statement, the number of [Formalized] or [Hired] premises it can cite on the
  dependency tree's path toward the goal, whether the idea would hire new
  axiom-class nodes (fragments adjacent to unhired axiom-class nodes on the
  dependency tree score higher), the graph's hired ratio — the hired axiom-class
  nodes over the total nodes — as a connectivity measure (the more hired, the more
  of the graph's statements are derived from the established base), and its
  provenance (revival-triggered or obstruction-
  touching fragments score higher) — the measured terms enter the score with equal
  weight. — and, when the phase-2 lane is open, the 2 lowest-
  goal-frontier leftovers feed it (§2.4), and from round 3 the lane's writer chooses 0
  or 1 summary instead.
- every fresh summary is distributed in its round: the lane (when open) takes its share
  first, and the phase-1 writers split the rest as evenly as possible (differing by at
  most one); there is no queue for partials.
- backpressure: the Producer schedules a report writer on the critical path only while
  fewer than 2 routes are in review — the Selector runs at most two panels at a time, and
  a review needs 75 min in rounds 1–3 and 85 min from round 4; additional writers run off the critical path in the background.
  rationale: the Selector drains at most 2 reviews per round, so a critical-path
  writer is scheduled only while fewer than 2 routes are in review.
- rounds ≥ 3 variant: from round 3, 4 fresh summaries arrive per round: when the lane is
  open, phase 1 runs exactly one report writer and phase 2 runs exactly one route
  writer — the route writer has 1 minute to choose 0 or 1 summary closest to its
  accepted route, and the phase-1 writer takes the rest (4 or 3); when the lane is
  closed, the two phase-1 writers split the 4 summaries (2 each). the 1-minute choice is
  added to the round's total:
  round 3 runs 139 minutes, and from round 4 the rounds run 149 minutes (see §0, the timeline variant).
- when a revival trigger fires, its fragment jumps the pairing queue.
- the Producer prefers assigned sets that shrink the goal node's distance to the established base
  on the dependency tree (see the Formalizer rule).
- the user may nominate which summaries or fragments to pair in the next round through the
  decision list; those nominations steer the pairing.

### 2.3 the report worker (window 20–45)

- a phase-1 report writer processes its assigned summaries with a time limit of 25 minutes, i.e.
  the 20–45 window. it has full tools to write the report and is spawned by the
  Coordinator with the explicit output path its subcoordinator assigns.
- the worker itself actively reviews the reliable idea set and the current dependency
  graph, and finds the interesting ideas according to its own reasoning about the
  summaries it received — the goal-frontier score guides the grouping but does not
  dictate the worker's synthesis.
- this worker will think about the ultimate problem strictly according to its assigned summaries and
  their complement material from the pool, and writes an idea report (lock this name).
- the idea report should be well-organized with precise citations. it has to make clear
  promise about how to achieve the ultimate goal through its work (with confidence and
  evidence).
- when writing the report the worker can use whatever ideas archived in the dossier —
  including the fragments deposited by stale reports, summaries and routes (the stale
  rule, §5) — but the main core should be what's in its assigned summaries and their complement.
- the report writer must make sure that the definitions, lemmas and theorems are well
  stated and their assumptions explicitly given — otherwise the report will be difficult
  to pass the hygiene linter.
- the persistence discipline binds the Producer's report worker: dossier-first, the
  exploration loop, the attempts-log entry, and the minimum-output floor.
- the report must satisfy the linter layer 2's format (§3): for every claim, lemma,
  theorem and proposition a uniform structure statement → assumptions (explicit) →
  implications; groups of claims; precise citations; a clear promise about achieving the
  goal; complete — no unfinished sentences, equations or diagrams.
- the finished report is a versioned file in `reports/` (project folder, not the dossier).
  if the 20–45 window ends while the worker is mid-flight, the phase is cut and its
  partial output recorded (versioned, in the dossier); a partial report does not move on
  to the linter. a cut report is not lost: the Producer records the partial output
  (versioned) and the report is re-attempted as a background report.

### 2.4 the route-attached lane (Producer phase 2)

- a second lane opens only when (a) the Creator's phase 2 is on and (b) accepted routes
  exist; otherwise it stays closed and its share of summaries goes to the phase-1 writers with the round's split (§2.2).
- when open, the Producer requests one route-attached report worker from the Coordinator
  (the route-worker),
  anchored on one accepted route — older versions of accepted routes are preferred as the
  anchor, the champion-route pointer's route is excluded, and accepted routes the user has
  not yet seen are excluded as anchors — and hands it the remaining summaries per the
  transfer rule (§2.2): in rounds 1–2 the 2 lowest-goal-frontier leftovers; from
  round 3 the route-worker's 0-or-1 choice, the rest going to the phase-1 writer.
- the route-worker treats the accepted route as the main approach: its report is a
  revision that extends or strengthens the route toward the goal, integrating the two
  summaries as ideas. it goes through the same gates as the phase-1 writers — the hygiene
  linter and the examine worker (§2.5) — and its successful report is a new version
  (revision) of the anchored route, following the normal route path to the Selector.
- on acceptance this writer is the new PI of the route and performs the handover: the
  older PI closes and the new PI takes over as the route's defender (see
  rules/worker-lifespans.md).
- the lane is off the critical path like the Creator's phase 2: its worker runs in the
  background, has the same 25-minute report budget as the phase-1 writers, and is not
  counted inside the 20–45 / 45–63 windows.

### 2.5 the gates — the order is fixed

- when the report is done, the Producer runs the hygiene linter on it before anything
  else (linter layer 1 ≈ 3 min, layer 2 ≈ 7 min; §3).
- a report that does not pass the quick lint is stale: it does not move on, and the round
  produces no route from it (stale processing, §5).
- when the report has passed the hygiene linter, the Producer requests an examine worker
  from the Coordinator to judge sufficiency (§4), with an 8 min cap.
- gate timing: every report is gated — the phase-1 reports and the lane revision
  alike — and the order is always linter first, then examine. the 45–63 window binds only
  the critical-path report's gates; every other report's gates run in the background with
  the same per-gate caps (linter layer 1 ≈ 3 min, layer 2 ≈ 7 min, examine cap 8 min) and
  no window binding. gates for different reports run in parallel: each off-path report
  gets its own examine worker.
- if the examine fails: the report is unsuccessful; it is sent back to the Creator
  (processed in phase 2) and the worker who produced it is closed.
- if the examine passes: the report is successful and is renamed a route with a title (§6).
- an examine-failed lint-passed report is copied to the Formalizer by the Producer as
  soon as it is stale — its raw form is its final form. a lint-passed report that becomes
  a route is not copied at linter time: after the Selector's verdict, the Selector sends
  the accepted route — full form (the PI's modified route) or core form (the accepted
  salvageable core) — together with the promoter's nearest true version note to the
  Formalizer (the note as scoping metadata); a rejected route's pair is not sent to the
  Formalizer — it enriches the fragment region.

### 2.6 archive duties

- the Producer archives any route properly with versions (in `routes/`, project folder).
- the Producer deposits the fragments of the items it marks stale into the fragment region
  of the idea pool (§5).
- the Producer marks an accepted route a new version once the user has seen it, after
  the Selector accepts it (this
  happens after the Selector's verdict; see the Selector rule).

## 3. the hygiene linter

- the hygiene linter has two layers. it runs on each idea report before the examine
  worker: layer 1 ≈ 3 min, layer 2 ≈ 7 min, then the examine worker (cap 8 min). on the
  critical path the linter runs inside the 45–63 window; for off-critical-path reports
  the same per-layer caps apply in the background, with no window binding (§2.5).
- the linter is not a reviewer: it never judges the correctness of the mathematics, and
  layer 2 is never delegated to a swarm — the swarms are purely mechanical.
- layer 1 is a deterministic mechanical pass (no AI). it checks:
  - every citation resolves to a real source with a locator;
  - every claim made has its proof either inline or present in the dossier;
  - the locked names are used consistently;
  - numbers, brackets and constants are internally consistent.
- layer 2 produces the format (lock this name):
  - every claim, lemma, theorem and proposition has a uniform structure — a precise
    statement, its assumptions explicitly listed, and its implications;
  - it identifies the assumptions and implications of every claim in every lemma, theorem
    and proposition;
  - it groups them so that the decompose workers and the swarm workers in the Formalizer
    can easily process them — the decompose worker works on the groups of claims with
    their assumptions and implications as grouped by the linter's layer 2, and decomposes
    them properly into the decomposed fragments (lock this name).
  - layer 2 also has the duty to formalize the arguments and identify the assumptions of
    the claims: the Formalizer's swarms never identify assumptions themselves — they
    only mechanically write the reports' per-fragment files (the .qmd and .lean pieces) — the
    decompose worker plans the merge into the single qmd file (the Formalizer writes it) and the
    lean code runner converts them to lean code, never identifying assumptions or judging the mathematics.
- a report that does not pass the quick lint is stale: it does not move on, and the round
  produces no route from it. the linter's finding is recorded as the failure reason in the
  stale marking.

## 4. the examine worker

- when the report is done and has passed the hygiene linter, the Producer requests an
  examine worker from the Coordinator to examine the quality of this report and
  determine just one thing: is the
  material sufficient enough to become an approach? it does not judge the correctness of
  the idea.
- specifically it only checks:
  - whether the report contains accurate literature;
  - whether it gives good quality of statement and proofs (no immediate mistakes);
  - whether every claim carries a structurally complete proof attempt — every lemma, theorem and proposition has a proof present, no GAP markers, no claim without a proof;
  - whether it conveys the claims about the ultimate goal clearly;
  - whether the report is complete — without unfinished sentences, equations or diagrams.
- the examine procedure should be short: it has an 8 min limit, after the linter's two
  layers. on the critical path that cap sits inside the 45–63 window; for off-critical-
  path reports the 8 min cap applies with no window binding — the examine worker still
  examines one report per pass, and different reports are examined in parallel by
  separate examine workers (§2.5). the examine worker is read-only (Read/Grep) and
  quality-critical: it gets the primary model in the role mapping.
- this is the first independent review gate of the verification protocol: it checks
  sufficiency only and does not judge correctness — correctness is reviewed later by the
  Selector's panel.
- on success: the successful report is renamed a route with a title (§6).
- on failure: the unsuccessful report is sent back to the Creator for the second phase and
  the worker who produced the report is closed; the report's source summaries are tagged
  with what was missing — the examine's sufficiency finding — so the next pairing
  deliberately fills the gap instead of repeating it. an examine failure is a normal
  recorded outcome, not a dead end: the report is marked stale with the sufficiency
  finding as the failure reason (§5).

## 5. the stale rule — the loop back

- unsuccessful reports and their corresponding summaries, and unaccepted routes will be
  marked stale, and will automatically be sent to the Creator by the corresponding
  subcoordinators. in this loop: the Producer marks failed reports stale and sends them to
  the Creator; the Selector marks unaccepted routes stale (see the Selector rule).
- each stale marking records three things:
  1. the failure reason — sufficiency failed, or the panel findings that rejected it;
  2. a revival trigger — re-examine when <event>;
  3. the fragments of the work — the sub-results that still hold, the obstruction, and the
     closest technique.
- the fragments are archived in the fragment region (lock this name) of the idea pool in
  the dossier, so the Producer's report worker can use them like any other idea in the
  dossier: a future report builds on what survived instead of re-deriving it, and the
  Creator's second phase mines the fragments directly.
- when a route is rejected, the promoter's nearest-true-version note enriches the
  fragments sent to the Creator's second phase (see the Selector rule).
- the user decides on each unaccepted route: recycle it back to the Creator, or park it
  (the fragments are kept but it is not auto-recycled). failed reports (pre-route) are
  sent back to the Creator automatically.
- stale entries are versioned files in `stale/` (project folder). the Creator's phase 2
  processes whatever stale material arrives (summaries / reports / routes), together with
  the reliable idea set and the fragment region (§1.3).

## 6. the route, the title, the PI

- when the examine worker confirms sufficiency, the successful report will be renamed a
  route (lock this name) with a title (lock this name: title — to distinguish it from
  other routes). the route is a versioned file in `routes/`.
- the worker who produced a successful route will remain and be called the PI (lock this
  name). the PI is resumable: the Producer directs the Coordinator to hold it open when
  the report succeeds, and the Coordinator re-invokes it (resume-by-ID, on the Selector's instruction)
  if the route is
  challenged or revised in a later round — it defends the route in the review, rebuts
  the panel, and modifies the route (see the Selector rule).
- the Producer will archive any route properly with versions, and whenever the Producer
  has a fresh route, the Producer sends the route to the Selector (see the Selector rule
  for the panel, the review summaries, the swarm and the verdict).
- the title of an accepted route names its subfolder in the Coordinator's question-routes
  folder, where all artifacts related to that route are kept — the summaries, the idea
  reports, the route with its versions, and the review reports (see the Coordinator rule).
- an accepted route will be marked a new version by the Producer; an unaccepted route is
  sent back to the Creator for the second phase unless the user parks it.

## 7. the handoff to the Selector — the downstream contract

kept here so the core loop is self-contained; the Selector's rules specify the mechanics.

- the Selector reviews each fresh route as it becomes ready: the adversarial panel
  (workerA lists the evidence points by 78 min; workerB checks inconsistencies and
  readability; workerC hunts counterexamples; workerD is external and makes the overall
  judgement), the PI's rebuttal with a change list, and the decision swarm of 3 workers
  with the resumed BCD reviewers, who each write review summaries (lock this name).
- the route is accepted if at least 2/3 of the swarm workers and at least 2/3 of the BCD
  reviewers agree — acceptance = ≥2/3 of the swarm workers AND ≥2/3 of the BCD reviewers.
- the project reaches a milestone only if all 3 swarm workers and all 3 BCD reviewers
  accept, and the accepted routes together achieve the locked goal. the milestone
  condition is exactly: 3/3 + 3/3 + accepted routes achieving the locked goal.
- at a milestone the Coordinator writes a report about it in PDF, called the manuscript
  (lock this name).
- only accepted routes are presented to the user; everything before that — fresh summary,
  idea report, route under review — is never treated as established.
- a [Formalized] idea in the reliable idea set is the exception: it may be cited by a
  report or a route as an established premise without further panel review, and cannot be
  overturned by a later round. [Formalized] premises are produced by the Formalizer: its
  decompose workers turn lint-grouped claims into the decomposed fragments, its mechanical
  swarm writes their per-fragment files (.qmd and .lean pieces), the lean code runner
  merges them into the single qmd file and converts them to lean code, and the lean code
  runner (lock this name) locks the green pieces in the qmd file, places their lean code
  in the reliable idea set (green lean codes are the only format in the reliable idea
  set), and marks hired assumptions as [Hired] on the dependency tree. the Producer's
  goal-frontier scoring reads this dependency tree, so the core loop and the Formalizer
  stay coupled.

## 8. file ownership — one writer per path

parallel background agents appending the same file interleave or lose writes, so each
shared path has one writer/appender:

- `dossier/attempts-log.md` — workers hand their entries in their final message; the
  owning subcoordinator appends (the Creator for the phase-2 workers, the Producer for
  the report workers).
- `dossier/verification-ledger.md` — appended by the subcoordinator whose review
  resolved: the Producer (examine verdict), the Selector (panel/swarm verdicts), the
  Formalizer (green/[Formalized] results).
- `dossier/idea-pool/fresh-summaries/` — the Creator only (single writer): it archives
  there the summaries its phase-1 and phase-2 workers produce.
- `dossier/idea-pool/reliable-idea-set/` — the lean code runner only (single writer):
  green lean codes are the only format in the reliable idea set.
- `dossier/idea-pool/fragment-region/` — the Producer (stale reports), the Selector
  (stale routes), the Formalizer (cut decompose work, swarm 5-min tails): each writes
  only its own entries, subcoordinator-mediated.
- `formalizer/qmd-index.md` — the lean code runner only.
- `formalizer/single.qmd` — the Formalizer writes the merge planned by the decompose
  worker (single writer for the merge); the connection annotation lines are the one exception — appended
  by the Selector's re-invoked promoter at the marked blocks (the Selector rule §7.1) and
  verified by the Selector by file; they are annotations, never content, and the merge
  never removes locked content.
- `version-inventory.md` — each owner appends its own rows.

no worker ever appends a shared file directly; a worker that must contribute to a shared
file hands the entry to its subcoordinator in its final message, and the subcoordinator
persists it verbatim.
