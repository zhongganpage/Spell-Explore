# stale entry — template

an unsuccessful report and its corresponding summaries, and an unaccepted route, are marked
stale and automatically sent to the Creator by the corresponding subcoordinator. each stale
marking records the failure reason, a revival trigger, and the fragments of the work. the
fragments are archived in the fragment region (lock this name) of the idea pool in the dossier,
so the Producer's report worker can use them like any other idea — a future report builds on
what survived instead of re-deriving it — and the Creator's second phase mines the fragments
directly. this file is the template each stale marking fills in.

## who, when, where

- marked by: the Producer (reports that failed the linter or the examine), the Selector
  (unaccepted routes), the Formalizer (cut decompose work, and the 5-minute tail of a swarm
  agent), the Coordinator (phases cut at their window end). an accepted route whose
  formalization failed is marked stale by the Selector or a dedicated stale-worker on the
  Coordinator's instruction (the accepted-route watch — two consecutive lean-runner batches
  with no green [acceptedR] piece; rules/formalizer.md).
- where it lives: the project folder (stale/), versioned; the fragments it carries are
  deposited into the fragment region in the idea pool in the dossier.
- the Creator's second phase picks the stale document up: it requests n idea-workers (0 ≤ n ≤ 8,
  independent of the phase-1 workers) from the Coordinator to search for good ideas and techniques in the summary, report, or route,
  and in the reliable idea set and the fragment region (at most 15 minutes), runs the same
  rotation as phase 1, and archives fresh summaries in the idea pool.

## the format

### id

`<stale-id>` · source item: `<summary | report | route> <id + version>` · version `<v1, v2, …>`

### failure reason

`<sufficiency failed — the examine's finding, including what was missing, or the panel
findings that rejected it, including the load-bearing obstruction named by the
rejecting votes — the single missing lemma, false step, or unproved claim. state
whether the item was killed by evidence or by opinion, so the Coordinator can detect
premature kills: stale or unaccepted items whose fragments later end up inside an
accepted route>`

### revival trigger

`re-examine when <event> — <the concrete event that should bring this work back into play: a
new lemma entering the reliable idea set, a technique arriving in the fragment region, a pairing
that fills the missing gap, a route revision that removes the obstruction>`

### fragments (deposited in the fragment region)

- sub-results that hold: `<every result that survives — each with its statement, its
  assumptions, and where its proof lives, so a future report builds on it>`
- obstruction: `<the exact point where the work failed — the claim, the step, the missing
  assumption>`
- closest technique: `<the nearest known technique or result, with source and locator, and what
  it leaves open>`
- if the route was rejected, also: promoter's nearest true version note `<the strongest claim
  the route can honestly make, and the exact point where it breaks>` and the promoter's
  connection marks `<the `[<route title>-T-<implied id>]` / `[<route title>-F-<initial id>]`
  marks written into the single qmd file in the 118–138 window (rules/selector.md §7.1): the
  pairs of statements the route's results or techniques bridge — a surviving sub-result a
  future report or route can build on>`

### examine sufficiency tag (only when a report failed the examine)

`<what was missing, tagged on the source summaries, so the next pairing deliberately fills the
gap instead of repeating it>`

## rules that bind this artifact

- no worker may delete anything in the idea pool: for workers it is append-only. the fragment
  region collects anything that is not well formatted — unformalized bits, partial work, and
  unclustered material.
- a stale accepted route (formalization failed — no green [acceptedR] piece in two
  consecutive lean-runner batches, rules/formalizer.md) records the failure reason
  `formalization failed — none of the accepted route's lean codes is green after two
  consecutive lean-runner batches (killed by evidence: lean)`, the fragments are the route's
  unproved pieces, and the revival trigger names the event that could formalize them.
- a stale marking is a storage state, never a verdict: the fragments carry the resume point,
  and when a revival trigger fires, its fragment jumps the pairing queue.
- rejection and counterexample are ordinary recorded outcomes, not failures — R3 of the
  persistence protocol: an unrecorded dead end is guaranteed to be re-attempted by a future
  worker.
