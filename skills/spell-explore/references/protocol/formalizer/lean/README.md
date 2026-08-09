# lean code — protocol/formalizer/lean/

The lean code produced from the Formalizer's single qmd file lives here. the
Formalizer is the fourth subcoordinator: it only receives idea reports that have
passed the hygiene linter — successful or unsuccessful — and it runs in the
background across rounds, not bound by the 133-minute round budget.

## What lives here

- the lean code generated from formalizer/single.qmd — the one qmd file, in
  qmd-prover form (there is only one qmd file). whenever a qmd piece is
  lean-green, the lean code runner locks that piece in the qmd file (green
  pieces are locked in place, never removed) and places the corresponding lean
  code in the reliable idea set (lock this name), which lives in the same place
  as the idea pool in the dossier.
- the sibling file formalizer/dependency-graph.json holds the dependency tree
  that the lean code runner builds and updates (see below).

## Who writes

- the working swarm of ~8 workers: it mechanically transforms the decomposed
  fragments (lock this name) into the single qmd file and then into lean code.
  the decomposed fragments are individual claims with their assumptions and
  implications, grouped by the linter's layer 2.
  the swarm does not judge the mathematics and does not run qmd-prover; if it
  detects that similar lemmas, definitions, theorems or propositions already
  exist in the qmd file, it places them closely.
- the lean code runner (lock this name): an independent, resumable worker that
  wakes on every qmd update, plans the verification jobs in advance, and
  distributes them to its own swarm agents — whatever number the plan requires,
  unrelated to the working swarm; it integrates the green results, locking
  green pieces in the qmd file, placing their lean code in the reliable idea
  set, and updating the dependency graph.

## How pieces become established

- the lean code runner builds and updates a dependency tree: every assumption —
  in the lean code format, not qmd — is a node, and every green lean code is a
  directed edge connecting one node to another. an assumption becomes [Hired]
  when it is implied through a green lean code by another different assumption.
  the graph is updated whenever there is a new green lean code, adding the nodes
  and edges of that green proof.
- the main goal is a distinguished node of this tree: the best outcome is a
  green lean code that connects the goal node to an acceptable assumption — the
  goal becomes reachable from the [Formalized] or [Hired] assumptions — and the
  Producer prefers pairings that shrink the goal node's distance to the
  acceptable set.
- a [Formalized] idea may be cited by a report or a route as an established
  premise without further panel review; it cannot be overturned by a later
  round. green lean codes are the only format in the reliable idea set.

## Who reads

- the lean code runner; the Producer's report worker (which reviews the reliable
  idea set and the current dependency graph); and any report or route that cites
  [Formalized] or [Hired] premises.

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
- the lean code runner never closes: it persists and can always be resumed, like
  the subcoordinators and the PIs. a round close never cuts the swarm.
