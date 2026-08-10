# Formalizer rule

this rule specifies the fourth subcoordinator, the Formalizer: what it receives, how it
decomposes idea reports into the decomposed fragments, how the purely mechanical working
swarm turns them into per-fragment files, how the lean code runner merges them into the
single qmd file, locks green pieces and builds the dependency tree, and what it outputs —
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
regulates the Formalizer. every worker it spawns is spawned in the explicit background mode,
never the blocking foreground. the Formalizer is resumable: it runs each phase to completion in one run — waiting for every worker's artifact before returning — and is resumed by the Coordinator for the next phase; it never returns early, and a narrated step is not a done step. within the Formalizer's territory so does the lean code runner (see
below).

the Formalizer runs in the background across rounds: it is not bound by the 2-hour-and-13-
minute round budget — its decompose workers run per pair of reports at any time, off the
critical path of the round timeline (0–20 the Creator's phase 1, 20–45 the Producer's report,
45–63 the hygiene linter and the examine worker, 63–103 the Selector's panel, 103–118 the PI's
rebuttal and the promoter, 118–138 the Selector's swarm and the resumed BCD reviewers), and
the Coordinator resumes the lean code runner on every qmd file update. the reliable idea set and the fragment region
grow continuously across rounds, and a round close never cuts the swarm. the Formalizer has
no overall time budget: only the decompose workers and the swarm agents carry time limits.

the Formalizer winds down only when the project ends: it finishes its existing work — no new
reports come in, the working swarm completes, and the lean code runner processes the
remaining qmd pieces — before it closes. the project ends when it reaches a milestone: all 3
swarm workers and all 3 BCD reviewers accept and the accepted routes together achieve the
locked goal (see the Selector rule for the acceptance thresholds: a route is accepted with at
least 2/3 of the swarm workers and at least 2/3 of the BCD reviewers agreeing; full consensus
3/3 + 3/3 is the milestone). on the formalization side, the locked goal being achieved means
the goal node of the dependency tree is reachable from the [Formalized] or [Hired]
assumptions; when the milestone is reached the Coordinator writes a report in PDF, called the
manuscript, and maintains the question-routes folder, which holds a copy of the full reliable
idea set.

## inputs: verdict-aware

the Formalizer's inputs are verdict-aware. a lint-passed report that fails the examine
worker is copied to it by the Producer as soon as it is stale — its raw form is its final
form. a lint-passed report that becomes a route is not copied at linter time: after the
Selector's verdict, the Selector sends the accepted route — full form (the PI's modified
route) or core form (the accepted salvageable core) — together with the promoter's nearest
true version note; a rejected route's pair enriches the fragment region instead. the
promoter's note is scoping metadata for the decompose workers: it marks the honest core to
formalize and the exact breaking point (an obstruction in the fragment region and the
obstructions register), and the note itself is never decomposed. there is no limit on the
number of inputs the Formalizer can take: every two units — a lint-passed examine-failed
report, or an accepted route with its note — make a new worker that decomposes them.

the Formalizer relies on the linter's layer 2, which produces the format: every claim, lemma,
theorem and proposition has a uniform structure — a precise statement, its assumptions
explicitly listed, and its implications — and the linter identifies the assumptions and
implications of every claim and groups them, so that the decompose workers and the swarm
workers in the Formalizer can easily process them. the hygiene linter has the duty to
formalize the arguments and identify the assumptions of the claims; the swarms are purely
mechanical — they only transform the reports into per-fragment files under
`formalizer/fragments/` that the lean code runner merges into the single qmd file, never
identifying assumptions or judging the mathematics.

## the decompose workers

every two units make a new worker that decomposes them — a unit being a lint-passed
examine-failed report, or an accepted route with its promoter's note. the decompose worker:

1. identifies the groups of claims with their assumptions and implications, as grouped by the
   linter's layer 2 — the format already gives each claim its statement, its explicit
   assumptions and its implications, grouped so the decomposition is mechanical rather than
   interpretive;
2. decomposes them properly into the decomposed fragments (lock this name) — individual
   pieces small enough for a swarm worker to formalize in the 10-minute lemma cut;
3. plans how to distribute the work to the swarm workers — which decomposed fragment goes to
   which worker, in which order, so the swarm works in parallel without duplicating or
   conflicting claims.

the decomposed fragments are thrown to the working swarm of ~8 workers. a unit that waits
more than ten minutes without a proper pair moves to the next step on its own: the Formalizer
holds incoming reports up to 10 minutes for a complement, and if none arrives the unpaired
report is decomposed singly — the 10-minute unpaired timeout, the same value as the
decompose worker's own limit.

a decompose worker has 10 minutes per pair of reports. on overrun it is cut and whatever it
produced is sent to the fragment region: the partial decomposition is recorded there, marked
unfinished, so nothing is lost and a future worker can pick it up. the decomposed fragments
produced on time are thrown to the working swarm; their distribution plan goes with them.

## the working swarm (purely mechanical)

the working swarm of ~8 workers is purely mechanical: it does not judge the mathematics, and
it never identifies assumptions — that duty belongs to the hygiene linter (layer 2) and to
the decompose workers. the swarm only mechanically transforms each decomposed fragment into
its per-fragment files under `formalizer/fragments/<fragment-id>/` — the `.qmd` piece in
qmd-prover form and the `.lean` piece — and reports the written paths in its final message;
it never merges them. the merge into the single qmd file is done deterministically by the
lean code runner at its next resumption, ordered by fragment id. there is only one qmd file in
the whole project: the Formalizer's single qmd file lives in the project folder at
`formalizer/single.qmd`. the swarm does not run qmd-prover. this working swarm is unrelated to
the lean code runner's own swarm, which executes the lean code runner's planned verification
jobs (see below).

the swarm's rules:

- **single qmd file.** there is only one qmd file in the project — `formalizer/single.qmd` —
  and the swarm never writes parallel qmd files: each transformed fragment becomes its own
  per-fragment files under `formalizer/fragments/<fragment-id>/`, and the lean code runner
  merges them into the one qmd file at its next resumption, ordered by fragment id.
- **similar facts placed closely.** each worker reads `formalizer/qmd-index.md` — the id list
  of the lemmas, definitions and theorems already in single.qmd, not the whole qmd file — and
  decides its placement from that list: a fragment whose facts resemble ids already in the
  index is written to sit next to its relatives, so the qmd file grows as one coherent body
  instead of scattered pieces. the lean code runner maintains qmd-index.md on every merge,
  appending the ids of the newly merged pieces.
- **writes lean code.** the swarm converts each decomposed fragment into the qmd piece and
  then into the lean piece, both written as per-fragment files under
  `formalizer/fragments/<fragment-id>/`, and reports the written paths in its final message;
  the lean code runner picks them up and runs them (see the artifact layout below).
- **10-minute lemma cut with relay.** whenever a swarm worker's job runs more than 10 minutes, it
  packages the partial work and waits for another swarm worker that has already done its job to
  take it over — the relay restarts the 10-minute clock on the receiving worker; if no such
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
  merge into the single qmd file and the green count are done by the lean code runner, not by
  the swarm.

## the lean code runner (lock this name)

the lean code runner is an independent, resumable worker. like the subcoordinators and the PIs it is resumed by the Coordinator on every qmd file update and restored after a session resume — it does not wake on its own. it plans in advance: on every resumption it examines the qmd
file, the generated lean code, the reliable idea set and the dependency graph, and builds a
forward plan of the mechanical verification jobs — which lean code to run, which pieces to
green-check, and in what order, preferring the pieces that shrink the goal node's distance
to the acceptable set. its duties, in order, on every resumption:

1. **merge the per-fragment pieces.** it merges only the completed per-fragment files under
   `formalizer/fragments/` — packaged partial work under `<id>/partial/` is not merged — into
   the single qmd file, deterministically ordered by fragment id, so `formalizer/single.qmd`
   stays the one qmd file of the project, and appends the ids of the newly merged pieces to
   `formalizer/qmd-index.md`.
2. **refresh the lean code.** it converts the merged single qmd file into the lean code under
   `formalizer/lean/` — running qmd-prover on `formalizer/single.qmd` as the mechanical step —
   so the verification jobs run the current lean code.
3. **plan and distribute.** it distributes the planned verification jobs to its own swarm
   agents — whatever number the plan requires, with no fixed count. the lean code runner's
   swarm is unrelated to the working swarm of the decompose workers: the working swarm
   transforms the decomposed fragments into per-fragment files — the qmd piece and the lean
   piece per fragment; the lean code runner's swarm executes the planned verification jobs
   (running the assigned lean code, counting the green theorems) and reports the green pieces
   with their lean code and their dependency edges.
4. **lock green pieces.** whenever a qmd piece is lean-green, the lean code runner locks that
   piece in the qmd file — green pieces are locked in place, never removed — and places the
   corresponding lean code in the reliable idea set (lock this name), which lives in the same
   place as the idea pool in the dossier (`dossier/idea-pool/`). so the reliable idea set
   holds the formalized pieces as lean code, and the qmd file keeps the green pieces locked in
   place.
5. **build and update the dependency tree.** the lean code runner is responsible for building
   and updating a dependency tree, stored as the dependency graph in the project folder at
   `formalizer/dependency-graph.json`:
   - every assumption — in the lean code format, not qmd — is a node;
   - every green lean code is a directed edge connecting one node to another;
   - an assumption becomes [Hired] when it is implied through a green lean code by another
     different assumption;
   - the main goal is a distinguished node of this tree;
   - the dependency graph is updated whenever there is a new green lean code, adding the nodes
     and edges of that green proof.

the lean code runner is not the judge of the mathematics either: it plans, distributes and
integrates — its swarm agents run the code and green-count, and it locks what is green and
records the edges; its swarm agents are purely mechanical as well. the best outcome for the
project is a green lean
code that connects the goal node to an acceptable assumption — the goal becomes reachable from
the [Formalized] or [Hired] assumptions — and the Producer prefers pairings that shrink the
goal node's distance to the acceptable set (the Producer's goal-frontier score counts the
[Formalized] or [Hired] premises an idea can cite on the dependency tree's path
toward the goal, and rewards ideas that would hire new assumptions).

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
- the lean formalization does not have to be fully based on mathlib: what matters is that the
  piece is green under the lean code runner and the assumptions are explicit.

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
each completed batch — a decompose run, a swarm batch that writes its per-fragment files, or
a lean code runner resumption that merges pieces, greens a piece or deposits fragments — it
writes one dated line recording
the green count, the [Formalized] count, the fragment deposits and the dependency graph
delta, so the index always reflects the current formalization state and the Coordinator's
round-start check reads a live number. the formalization status block holds the green
count, the [Formalized] count, and the dependency-graph summary — nodes, edges, and the
goal node's distance to the acceptable set.

## artifact rules and versioning

- artifacts are files, and the Formalizer guarantees them: every worker it spawns that
  produces an artifact is spawned with an explicit output path and must write its artifact
  there and confirm the write in its final message — the working swarm, for instance, writes
  its per-fragment files under `formalizer/fragments/` and reports the written paths. the
  'recovered from agent output' pattern — a worker that cannot write includes the complete
  artifact text in its final message, and the Formalizer persists that text verbatim at the
  assigned path — remains only for genuinely read-only roles: the panel, the examine worker,
  the decision swarm, the lean runner's swarm agents (read-only Read/Grep/Bash), and the
  decompose workers, which produce the plan, not the files. the
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
    single qmd file by the lean code runner, ordered by fragment id;
  - `formalizer/qmd-index.md` — the id list of the lemmas, definitions and theorems in
    single.qmd: read by the working swarm for placement, maintained by the lean code runner
    on every merge;
  - `formalizer/dependency-graph.json` — the dependency tree: assumption nodes · green edges ·
    [Hired] flags · the goal node;
  - `formalizer/lean/` — the lean code generated from the qmd file;
  - `dossier/idea-pool/` — the reliable idea set ([Formalized] green lean) and the fragment
    region (append-only for workers).

## relationship to the other subcoordinators

- the Producer feeds the Formalizer (examine-failed lint-passed reports) and the Selector
  feeds it post-verdict (accepted routes — full or core form — with the promoter's note as
  scoping metadata); the Producer consumes its outputs (the [Formalized] premises and the
  dependency tree, via the goal-frontier score; the fragment region as pairing material).
  the Producer prefers pairings that shrink the goal node's distance to the acceptable set.
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
  the Formalizer and the lean code runner are present and working — re-spawning them if a
  resumed session lost them — and resolves any stall or conflict it finds; the check is
  a bounded read that, like the round-1 setup, is not counted in the 138-minute budget.
- the Formalizer is a mandated part of the project: it always runs across rounds and winds
  down only when the project ends, as described above.
