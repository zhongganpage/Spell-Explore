# connection marks — template

the promoter's connection report (lock this name), written by the Selector's re-invoked
promoter in the 118–138 window, at the same time as the decision swarm and the resumed
BCD vote. the marking is verdict-independent: it runs for every route under review,
whatever the vote. the marks themselves are written into the single qmd file
(formalizer/single.qmd) as qmd annotation lines at the marked blocks; this report is the
versioned record of them, with the justifications, so the Selector can verify the marks
by file and route the connection info post-verdict. this file is the template the
promoter fills in.

## who, when, where

- produced by: the promoter, re-invoked in a fresh context during the 118–138 window of
  the round (the promoter does not resume in this period; rules/selector.md §7.1).
- inputs: the revised route (the PI's modified route), the change list, the BCD review
  reports (the raw review reports and the three review summaries of workerB, workerC and
  workerD), and the single qmd file — formalizer/single.qmd with its id list
  formalizer/qmd-index.md.
- where it lives: a versioned Selector artifact at the assigned output path — the
  promoter is read-only, so its final message carries the complete report and the
  Selector persists it verbatim, marked recovered from agent output; the marks are
  written into single.qmd at the same time and verified by the Selector by file. for an
  accepted or accepted-core route the report rides with the accepted route and the
  promoter's note to the Formalizer as scoping metadata; for a rejected route its
  connection entries enrich the stale entry's fragments.

## the marks (written into single.qmd)

for every statement-pair the route's results or techniques can bridge — the initial
statement X implies the statement Y, by a proof that uses the route's results or some
techniques in them — the promoter writes, as an annotation line directly above the marked
block (the qmd annotation-comment feature, with `@id` pointers; the marks are
annotations, never content — they never change a block's statement):

- above the initial statement X: `<!-- connection: [<route ID>-T-<the id of the implied statement>] — the results/techniques of route <title> v<n> prove @<implied id> from this statement (@<initial id>) -->`
- above the implied statement Y: `<!-- connection: [<route ID>-F-<the id of the initial statement>] — this statement follows from @<initial id> by the results/techniques of route <title> v<n> -->`

route ID = the route's title (the locked name that distinguishes the route from every
other route). the marks may use some of the qmd features — the `@id` pointer syntax and
the annotation-comment convention — and the promoter may run qmd-prover's mechanical
check on single.qmd to verify the file stays valid. when single.qmd has no statements
yet, or no bridge is found, the report records that explicitly (`no connections found`).

## the report

### route

`<route title> v<n>`

### marks

- `<id of the initial statement X>` ← `[<route title>-T-<id of the implied statement Y>]`
- `<id of the implied statement Y>` ← `[<route title>-F-<id of the initial statement X>]`
- justification: `<one line per pair: how the route's results or techniques show the
  proof from X to Y — the claim or technique in the route that does the work>`

## rules that bind this artifact

- the marks are annotations (provenance), never content: they never change a block's
  statement, and they survive the lean code runner's merges (the merge appends
  per-fragment pieces ordered by fragment id and never removes locked content,
  rules/formalizer.md); the lean conversion ignores comments, so the marks never change
  the mathematics.
- the lean code runner mirrors the marks into the connections section of qmd-index.md at
  its next merge, so the Creator's phase-2 workers and the working swarm are notified of
  the connection by the ids and may use ideas from the route.
- everything is versioned (v1, v2, …); nothing is cited or built on without its version.
