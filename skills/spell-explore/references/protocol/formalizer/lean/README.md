# lean code — protocol/formalizer/lean/

The lean code produced from the Formalizer's single qmd file lives here. the
Formalizer is the fourth subcoordinator: its inputs are verdict-aware:
examine-failed lint-passed reports go immediately; accepted/accepted-core
routes (full or core form) together with the promoter's note go
post-verdict from the Selector; rejected pairs go to the fragment region.
and it runs in the background across rounds, not bound by the
round budget.

## What lives here

- the lean code generated from formalizer/single.qmd — the one qmd file, in
  qmd-prover form (there is only one qmd file). whenever a qmd piece is
  lean-green, the lean code runner locks that piece in the qmd file (green
  pieces are locked in place, never removed except by the runner's retraction
  duty — a GREEN record found false is retracted, record + comment) and places
  the corresponding lean
  code in the reliable idea set (lock this name), which lives in the same place
  as the idea pool in the dossier.
- the sibling directory formalizer/fragments/ — one directory per fragment id,
  holding the `.qmd` piece and the `.lean` piece that the working swarm writes;
  the decompose worker plans their merge into single.qmd (the Formalizer writes it),
  ordered by fragment id.
- the sibling file formalizer/qmd-index.md — the id list of the lemmas,
  definitions and theorems in single.qmd: the working swarm reads it for
  placement, never the whole single.qmd, and the decompose worker maintains it
  on every merge, appending the ids of the newly merged pieces.
- the sibling directory formalizer/Integrator/ holds the integration working
  lean file ITG.lean and the integration report integration-report.md — the
  integration graph and the chain/atlas report that the Integrator builds and updates (see below).

## Who writes

- the working swarm of ~4 workers: it mechanically transforms the decomposed
  fragments (lock this name) into per-fragment files under
  formalizer/fragments/<fragment-id>/ — the `.qmd` piece and the `.lean` piece
  — and reports the written paths in its final message. it never merges them.
  the decomposed fragments are individual claims with their assumptions and
  implications, grouped by the linter's layer 2.
  the swarm does not judge the mathematics and does not run qmd-prover; it
  reads formalizer/qmd-index.md — the id list of the lemmas, definitions,
  theorems and propositions already in single.qmd, not the whole qmd file — and
  if a fragment resembles ids already in the index it writes its piece to sit
  next to its relatives.
- the lean code runner (lock this name): an independent, resumable worker that
  is resumed by the Coordinator once per round at the round start (batched — never on every qmd
  file update; run-or-postpone gate), plans the
  verification jobs in advance, and distributes them to its own swarm agents —
  whatever number the plan requires — at most 3 — unrelated to the working swarm. at every
  resumption it reads the already-merged `single.qmd` and its index (`formalizer/qmd-index.md`) —
  it never merges pending per-fragment files into `single.qmd` (the decompose worker plans the
  merge and the Formalizer writes it); then it integrates the green
  results, locking green pieces in the qmd file, placing their lean code in the
  reliable idea set.

## How pieces become established

- the Integrator builds and updates the integration working lean file ITG.lean,
  with the integration report integration-report.md: a node is a statement —
  in the lean code format, not qmd — carrying a status class (kernel | mathlib |
  formalized | axiom | goal), and an edge is "the proof of the conclusion references
  the premise," derived from Lean (`#print axioms`), never from qmd citations. an
  axiom-class node becomes [Hired] iff some green lean code whose conclusion is that
  node's statement is implied by the established base.
  ITG.lean is updated whenever there is a new green lean code, adding the nodes
  and edges of that green proof.
- the main goal is a distinguished node of this tree: the best outcome is a
  green lean code that connects the goal node to the established base — kernel
  axioms + Mathlib theorems + [Formalized] pieces — with `#print axioms
  goalTheorem` clean of non-kernel axioms; the Producer prefers pairings that
  shrink the goal node's distance to the established base.
- a [Formalized] idea may be cited by a report or a route as an established
  premise without further panel review; it cannot be overturned by a later
  round. green lean codes are the only format in the reliable idea set.

## Who reads

- the lean code runner; the working swarm (which reads formalizer/qmd-index.md,
  not the whole single.qmd, to decide placement); the Producer's report worker
  (which reviews the reliable idea set and the current integration report + ITG.lean); and
  any report or route that cites [Formalized] or [Hired] premises.

## Timing rules (the only Formalizer time limits)

- a decompose worker has 10 minutes per pair of reports; on overrun it is cut
  and whatever it produced is sent to the fragment region (lock this name). a
  report that waits more than ten minutes without a proper pair moves to the
  next step on its own.
- any swarm agent lives for 30 minutes and is resumable within that window: a
  resumed agent keeps its context and continues, and after the 30 minutes it
  closes. in the last 5 minutes of its life the agent sends its remaining
  unformalized work — the bits it could not formalize within its time limit — to
  the fragment region, so nothing is lost and a future worker can pick them up.
- whenever your job runs more than 10 minutes, you package the partial work
  and wait for another swarm worker that has already done its job to take it
  over — the relay restarts the 10-minute clock on the receiving worker; if no
  such worker appears within 1 minute, you send the packaged partial work to
  the fragment region.
- the lean code runner is resumable: the Coordinator resumes it once per round at the round
  start — batched, never on every qmd update; a postponed run is recorded paused until the
  user runs it — and restores it after a session resume, like the subcoordinators and the PIs.
  a round close never cuts the swarm.
