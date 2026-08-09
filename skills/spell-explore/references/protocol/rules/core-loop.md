# Core loop — Creator → Producer → hygiene linter → examine → route

this file specifies the core loop of the round, in the construction plan's build order
(§5, step 2): the Creator (two independent phases) → the Producer (pairing + report) → the
hygiene linter (two layers) → the examine worker → the route with its title and PI. it
covers the first three windows of the 133-minute timeline — 0–20, 20–45, 45–58 — and the
stale loop that feeds the Creator's second phase. the Selector, the Formalizer, and the
Coordinator's regulation are specified in their own files; this file only defines the
handoffs into them.

the full round timeline (binding per-phase limits; the Selector windows belong to the
Selector's rules):

| window | phase | binding notes |
|---|---|---|
| 0–20 | Creator phase 1 | n idea-workers (0 ≤ n ≤ 8) think (≤10 min) + summaries (≤10 min); fresh summaries ready ~20 |
| 20–45 | Producer report worker (25 min) | paired summary + complement → idea report |
| 45–58 | hygiene linter (layer 1 ≈2 min, layer 2 ≈6 min) + examine worker (cap 5 min) | linter first, then examine; fail → stale |
| 58–98 | Selector panel (40 min) | workerA lists by 73; B/C/D review 58–88; exchange 88–98 |
| 98–113 | PI rebuts + change list; promoter in parallel | both feed the swarm |
| 113–133 | swarm (20 min) + resumed BCD (20 min) | accept ≥2/3 swarm AND ≥2/3 BCD; milestone = 9/9 + 3/3 + goal achieved |

## 0. binding rules that apply to the whole loop

- the round clock is hard: 2 hours and 13 minutes (133 minutes) total. the windows above
  are the binding per-phase limits; changing any of them means the 2-hour-and-13-minute
  budget no longer holds.
- a phase that reaches its window end is cut and its partial output recorded — the same
  rule as the 10-minute lemma cut — and the round closes atomically at 133 min even if a
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
  spawned has produced its artifact at the assigned path and the subcoordinator has
  verified the write. every other worker closes once its job is done. see
  rules/worker-lifespans.md for the hold-open connections.
- everything is versioned: every fresh summary, idea report, route, stale entry, reliable
  idea set entry and fragment region update carries a version (v1, v2, …); nothing is
  cited or built on without its version. the locked goal file is the exception: it is
  locked and the project never changes it.
- artifacts are files, and the subcoordinators guarantee them: every worker that produces
  an artifact is spawned with an explicit output path and must write its artifact there
  and confirm the write in its final message; a worker that cannot write — a read-only
  profile, or the external workerD — includes the complete artifact text in its final
  message and the responsible subcoordinator persists that text verbatim at the assigned
  path, marked "recovered from agent output". subcoordinators check that every artifact
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
regulates its own workers within its domain — idea generation and archiving — monitoring
their status, enforcing the time limits and the artifact rules, and solving issues inside
its territory. it is resumable.

the Creator has two phases, which are independent and may run at the same time:

- phase 1 — new-idea generation around the locked goal (window 0–20, on the critical path);
- phase 2 — mining of incoming material (off the critical path, in the background).

in rounds ≥ 2, when the Selector has unfinished work, the Creator runs at the same time:
it runs phase 1, whose workers look for ideas not in the idea pool, and phase 2 whenever
there are stale documents (summaries / reports / routes) from the other subcoordinators.

### 1.2 phase 1 — the think-and-rotate (window 0–20)

- at the start of the phase the Creator creates n idea-workers (0 ≤ n ≤ 8; the Creator
  chooses n per phase, and the two phases are independent) — called workers (lock this
  name: every subagent of a subcoordinator is called worker) — to actively think about
  new ideas (with maximal freedom) around the goal — the locked goal file — with maximal
  time length 10 min. the workers read the locked goal file and think; they may follow or
  not follow the persistence and verification protocols: their exploration is free-form,
  bound only by the time limits and the summary format.
- when the Creator receives all the ideas from the workers, it does not close the
  workers: it rotates the n ideas — the Creator holds all n idea-workers open from
  thinking through the rotation to the summaries: it waits for all n ideas before
  rotating and for all n summaries before archiving; no idea-worker closes mid-rotation
  — it hands the ideas of each worker to the next worker (idea of worker i goes to
  worker i+1, wrapping around; with n = 4 this is idea of worker 1234 given to worker
  4123) — and the workers learn from the idea they receive and write a summary. the rotation hands all n ideas at once and the workers write in
  parallel, so all n fresh summaries are ready by ~20 min. with n = 0 the phase produces
  nothing.
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
  a file (see §2); the Producer pairs it and processes the pair. the Creator never starts
  the handoff on a missing artifact.

### 1.3 phase 2 — the mining phase (off the critical path, in the background)

- trigger: whenever the Creator receives a summary or a report or an unsuccessful route —
  the corresponding subcoordinators automatically send stale material (see §5) — it runs
  phase 2.
- the Creator first makes n idea-workers (0 ≤ n ≤ 8, independent of the workers in
  phase 1) to search for good ideas / techniques in the received summary / report /
  route, and also in the reliable idea set and the fragment region in the dossier. this
  is at most 15 minutes.
- then, as in phase 1, the Creator rotates the n ideas: it hands the ideas of each worker
  to the next worker (idea of worker i goes to worker i+1, wrapping around), and the
  workers learn from the idea they receive and write a summary — at most 10 min, as in
  phase 1. with n = 0 the phase produces nothing.
- the Creator then archives the summaries properly in the idea pool in the dossier. these
  summaries are fresh: they are versioned like phase-1 output, live in the same
  `dossier/idea-pool/fresh-summaries/`, and enter the same pairing pool of the Producer.
- the persistence discipline binds the Creator's phase-2 workers: they read the dossier
  first, run the exploration loop (load → attack → record → update → next), and leave an
  attempts-log entry; a worker that cannot produce a good idea still returns a trial idea
  or a worked example instead of nothing (the minimum-output floor).
- failure-tagged summaries: when a report fails the examine, its source summaries are
  tagged with what was missing — the examine's sufficiency finding — so the next pairing
  deliberately fills the gap instead of repeating it. the tag is part of the summary
  record and is read by the Producer at pairing time.
- phase 2 is off the critical path and in the background: it runs at the same time as the
  Producer's report and the Selector's review, and is not counted inside the 0–20 /
  20–45 / 45–58 windows. a phase that reaches its own limits (15 min mining, 10 min
  summaries) is cut and its partial output recorded, like every other phase.

## 2. the Producer

### 2.1 the subcoordinator

the Producer does not produce anything: it regulates report and route production within
its domain — monitoring the report workers, enforcing time limits and artifact rules, and
solving issues inside its territory. it is resumable.

- whenever the Creator has a fresh summary ready, the Creator hands it to the Producer.
- at the start of a round any carried-over work is handled first: the Producer processes
  queued summary pairs.

### 2.2 pairing by complementarity

- the Producer pairs each fresh summary by complementarity — with another fresh summary,
  or with an obstruction and its closest technique from the fragment region — so the
  report is directed rather than random, and creates a worker to process the pair.
- the Producer maintains a goal-frontier score for every pool idea — how much of the
  locked goal's unproved structure the idea touches, measured by term overlap with the
  goal statement, the number of [Formalized] or [Hired] premises it can cite on the
  dependency tree's path toward the goal, whether the idea would hire new
  assumptions (fragments adjacent to unhired assumption nodes on the dependency
  tree score higher), and its provenance (revival-triggered or obstruction-
  touching fragments score higher) — and pairs the highest-scoring ideas first.
- when a revival trigger fires, its fragment jumps the pairing queue.
- the Producer prefers pairings that shrink the goal node's distance to the acceptable set
  on the dependency tree (see the Formalizer rule).
- the user may nominate which summaries or fragments to pair in the next round through the
  decision list; those nominations steer the pairing.

### 2.3 the report worker (window 20–45)

- the report-writing worker processes the pair with a time limit of 25 minutes, i.e. the
  20–45 window. it has full tools to write the report and is spawned with an explicit
  output path.
- the worker itself actively reviews the reliable idea set and the current dependency
  graph, and finds the interesting ideas according to its own reasoning about the
  summaries it received — the goal-frontier score guides the pairing but does not dictate
  the worker's synthesis.
- this worker will think about the ultimate problem strictly according to the paired
  summary and its complement, and writes an idea report (lock this name).
- the idea report should be well-organized with precise citations. it has to make clear
  promise about how to achieve the ultimate goal through its work (with confidence and
  evidence).
- when writing the report the worker can use whatever ideas archived in the dossier —
  including the fragments deposited by stale reports, summaries and routes (the stale
  rule, §5) — but the main core should be what's in the paired summary and its complement.
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
  to the linter.

### 2.4 the gates — the order is fixed

- when the report is done, the Producer runs the hygiene linter on it before anything
  else (linter layer 1 ≈ 2 min, layer 2 ≈ 6 min; §3).
- a report that does not pass the quick lint is stale: it does not move on, and the round
  produces no route from it (stale processing, §5).
- when the report has passed the hygiene linter, the Producer creates another worker — the
  examine worker — to judge sufficiency (§4), with a 5 min cap.
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

### 2.5 archive duties

- the Producer archives any route properly with versions (in `routes/`, project folder).
- the Producer deposits the fragments of the items it marks stale into the fragment region
  of the idea pool (§5).
- the Producer marks an accepted route a new version when the Selector accepts it (this
  happens after the Selector's verdict; see the Selector rule).

## 3. the hygiene linter

- the hygiene linter has two layers. it runs on each idea report before the examine
  worker, inside the 45–58 window: layer 1 ≈ 2 min, layer 2 ≈ 6 min, then the examine
  worker (cap 5 min).
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
    only mechanically transform the reports into the single qmd file and then into lean
    code, never identifying assumptions or judging the mathematics.
- a report that does not pass the quick lint is stale: it does not move on, and the round
  produces no route from it. the linter's finding is recorded as the failure reason in the
  stale marking.

## 4. the examine worker

- when the report is done and has passed the hygiene linter, the Producer creates another
  worker to examine the quality of this report and determine just one thing: is the
  material sufficient enough to become an approach? it does not judge the correctness of
  the idea.
- specifically it only checks:
  - whether the report contains accurate literature;
  - whether it gives good quality of statement and proofs (no immediate mistakes);
  - whether every claim carries a structurally complete proof attempt — every lemma, theorem and proposition has a proof present, no GAP markers, no claim without a proof;
  - whether it conveys the claims about the ultimate goal clearly;
  - whether the report is complete — without unfinished sentences, equations or diagrams.
- the examine procedure should be short: it has a 5 min limit, inside the 45–58 window,
  after the linter's two layers. the examine worker is read-only (Read/Grep) and quality-
  critical: it gets the primary model in the role mapping.
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
  name). the PI is resumable: the Producer holds it open when the report succeeds, and
  the Coordinator or the Selector re-invokes it (resume-by-ID) if the route is
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
  (workerA lists the evidence points by 73 min; workerB checks inconsistencies and
  readability; workerC hunts counterexamples; workerD is external and makes the overall
  judgement), the PI's rebuttal with a change list, and the decision swarm of ~9 workers
  with the resumed BCD reviewers, who each write review summaries (lock this name).
- the route is accepted if at least 2/3 of the swarm workers and at least 2/3 of the BCD
  reviewers agree — acceptance = ≥2/3 of the swarm workers AND ≥2/3 of the BCD reviewers.
- the project reaches a milestone only if all 9 swarm workers and all 3 BCD reviewers
  accept, and the accepted routes together achieve the locked goal. the milestone
  condition is exactly: 9/9 + 3/3 + accepted routes achieving the locked goal.
- at a milestone the Coordinator writes a report about it in PDF, called the manuscript
  (lock this name).
- only accepted routes are presented to the user; everything before that — fresh summary,
  idea report, route under review — is never treated as established.
- a [Formalized] idea in the reliable idea set is the exception: it may be cited by a
  report or a route as an established premise without further panel review, and cannot be
  overturned by a later round. [Formalized] premises are produced by the Formalizer: its
  decompose workers turn lint-grouped claims into the decomposed fragments, its mechanical
  swarm turns them into the single qmd file and then into lean code, and the lean code
  runner (lock this name) locks the green pieces in the qmd file, places their lean code
  in the reliable idea set (green lean codes are the only format in the reliable idea
  set), and marks hired assumptions as [Hired] on the dependency tree. the Producer's
  goal-frontier scoring reads this dependency tree, so the core loop and the Formalizer
  stay coupled.
