# Formalizer rule

this rule specifies the fourth subcoordinator, the Formalizer: what it receives, how it
decomposes idea reports into the decomposed fragments, how the purely mechanical working
swarm turns them into per-fragment files, how the decompose worker plans the merge and the
Formalizer writes it into the single qmd file, how the lean code runner locks green pieces and builds the dependency tree, and what it outputs —
the reliable idea set and the fragment region. it is authoritative on the Formalizer's territory and consistent
with planning-ideas-no-push.md (the locked spec) and construction-plan.md §1 and §5 — construction-plan §1's tree now includes `formalizer/fragments/` (the per-fragment files) and `formalizer/qmd-index.md` (the id list), updated in construction-plan.md by this group. the role of the
Formalizer in the whole project is subordinated to the Coordinator, which regulates all four
subcoordinators and enforces the 138-minute round timeline (0–20, 20–45, 45–63, 63–103,
103–118, 118–138) — the Formalizer is not bound by it.

## territory and lifecycle

the Formalizer is a subcoordinator. like the other subcoordinators it does not do the work
itself: it regulates its own workers within formalization — the decompose workers, the
working swarm, and the lean code runner — monitoring their status, enforcing the time limits
and the artifact rules, and solving issues inside its territory, while the Coordinator
regulates the Formalizer. every worker it directs is spawned by the Coordinator in the
explicit background mode, never the blocking foreground; the working swarm is the
Formalizer's own and is spawned by it in the explicit background mode. the Formalizer
is resumable: it runs each phase to completion in one run — waiting for every worker's artifact before returning — and is resumed by the Coordinator for the next phase; it never returns early, and a narrated step is not a done step. the lean code runner is resumable the same way within the Formalizer's territory (see
below).

the Formalizer runs in the background across rounds: it is not bound by the 2-hour-and-18-
minute round budget — its decompose workers run per pair of reports at any time, off the
critical path of the round timeline (0–20 the Creator's phase 1, 20–45 the Producer's report,
45–63 the hygiene linter and the examine worker, 63–103 the Selector's panel, 103–118 the PI's
rebuttal and the promoter, 118–138 the Selector's swarm, the resumed BCD reviewers and the
re-invoked promoter's connection marking), and
the Coordinator resumes the lean code runner once per round at the round start — batched,
never on every qmd file update — subject to the run-or-postpone user gate (the lean code
runner section below); fragments that land mid-round wait for the next resumption. the
reliable idea set and the fragment region
grow continuously across rounds, and a round close never cuts the swarm. the Formalizer has
no overall time budget: only the decompose workers and the swarm agents carry time limits.
across round boundaries the Formalizer's context is bounded like the other
subcoordinators' (rules/coordinator.md §3, the round-boundary bounded context), with
the in-flight exception: it requests the round-boundary fresh spawn only when its
territory is idle — no worker in flight (the working swarm complete, the lean code
runner not mid-batch) and no pending decompose units — otherwise it yields
children-in-flight and requests the close at the next natural boundary; the Coordinator
never TaskStops it mid-flight. a round close never cuts the swarm, and the reliable
idea set, the fragment region, the qmd file and the dependency graph live in the files,
so a fresh context loses nothing.

the Formalizer winds down only when the project ends: it finishes its existing work — no new
reports come in, the working swarm completes, and the lean code runner processes the
remaining qmd pieces — before it closes. the project ends when it reaches a milestone: all 3
swarm workers and all 3 BCD reviewers accept and the accepted routes together achieve the
locked goal (see the Selector rule for the acceptance thresholds: a route is accepted with at
least 2/3 of the swarm workers and at least 2/3 of the BCD reviewers agreeing; full consensus
3/3 + 3/3 is the milestone). on the formalization side, the locked goal being achieved means the goal node is reachable from
the established base — kernel + mathlib + formalized — and `#print axioms goalTheorem` contains
no non-kernel axiom; a full manuscript claim requires the hired set empty and the reachability
proven in lean. when the milestone is reached the Coordinator writes a report in PDF, called the
manuscript, and maintains the question-routes folder, which holds a copy of the full reliable
idea set.

## inputs: verdict-aware

the Formalizer's inputs are verdict-aware. a lint-passed report that fails the examine
worker is copied to it by the Producer as soon as it is stale — its raw form is its final
form. a lint-passed report that becomes a route is not copied at linter time: after the
Selector's verdict, the Selector sends the accepted route — full form (the PI's modified
route) or core form (the accepted salvageable core) — together with the promoter's nearest
true version note and the promoter's connection report (§7.1 of the Selector rule); a rejected route's pair enriches the fragment region instead. a unit that is an accepted route — full or core form — is decomposed with every piece marked [acceptedR] (lock this name): the piece-provenance marker the decompose plan carries and the working swarm writes on the qmd piece, so the lean code runner can trace every piece back to its accepted route (the accepted-route watch below). the
promoter's note is scoping metadata for the decompose workers: it marks the honest core to
formalize and the exact breaking point (an obstruction in the fragment region and the
obstructions register), and the note itself is never decomposed. the connection report is
scoping metadata of the same kind, and it is an input to the decompose worker: it names
the pairs of existing statements in single.qmd that the route's results or techniques
bridge, and the decompose worker schedules them — a `full-argument` pair as a proof
fragment (the swarm transcribes the written argument verbatim), a `route-ref` pair as a
plain import edge, and an `open` pair annotation-only, recorded for the PI (the
Formalizer surfaces it at revision time), never scheduled. a scheduled proof fragment
carries `[proves: X → Y via <route> v<n>]`; when the lean code runner verifies it green
it records a `proves` edge — the first green→green edge class — in the dependency graph
and logs the pair in `formalizer/connection-proofs.md`, the registry the runner
maintains (rules below). there is no limit on the
number of inputs the Formalizer can take: every two units — a lint-passed examine-failed
report, or an accepted route with its note — the Formalizer requests a decompose worker
from the Coordinator.

the Formalizer relies on the linter's layer 2, which produces the format: every claim, lemma,
theorem and proposition has a uniform structure — a precise statement, its assumptions
explicitly listed, and its implications — and the linter identifies the assumptions and
implications of every claim and groups them, so that the decompose workers and the swarm
workers in the Formalizer can easily process them. the hygiene linter has the duty to
formalize the arguments and identify the assumptions of the claims; the swarms are purely
mechanical — they only transform the reports into per-fragment files under
`formalizer/fragments/` that the decompose worker plans to merge into the single qmd file
(the Formalizer writes the merge), never identifying assumptions or judging the mathematics.

## the decompose workers

the Formalizer requests a decompose worker from the Coordinator for every two units — a
unit being a lint-passed examine-failed report, or an accepted route with its
promoter's note. the decompose worker:

1. identifies the groups of claims with their assumptions and implications, as grouped by the
   linter's layer 2 — the format already gives each claim its statement, its explicit
   assumptions and its implications, grouped so the decomposition is mechanical rather than
   interpretive;
2. decomposes them properly into the decomposed fragments (lock this name) — individual
   pieces small enough for a swarm worker to formalize in the 10-minute lemma cut;
3. plans how to distribute the work to the swarm workers — which decomposed fragment goes to
   which worker, in which order, so the swarm works in parallel without duplicating or
   conflicting claims; when the unit is an accepted route (full or core form), the plan marks
   every piece [acceptedR: <route title> v<n>] — the piece-provenance marker the swarm writes
   on the qmd piece;
4. classifies every assumption it names — mathlib vs axiom — preferring the mathlib statement
   when one exists, and records a documented "no Mathlib equivalent" justification for every
   declared axiom; the Formalizer files those justifications in the hireable registry;
5. after the working swarm finishes, produces the merge plan: the completed per-fragment
   `.qmd` pieces in deterministic order by fragment id (`partial/` never merged), with the
   `formalizer/qmd-index.md` update — the appended ids of the newly merged pieces, the
   connection annotations of single.qmd mirrored into the connections section of the index,
   and a similarity section mirroring its [Similar] annotations, so the working swarm and
   the Creator's phase-2 workers are notified by ids — the Formalizer writes the merge into
   `formalizer/single.qmd` and `formalizer/qmd-index.md` exactly as planned, a mechanical
   assembly of the same class as the swarm's transcription;
6. writes a `[Similar: <green id>]` annotation in the merge plan on each merged non-green piece
   whose proof text resembles a green piece's proof text but is not mechanically the same —
   the comparison is local (the merged piece vs the green pool in single.qmd / the reliable
   idea set), proof-text similarity is the index, the most similar green id wins; `[Similar]`
   is an annotation, never a dependency-graph edge, never a claim of equivalence;
7. schedules the connection report's pairs when the unit carries one: a `full-argument` pair
   as a proof fragment — the swarm transcribes the written argument verbatim — carrying
   `[proves: X → Y via <route> v<n>]`; a `route-ref` pair as a plain import edge; an `open`
   pair annotation-only, recorded for the PI (the Formalizer surfaces it at revision time),
   never scheduled.

the decomposed fragments are thrown to the working swarm of ~4 workers — the
Formalizer's own swarm, spawned and regulated by it. a unit that waits
more than ten minutes without a proper pair moves to the next step on its own: the Formalizer
holds incoming reports up to 10 minutes for a complement, and if none arrives the unpaired
report is decomposed singly — the 10-minute unpaired timeout, the same value as the
decompose worker's own limit.

a decompose worker has 10 minutes per pair of reports. on overrun it is cut and whatever it
produced is sent to the fragment region: the partial decomposition is recorded there, marked
unfinished, so nothing is lost and a future worker can pick it up. at most one decompose pair runs at a time. the decomposed fragments
produced on time are thrown to the working swarm; their distribution plan goes with them.

## the working swarm (purely mechanical)

the working swarm of ~4 workers is purely mechanical: it does not judge the mathematics, and
it never identifies assumptions — that duty belongs to the hygiene linter (layer 2) and to
the decompose workers. the swarm only mechanically transforms each decomposed fragment into
its per-fragment files under `formalizer/fragments/<fragment-id>/` — the `.qmd` piece in
qmd-prover form and the `.lean` piece — and reports the written paths in its final message;
it never merges them. the merge into the single qmd file is planned deterministically by the
decompose worker and written by the Formalizer, ordered by fragment id. there is only one qmd file in
the whole project: the Formalizer's single qmd file lives in the project folder at
`formalizer/single.qmd`. the swarm does not run qmd-prover. this working swarm is unrelated to
the lean code runner's own swarm, which executes the lean code runner's planned verification
jobs (see below).

the swarm's rules:

- **bounded briefs.** the swarm is purely mechanical, so its workers need only the
  material they transform: each working-swarm agent is spawned (or resumed) with a
  compact job brief — the decomposed fragment (or the packaged relay), the locked
  per-fragment format (the .qmd piece in qmd-prover form and the .lean piece), the
  placement index (qmd-index.md — the id list, not the whole qmd file), and its
  output path — and nothing else. it never loads the whole single.qmd, the
  generated lean tree, or the dependency graph into its context; those belong to
  the lean code runner. a swarm agent that over-reads beyond its brief is
  corrected by the Formalizer (the context economy rule, rules/coordinator.md §3).
- **single qmd file.** there is only one qmd file in the project — `formalizer/single.qmd` —
  and the swarm never writes parallel qmd files: each transformed fragment becomes its own
  per-fragment files under `formalizer/fragments/<fragment-id>/`, and the decompose worker
  plans the merge into the one qmd file (the Formalizer writes it), ordered by fragment id. single.qmd
  may also carry annotation lines — `<!-- connection: [<route title>-T-<id>] … -->`
  and `[<route title>-F-<id>]` marks, written by the Selector's re-invoked promoter during the
  118–138 window (the Selector rule §7.1), and `[Similar: <green id>]` marks, written by the
  decompose worker at merge (the decompose workers above): they are annotations (provenance),
  never content — they never change a block's statement, and the merge appends per-fragment
  pieces ordered by fragment id and never removes locked content, so they survive; the lean
  conversion ignores comments, so they never change the mathematics. single-writer ordering:
  the Formalizer writes the decompose worker's merge plan within the round and the lean code
  runner locks green pieces at the next round start — the two never write in the same turn,
  and every write bumps the single.qmd version.
- **similar facts placed closely.** each worker reads `formalizer/qmd-index.md` — the id list
  of the lemmas, definitions and theorems already in single.qmd, not the whole qmd file — and
  decides its placement from that list: a fragment whose facts resemble ids already in the
  index is written to sit next to its relatives, so the qmd file grows as one coherent body
  instead of scattered pieces. the decompose worker maintains qmd-index.md on every merge,
  appending the ids of the newly merged pieces, mirroring the connection annotations of
  single.qmd into a connections section of the index (id → the `[<route title>-T-<id>]` /
  `[<route title>-F-<id>]` marks attached to it) and writing a similarity section mirroring
  the [Similar] annotations, so the working swarm and the Creator's phase-2 workers see the
  route bridges and the similarity marks without loading single.qmd.
- **writes lean code.** the swarm converts each decomposed fragment into the qmd piece and
  then into the lean piece, both written as per-fragment files under
  `formalizer/fragments/<fragment-id>/`, and reports the written paths in its final message;
  the lean code runner picks them up and runs them (see the artifact layout below).
- **writes the [acceptedR] marker.** when the decomposition plan marks a piece [acceptedR: <route title> v<n>], the swarm writes that marker as a metadata line in the per-fragment `.qmd` piece (the `.lean` piece is unchanged, so it keeps compiling); the marker is provenance, never content — it does not change the mathematics.
- **prefer mathlib over declared axioms.** the swarm writes the lean pieces importing mathlib
  for any classical result that exists there — it never declares an axiom for something mathlib
  proves; an unavoidable declared axiom sits in a clearly flagged section with its "no Mathlib
  equivalent" justification comment, which the Formalizer files in the hireable registry.
- **10-minute lemma cut with relay.** whenever a swarm worker's job runs more than 10 minutes, it
  packages the partial work and waits for another swarm worker that has already done its job to
  take it over — the relay restarts the 10-minute clock on the receiving worker; the Formalizer enforces the 1-minute timeout: if no such
  worker appears within 1 minute, the packaged partial work is sent to the fragment region. a
  phase that reaches its window end is cut and its partial output recorded — the same
  cut-and-record rule.
- **30-minute life, resumable in-window.** any swarm agent lives for 30 minutes and is
  resumable within that window: a resumed agent keeps its context and continues; after the 30
  minutes it closes.
- **fragment clustering throughout its life.** throughout its life the swarm agent updates the
  fragments in the dossier and clusters similar fragments, so related bits stay together in
  the fragment region.
- **5-minute tail.** in the last 5 minutes of its life the agent sends its remaining
  unformalized work — the bits it could not formalize within its time limit — to the fragment
  region in the dossier and clusters them there, so nothing is lost and a future worker can
  pick them up. the formalized work has already been written as its per-fragment files; the
  merge into the single qmd file is done by the decompose worker and the green count by the
  lean code runner, not by the swarm.

## the lean code runner (lock this name)

the Formalizer requests the lean code runner from the Coordinator; like the subcoordinators and the PIs it is resumed by the Coordinator once per round at the round start — batched, never on every qmd file update — and restored after a session resume; it does not wake on its own. the run-or-postpone gate: at the round start, when landed-but-unintegrated per-fragment files exist under formalizer/fragments/ (or the runner is recorded paused with pending units) and the runner is not already active, the Coordinator decides per the runner-mode chosen at round 1 — in manual mode it asks the user whether to run the runner now or postpone it to the next round; in auto mode it automatically chooses 'run' without asking. on 'run' the Coordinator clears the pause and resumes the runner in the background — one resumption per round, fragments that land mid-round wait for the next one; on a manual 'postpone' the Coordinator records `paused: round N` in the worker registry and the Formalizer mirrors it in its resume pack (runtime/formalizer-state.md) with the pending units, and the runner is not resumed on any trigger while paused — the Formalizer re-requests it at the next round start, where the gate applies again. it plans in advance: on every resumption it reads its previous batch report, the qmd-index tail (the ids merged since the last resumption) and the dependency graph (the not-green pieces and the reverse-edge closure of the new pieces) to build a forward plan of the mechanical verification jobs — which lean code to run, which pieces to
green-check, and in what order, preferring the pieces that shrink the goal node's distance
to the established base. the plan covers only the delta since the last resumption: the
pieces merged since the last resumption (the ids appended to qmd-index.md), the pieces
that were not green at the last resumption (a missing premise may now be proved by the new
pieces), and the pieces whose premise set the new pieces extend (the dependency graph's
reverse edges). pieces already locked green are never re-dispatched — a locked green
piece's lean code is fixed in the reliable idea set and its premises (kernel, mathlib,
[Formalized]) are fixed, so it cannot turn ungreen, and re-running it would only re-read
the same context for nothing. the mechanical compile (qmd-prover on single.qmd)
still runs on the full file; the swarm jobs — which carry the agent-turn cost — run only
on the delta. its duties, in order, on every resumption:

1. **refresh the lean code.** it converts the merged single qmd file into ONE append-only
   lean file, `formalizer/lean/single.lean` — running qmd-prover on `formalizer/single.qmd`
   as the mechanical step — so the verification jobs run the current lean code; later rounds
   only ADD new lean code, never rewriting locked green sections. single.lean carries
   mandatory section markers per div (the existing `-- ====` header blocks), and a 1:1
   correspondence registry maps every qmd div id to its lean declaration, recording each
   div's line range in single.lean so the swarm can copy a local part; the per-fragment lean
   files keep their role as the swarm's working copies, and single.lean is the canonical
   compile and analysis base. the decompose worker mirrors its own [Similar] annotations
   in single.qmd into a similarity section of `formalizer/qmd-index.md` at merge — the
   notification channel for the miners and the Creator's phase-2 workers; the runner never
   claims equivalence, and a missing [Similar] means nothing.
2. **unify the symbols and maintain the symbol list.** when single.lean holds more than 10
   lean codes, it unifies the symbols — pure renames only, below — and writes
   `formalizer/symbol-list.md` from `templates/symbol-list.md`: every symbol with its precise
   definition, centralizing the per-fragment "Mathlib bridge" notes. all the other workers —
   idea workers, writers, reviewers, decompose, swarm — use the symbols as defined in the
   list and propose new symbols when they need one; the new-symbol intake is the worker
   carrying the definition comment in its piece and the runner adding it to the list at its
   next resumption, and the linters accept `proposed` symbols, not violations. green lean
   code may be RENAMED (pure renames only) as part of the unification: a rename is atomic,
   compile-verified, and rolled back on failure — it never changes the mathematics, and a
   green piece stays green. the rename log (old → new) lives in the symbol list, and a
   rename syncs the green archive in the reliable idea set (the [Formalized] lean copies),
   `axioms-<piece>.txt`, `hireable-registry.md` and the 1:1 registry — all updated together,
   each with a version bump; a [Similar] mark's target follows the rename log. model merging
   (two pieces modelling one object) is NOT a rename: it is mathematics and goes through the
   route pipeline, never the runner.
3. **plan and distribute.** it distributes the planned verification jobs to its own swarm
   agents — whatever number the plan requires, at most 3. its swarm is
   its own: the lean code runner spawns and regulates it, and the Coordinator does not
   intervene. the lean code runner's
   swarm is unrelated to the working swarm of the decompose workers: the working swarm
   transforms the decomposed fragments into per-fragment files — the qmd piece and the lean
   piece per fragment; the lean code runner's swarm executes the planned verification jobs
   (copying the assigned piece plus its dependency closure from single.lean into a new
   temporary lean file and compiling there — single.lean itself stays untouched by the swarm
   — counting the green theorems, and running
   `#print axioms <theoremName>` on each green theorem) and reports the green pieces with their
   lean code, their axiom footprint and their dependency edges.
4. **lock green pieces.** whenever a qmd piece is lean-green, the lean code runner locks that
   piece in the qmd file — green pieces are locked in place, never removed — and places the
   corresponding lean code in the reliable idea set (lock this name), which lives in the same
   place as the idea pool in the dossier (`dossier/idea-pool/`), recording the piece's
   `#print axioms` footprint in its reliable idea set entry; when a [Similar]-marked piece
   turns green it retires the mark at lock time. so the reliable idea set holds
   the formalized pieces as lean code, and the qmd file keeps the green pieces locked in
   place.
5. **build and update the dependency tree.** the lean code runner is responsible for building
   and updating a dependency tree, stored as the dependency graph in the project folder at
   `formalizer/dependency-graph.json` (schema v2), built from the single file:
   - every statement — in the lean code format, not qmd — is a node whose identity is its div
     id, stable across renames, carrying its lean declaration name as an attribute — a rename
     updates the attribute, never the node id — and a status class (`kernel` | `mathlib` |
     `formalized` | `axiom` | `goal`) and a status (`formalized` | `hired` | `axiom` |
     `base` | `goal`);
   - every green lean code contributes a directed edge — "the proof of the conclusion
     references the premise" — extracted from lean, not from qmd `@id` citations: the runner
     runs `#print axioms <theoremName>` on every green piece and classifies each name in the
     result — kernel axiom names are acceptable base; mathlib theorem names resolve
     transitively to kernel axioms and are acceptable (established by compilation — never to
     be hired); declared axiom names must exist in the project's hireable registry, and the
     piece is green modulo that axiom; each edge carries `source: lean-axioms`;
   - an axiom-class node becomes [Hired] iff some green lean code whose conclusion is that
     node's statement is implied by the established nodes — i.e. the axiom is now derivable
     and could be replaced by a proof, and `#print axioms` on the new proof no longer lists
     it — the runner marks [Hired] in single.lean as an annotation at the same time;
     axiom-class nodes are never [Formalized];
   - the main goal is a distinguished node of this tree;
   - the dependency graph is updated whenever there is a new green lean code, adding the nodes
     and edges of that green proof, with the piece's `#print axioms` footprint recorded in the
     graph; when a scheduled proof fragment carrying `[proves: X → Y via <route> v<n>]` is
     verified green, the runner records a `proves` edge — the first green→green edge class —
     from the pair in the graph and logs it in `formalizer/connection-proofs.md`, the
     registry it maintains. the graph itself stays `formalizer/dependency-graph.json`;
     [Similar] is not an edge class — the proves edges are the only new edge class.
6. **update the accepted-route watch.** at its resumption it reads the [acceptedR] markers from single.qmd and records the piece ids under their accepted routes in `formalizer/accepted-routes.md`, and at the end of each batch it updates the per-route green counts and flags the stale trigger; the [no-green] marking, clearing, surfacing and the stale signal are the Formalizer's (the accepted-route watch section below).

the lean code runner is not the judge of the mathematics either: it plans, distributes and
integrates — its swarm agents run the code and green-count, and it locks what is green and
records the edges; its swarm agents are purely mechanical as well. the best outcome for the
project is a green lean
code that connects the goal node to the established base — the goal is reachable from kernel +
mathlib + formalized, with `#print axioms goalTheorem` containing no non-kernel axiom — and the
Producer prefers pairings that shrink the goal node's distance to the established base (the
Producer's goal-frontier score counts the established premises an idea can cite on the
dependency tree's path toward the goal — kernel, mathlib, formalized, and hired axioms — and
rewards ideas that would hire a declared axiom: derive it from the established base).

## the accepted-route watch and the stale signal (lock this name)

the Formalizer watches the lean formalization of every accepted route (full or core form).
the watch registry is `formalizer/accepted-routes.md` (versioned): per accepted route —
title and version — the ids of its [acceptedR] pieces merged into single.qmd, the green
count over the total, the watch state (`none | no-green`), and whether the route's writer
was warned. a route enters the watch when its first [acceptedR] piece is merged.

at the end of every lean code runner batch — after the merge, the verification and the
green-locking — the Formalizer tallies: for each accepted route in the watch, the number of
[acceptedR] pieces whose lean code is green. the tally joins the formalization status line
(status reporting below). the transitions, per route:

- **≥1 piece green** → clear the [no-green] marker if set; the route remains accepted; the [no-green] marker is cleared — a green batch in between saves the route;
- **0 pieces green and no [no-green] marker** → first no-green batch: mark the route
  [no-green] (lock this name) in the watch registry and the status line, and the Coordinator
  tells the Producer to warn the route's writer — the Producer writes a dated warning note
  into question-routes/<title>/ and flags it in the route PI's resume pack
  (runtime/<title>-pi-state.md); the Coordinator surfaces the marker to the user. the route
  remains accepted;
- **0 pieces green and the [no-green] marker already set** → second consecutive no-green
  batch: the route is stale. the Formalizer writes the stale signal to
  runtime/stale-signals/<route-title>.md in the locked format (kind: stale-signal ·
  requester: formalizer · route and version · the tally: total [acceptedR] pieces, green
  count, the two batch dates · the piece ids), **before it ends** — the signal is written and
  stated in its final message, never left for a later run.

the Coordinator receives the signal, delegates the stale marking (rules/coordinator.md §3),
and completes the demotion by the end of the round; the stale-signal file carries the status
line (received | delegated | done) the Coordinator appends as it processes it. a staled
accepted route is no different from a stale route: the stale entry (templates/stale-entry.md)
with its fragments archived in the fragment region, its abstract superseded in
question-routes.md, its defender PI retired — and revivable only through the stale entry's
revival trigger.

## outputs

### the reliable idea set (lock this name)

- the reliable idea set consists of the ideas that are lean-verified under the Formalizer.
- locked protocol rule: green lean codes are the only format in the reliable idea set — only
  pieces that the lean code runner has counted as green are placed there, and only as lean
  code.
- each idea in the reliable idea set carries the special marker [Formalized].
- a [Formalized] idea may be cited by a report or a route as an established premise without
  further panel review: like Spell v1's formalized lemma, it cannot be overturned by a later
  round. this is the formalization side of the verification protocol — a [Formalized] idea in
  the reliable idea set is an additional premise channel, established without further panel
  review.
- the reliable idea set lives in the same place as the idea pool in the dossier
  (`dossier/idea-pool/`); the lean code runner places it there. the Coordinator keeps a copy of
  the full reliable idea set as a file in the question-routes folder.
- each [Formalized] idea's entry records its `#print axioms` footprint: the names its green
  lean code depends on beyond the kernel, each classified as mathlib (acceptable, established
  by compilation — never to be hired) or a declared axiom (green modulo that axiom, filed in
  the hireable registry); the same footprint is recorded in the dependency graph.
- the lean formalization does not have to be fully based on mathlib — a declared axiom is
  allowed only with a documented "no Mathlib equivalent" justification filed in the hireable
  registry, and mathlib imports are preferred for any classical result that exists there:
  what matters is that the piece is green under the lean code runner — it compiles and its
  `#print axioms` footprint contains only kernel axioms, mathlib names and hireable-registry
  names.

### the fragment region (lock this name)

- the fragment region is part of the idea pool in the dossier (`dossier/idea-pool/`); the
  Formalizer deposits it there, alongside the fresh summaries; the reliable idea set is placed there by the lean code runner.
- it collects anything that is not well formatted — unformalized bits, partial work, and
  unclustered material: the cut output of overrun decompose workers, the cut lemmas of the
  swarm, the 5-minute-tail handoff of closing swarm agents, and any other unfinished
  formalization.
- for workers it is append-only: no worker may delete anything in the idea pool, and the
  fragment region is part of the idea pool.
- fragments are live material for the rest of the project: the Producer's report worker can
  use them like any other idea in the dossier — pairing a fragment with an obstruction and its
  closest technique — and the Creator's second phase mines them directly, so a future report
  builds on what survived instead of re-deriving it.

## status reporting

the Formalizer keeps the formalization status in the Knowledge State index current: after
each completed batch — a decompose run (including its merge), a swarm batch that writes its
per-fragment files, or a lean code runner resumption that greens a piece or deposits
fragments — it
writes one dated line recording
the green count, the [Formalized] count, the fragment deposits and the dependency graph
delta, so the index always reflects the current formalization state and the Coordinator's
round-start check reads a live number. the same line carries the [acceptedR] tally — the
green [acceptedR] pieces over the total, per accepted route — and any [no-green] markers of
the accepted-route watch, so the round-start check reads the watch state live. the formalization status block holds the green
count, the [Formalized] count, and the dependency-graph summary — nodes, edges, and the
goal node's distance to the established base.

## bounded resumption reads — the delta, not the whole state

the Formalizer's territory state is large and mostly unchanged between batches —
formalizer/single.qmd, the generated lean code under formalizer/lean/,
formalizer/dependency-graph.json and the fragment region grow piece by piece. on
resumption the Formalizer reads only the delta since its last batch, never the
whole files (the context economy rule, rules/coordinator.md §3):

- its resume pack (runtime/formalizer-state.md) carries the delta markers: a
  pointer to the latest formalization status-line entry, the last merged fragment
  id (the qmd-index.md tail since that id), the last dependency-graph update
  reference, the last fragment-region deposit reference, and the pending units;
- on resumption it reads the resume pack, the formalization status line in the
  Knowledge State index, the qmd-index.md tail, the new fragment-region deposits
  and the lean code runner's latest batch report — and verifies artifact
  existence by file (paths), never full contents;
- the whole single.qmd, the whole lean/ tree and the whole dependency graph are
  read only when a specific duty needs them (e.g. the goal-distance check the
  Coordinator requests) — never as a resumption habit.

the delta reads replace only the way the Formalizer re-reads unchanged state; every
duty stays exactly as specified — the decompose regulation, the swarm regulation,
the lean-runner gate re-request, the status reporting, and the accepted-route
watch: the watch is unchanged and stays cheap because it reads the small registry
formalizer/accepted-routes.md (never the qmd file) at each batch end, tallies the
[acceptedR] green counts per accepted route, applies the [no-green] transitions,
and writes the stale signal to runtime/stale-signals/ before it ends (the
accepted-route watch and the stale signal above).

## artifact rules and versioning

- artifacts are files, and the Formalizer guarantees them: every worker it directs that
  produces an artifact is spawned — by the Coordinator at its request, or by its owner
  for a swarm — with the explicit output path its subcoordinator assigns and must write its artifact
  there and confirm the write in its final message — the working swarm, for instance, writes
  its per-fragment files under `formalizer/fragments/` and reports the written paths. the
  'recovered from agent output' pattern — a worker that cannot write includes the complete
  artifact text in its final message, and the Formalizer persists that text verbatim at the
  assigned path — remains only for genuinely read-only roles: the panel, the examine worker,
  the decision swarm, the lean runner's swarm agents (read-only Read/Grep/Bash), and the
  decompose workers, which produce the plan and the merge output, not the files. the
  Formalizer checks that every artifact exists after each worker completes and never starts
  the next step on a missing artifact; documents move between workers only as files.
- everything is versioned: every qmd file update, reliable idea set entry, fragment region
  update and dependency graph update carries a version (v1, v2, …); nothing is cited or built
  on without its version. the goal file is excluded from this rule: it is locked and the
  project never changes it.
- artifact locations (default layout, construction-plan §1):
  - `formalizer/single.qmd` — the one qmd file (green pieces locked in place, never removed);
  - `formalizer/fragments/` — the per-fragment files: one directory per fragment id holding
    the `.qmd` piece and the `.lean` piece, written by the working swarm and merged into the
    single qmd file by the decompose worker, ordered by fragment id;
  - `formalizer/qmd-index.md` — the id list of the lemmas, definitions and theorems in
    single.qmd: read by the working swarm for placement, maintained by the decompose worker
    on every merge;
  - `formalizer/dependency-graph.json` — the dependency tree (schema v2): statement nodes with
    their class (`kernel` | `mathlib` | `formalized` | `axiom` | `goal`) and status
    (`formalized` | `hired` | `axiom` | `base` | `goal`) · green edges with `source:
    lean-axioms` · [Hired] flags · the goal node;
  - `formalizer/lean/` — the lean code generated from the qmd file: the one canonical
    append-only file `single.lean` with its 1:1 correspondence registry and its mandatory
    section markers, the per-green-piece `#print axioms` footprints
    (`axioms-<piece>.txt`), and the hireable registry (`hireable-registry.md`);
  - `formalizer/symbol-list.md` — the symbol list written from `templates/symbol-list.md`
    when single.lean holds more than 10 lean codes: every symbol with its precise definition
    and the rename log (old → new);
  - `formalizer/connection-proofs.md` — the registry of proved connection pairs
    (`X → Y via <route> v<n>`), maintained by the lean code runner;
  - `dossier/idea-pool/` — the reliable idea set ([Formalized] green lean) and the fragment
    region (append-only for workers);
  - `formalizer/accepted-routes.md` — the accepted-route watch registry (versioned;
    maintained by the lean code runner at its resumption and batch end);
  - `runtime/stale-signals/` — the stale-signal channel (<route-title>.md in the locked
    format; the Formalizer writes it before ending, the Coordinator appends the status line).

## relationship to the other subcoordinators

- the Producer feeds the Formalizer (examine-failed lint-passed reports) and the Selector
  feeds it post-verdict (accepted routes — full or core form — with the promoter's note as
  scoping metadata); the Producer consumes its outputs (the [Formalized] premises and the
  dependency tree, via the goal-frontier score; the fragment region as pairing material).
  the Producer prefers pairings that shrink the goal node's distance to the established base.
- the Creator's second phase consumes its outputs: its phase-2 workers search for good ideas
  and techniques in the reliable idea set and the fragment region in the dossier.
- the Selector's acceptance decisions are orthogonal to formalization: acceptance of a route
  needs at least 2/3 of the swarm workers and at least 2/3 of the BCD reviewers, and the
  project reaches a milestone only on full consensus — all 3 swarm workers and all 3 BCD
  reviewers accept and the accepted routes together achieve the locked goal. in that review
  the BCD reviewers write review summaries, which the PI receives to modify the route and
  rebut. a [Formalized] idea is already established and needs no panel review, but
  formalization never makes a route accepted by itself. the swarm judges the route itself, referring to the promoter's nearest true version note as a
  high-level check, and votes accept, accept-core, or reject; rejected work enriches
  the fragments.
- the Coordinator regulates the Formalizer like the other subcoordinators: it monitors its
  status, checks that handoffs satisfy dependencies, and solves issues — restarting a stalled
  worker, reordering handoffs, arbitrating, or escalating to the user — and measures the
  system (idea-yield, premature kills, panel consistency) without ever touching the acceptance
  thresholds. at the start of each round it performs the bounded Formalizer check before
  the round clock starts: it reads the formalization status line in the Knowledge State
  index that the Formalizer keeps current, and the live background state, verifies that
  the four subcoordinators (Creator, Producer, Selector, Formalizer), the PIs, and the
  lean code runner are present and working — re-spawning them if a
  resumed session lost them — and resolves any stall or conflict it finds; the check is
  a bounded read that, like the round-1 setup, is not counted in the 138-minute budget.
- the Formalizer is a mandated part of the project: it always runs across rounds and winds
  down only when the project ends, as described above.
