# patch spec — connection proofs (v1)

authoritative implementation spec for the connection-proofs amendment. the
protocol source is `references/protocol/` (the packaged skill's protocol tree;
this spec lives at `references/`, a sibling). edit only the files listed per
section. style: match the surrounding prose — lowercase, dense, single long
paragraphs per brief, no new headings unless stated. every artifact stays
versioned (v1, v2, …). never invent new roles: where a duty is added, attach it
to an existing role's brief. mechanical-only discipline everywhere: no worker
judges mathematics.

## D1. promoter marks with proofs (connection-report v2)

files: `templates/connection-marks.md`, `agents/promoter.md`,
`rules/selector.md` (§7.1 + close checklist).

- the promoter keeps the marking duty (the Selector's resumed promoter,
  118–138 window, verdict-independent). the PI does NOT mark; `agents/pi.md`
  is untouched.
- the report gains a proof field on every T (initial) mark, three states:
  - `route-ref:<claim-id>` — the implication is already a claim in the revised
    route; no new argument needed.
  - `full-argument` — a complete argument written inline, using ONLY claims
    already in the revised route; the swarm can transcribe it mechanically.
  - `open` — no complete argument; the gap is recorded for the PI, the mark
    stays annotation-only.
  - F (implied) marks carry one line of reason only, no proof field.
- template: `templates/connection-marks.md` — in the "marks" report section,
  add per-pair lines: `proof: <route-ref:<id> | full-argument | open>` (T
  marks) and the existing one-line justification stays for both. keep the
  `<!-- connection: [...] -->` annotation-line format unchanged (marks remain
  annotations, never content). record open gaps in a dedicated `open gaps`
  report subsection (id pair + what is missing).
- promoter brief: duty 2 text — for every T mark, name which of the three
  proof states applies and supply the argument for `full-argument`; state the
  report is the connection-report and it is delivered to the Formalizer and
  the decompose workers (not just the Selector).
- selector rules: the close checklist verifies the connection-report exists
  with proof fields (L-B below); the report travels with the accepted route to
  the Formalizer; for a rejected route the marks still enrich the stale entry.

## D2. two mechanical linters (L-A, L-B)

files: `rules/selector.md` (new §), `agents/selector.md` (brief line).

- L-A — accepted route + PI change list: every change-list item lands in the
  route (ids exist, numbering consistent), claim structure uniform, citations
  and locked names consistent, symbols conform to the symbol list (D5).
- L-B — connection report: T/F pairs complete, both ids exist in the route,
  proof field is one of the three states and valid (`route-ref` resolves to a
  route claim, `full-argument` cites only route claims, `open` is recorded in
  the open-gaps subsection), and cross-checked against the route.
- both run at the Selector close, before the handoff to the Formalizer; a
  failing artifact stays at the Selector (report back to the promoter, route
  back to the route-writer); non-blocking for the next round's start (recorded
  pending like the other per-close decisions).
- deterministic mechanical checks, no new subagent, no AI judgment — the
  Selector runs them (or its own workers per the existing gate pattern).

## D3. miners read the connection-report; graph workers focus on the graph

files: `agents/idea-worker.md` (phase 2), `agents/graph-worker.md`,
`agents/creator.md` (phase 2 dispatch), `rules/core-loop.md` (phase-2 text
where it names the connection-marks source).

- regular miners: may read the connection-report (the report, not only the
  qmd-index connections section) as material for fresh summaries; the marks'
  proof states tell them which connections are already argued (borrow the
  technique) vs open (mine toward the gap).
- graph workers: drop the connection-marks-as-bridging-hints duty; they read
  only `dependency-graph.json` (nodes, green edges, [Hired], goal), the
  reliable idea set, and the Knowledge State index, and propose bridging
  lemmas from the graph. remove the sentence about reading the connections
  section / grepping single.qmd for connection annotations.
- creator: phase-2 dispatch passes the connection-report pointer to miners and
  the graph to graph workers.

## D4. merge moves to the decompose worker; [Similar] marked at merge

files: `agents/decompose-worker.md`, `rules/formalizer.md`, `agents/formalizer.md`,
`agents/swarm-worker.md` (its "the merge is the lean code runner's job" line).

- after the working swarm finishes, the decompose worker merges the completed
  per-fragment `.qmd` pieces into `formalizer/single.qmd` (deterministic order
  by fragment id; `partial/` never merged) and updates `formalizer/qmd-index.md`.
- the decompose worker writes a `[Similar: <green id>]` annotation (in
  single.qmd, same annotation line family as connection marks) on each merged
  non-green piece whose proof text resembles a green piece's proof text but is
  not mechanically the same — the comparison is local (the merged piece vs the
  green pool in single.qmd / the reliable idea set), proof-text similarity is
  the index, the most similar green id wins. `[Similar]` is an annotation,
  NEVER a dependency-graph edge, never a claim of equivalence.
- the runner's step-1 merge is REMOVED from `agents/lean-code-runner.md`; the
  runner reads the already-merged single.qmd. the accepted-route watch stays
  with the runner (it reads `[acceptedR]` from single.qmd at its resumption).
- single.qmd single-writer ordering: the decompose worker merges within the
  round; the runner locks green pieces at the next round start; the two never
  write in the same turn; every write bumps the single.qmd version. record
  this ordering rule in `rules/formalizer.md`.

## D5. lean runner pipeline: single.lean, symbol list, renames, [Similar], [Hired]

files: `agents/lean-code-runner.md`, `agents/lean-swarm-worker.md`,
`templates/symbol-list.md` (NEW), `rules/formalizer.md`.

- **single.lean**: the runner converts/refreshes the lean code from
  `formalizer/single.qmd` into ONE append-only `formalizer/lean/single.lean`;
  later rounds only ADD new lean code, never rewrite locked green sections;
  a 1:1 correspondence registry maps qmd div id ↔ lean declaration
  (the existing per-fragment lean files keep their role as the swarm's
  working copies; single.lean is the canonical compile + analysis base).
- **section markers**: single.lean carries mandatory section markers per div
  (the existing `-- ====` header blocks); the registry records each div's line
  range so the swarm can copy a local part.
- **symbol list**: when single.lean holds more than 10 lean codes, the runner
  unifies the symbols (pure renames — see below) and writes
  `formalizer/symbol-list.md` from `templates/symbol-list.md`: every symbol
  with its precise definition (centralizes the per-fragment "Mathlib bridge"
  notes). all other workers (idea workers, writers, reviewers, decompose,
  swarm) use symbols as defined in the list and propose new symbols when
  needed; new-symbol intake: the worker carries the definition comment in its
  piece, the runner adds it to the list at its next resumption; linters accept
  `proposed` symbols (not violations).
- **rename policy**: green lean code may be RENAMED (pure renames only) as
  part of unification; a rename is atomic, compile-verified, and rolled back
  on failure — a rename never changes mathematics, and a green piece stays
  green. the rename log (old → new) lives in the symbol list. renames sync:
  the green archive in the reliable idea set (the [Formalized] lean copies),
  `axioms-<piece>.txt`, `hireable-registry.md`, and the 1:1 registry are all
  updated together, each with a version bump. model merging (two pieces
  modelling one object) is NOT a rename — it is mathematics and goes through
  the route pipeline, never the runner.
- **swarm verification**: the runner's swarm agents copy the assigned piece +
  its dependency closure from single.lean into a new temporary lean file and
  compile there; single.lean itself stays untouched by the swarm.
- **[Similar]**: the decompose worker writes its [Similar]
  annotations into single.qmd at merge and mirrors them into the qmd-index
  similarity section (notification channel for miners and the Creator's phase-2
  workers). lifecycle: when a [Similar]-marked piece turns green, the runner
  retires the mark at lock time; on rename, the mark's target follows the
  rename log. the runner never claims equivalence, and a missing [Similar]
  means nothing.
- **[Hired]**: the runner marks [Hired] IN single.lean (annotation) and builds
  the dependency graph from the single file. graph node identity = div id
  (stable), with the lean declaration name as an attribute updated on rename —
  renames must not rewrite node ids.
- the graph itself stays `formalizer/dependency-graph.json`; [Similar] is not
  an edge class (proves edges from D6 remain the only new edge class).

## D6. decompose consumes the connection-report

files: `agents/decompose-worker.md`, `rules/formalizer.md`.

- the connection-report is an input to the decompose worker:
  - `full-argument` pairs are scheduled as proof fragments (the swarm
    transcribes the written argument verbatim);
  - `route-ref` pairs are scheduled as plain import edges;
  - `open` pairs stay annotation-only, recorded for the PI (the Formalizer
    surfaces them at revision time), never scheduled.
- a scheduled proof fragment carries `[proves: X → Y via <route> v<n>]`; when
  the runner verifies it green it records a `proves` edge (the first
  green→green edge class) in the dependency graph and logs the pair in
  `formalizer/connection-proofs.md` (new registry the runner maintains).

## D7. connection-report delivery

files: `rules/selector.md`, `agents/formalizer.md`.

- the Selector hands the connection-report to the Formalizer with the accepted
  route; the Formalizer passes it to the decompose workers as scoping input.
- qmd-index gains a similarity section (written by the decompose worker at
  merge) mirroring the [Similar] annotations, so the Creator's phase-2 workers
  and the working swarm are notified by ids.

## verification

after editing, run from the repo root:
`scripts/sync-skill.sh` (must exit 0 — repo skill == user-scope skill),
then `scripts/check-skill.sh`. the project mirror
`D:/workspace/nonexL2-Explore/references/protocol` is copied afterwards by the
Coordinator-level sync, not by the worker.
