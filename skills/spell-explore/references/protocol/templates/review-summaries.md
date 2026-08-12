# review summaries — template

three review summaries (lock this name), one from each of workerB, workerC, workerD of a
Selector panel. workerA runs first in the 63–103 window — it checks the high-level ideas and
claims towards the ultimate goal, finds the evidences of these ideas given in the route (mainly
focusing on whether they really are the evidence of the claim), identifies the important points
that lead to the ultimate goal without criticizing them, and makes a list by 78 min; workerB and
workerC pivot to that list when it arrives. the Selector sends the three summaries to the PI,
who modifies the route and rebuts in the 103–118 window. the summaries travel with the PI's
rebuttal and the promoter's nearest true version note to the swarm and to the BCD
voters (B/C resumed, workerD re-invoked externally) when they decide. the summaries judge the route itself — its claims, proofs and
evidences — and may refer to the promoter's high-level check when available. this file is
the template each of the three workers fills in.

## who, when, where

- produced by: workerB, workerC, workerD of one panel, each in a fresh context, receiving only
  the route and the statements of the cited results — never the author's reasoning or the
  expected outcome.
- timing, 63–103 window: B/C/D have 30 minutes to run the review and write a raw review report,
  and an additional 10 minutes to exchange the reports (each receives the reports from the other
  two), then each writes its review summary.
- workerD is external and makes the overall judgement; with two panels at a time two exterior
  invocations are needed — any workerD falls back to an internal reviewer when the exterior
  reviewer (X) is unavailable or shares the primary's provider family, and the reduced diversity
  is recorded (modules/providers.md).
- after writing their summaries, B and C do not close: they pause, keep their panel context, wait
  for the PI's rebuttal, vote at the swarm stage (20 minutes in the 118–138 window), and only
  then close; workerD is not held — the Coordinator re-invokes it externally for the vote with a
  consolidated prompt.
- the canary gate rides in the review batch: a seeded known-false claim and one planted
  step-error (both excluded from the real record and the route). the gate is announced to the
  B/C/D panel — detection is recorded as announced — and the route may not be accepted unless
  the panel catches the claim (≥80%) and the step-error (100%, with the step cited); the
  running detection rate is recorded in the archive. the swarm stage additionally carries an
  unannounced canary when one is available — the swarm is not told — and its detection is
  recorded separately.

## the three summaries

each of the three summaries carries a "questions for the PI" section: every doubt the
reviewer has about any aspect of the route — a claim, a proof step, an evidence, a
definition, an assumption, an edge case, a citation, the link to the goal — asked as a
concrete question with a stable id (`Q-B<n>` / `Q-C<n>` / `Q-D<n>` by reviewer); the
reviewer also questions every statement that is non-trivial and not well clarified
(hypotheses, terms, definitions or well-posedness not explicit), including the rougher
statements of early routes; a reviewer with no doubt records `no doubts found`. the PI
must answer every question when modifying the route (the change list), and the BCD vote
weighs the quality of the answers.

### workerB — inconsistencies and readability

route: `<route title + version>` · reviewer: `B` · summary id + version: `<id> <v1, v2, …>`

- list from workerA received: `<the evidence points it was asked to judge>`
- inconsistencies: `<each one: the claim id, the problem — e.g. a theorem whose proof is not
  explicitly presented, wrongly presented, or buried in the route; misused citations;
  readability issues>`
- proof-step ledger: `<per claim: each proof step traced to a cited result or to a checked
  computation; every untraceable step listed — an untraceable step is a blocking gap>`
- assumption audit: `<per claim: the hypotheses listed, each confirmed to hold at the point of
  use; any silent assumption flagged, with the step as the repair target>`
- evidence tie-in: `<per workerA evidence point: holds | weakens | fails>`
- canary (announced): `<step-error caught? 100% required, with the step cited>`

### workerC — counterexamples

route: `<route title + version>` · reviewer: `C` · summary id + version: `<id> <v1, v2, …>`

- list from workerA received: `<the evidence points it was asked to judge>`
- counterexamples: `<for each claim examined: the claim id, the attempted counterexample, and
  whether it holds — or the claim survives>`
- counterexample duty: `<at least one attempted counterexample per claim on workerA's list,
  recorded even when it fails — 'searched, survived'>`
- evidence tie-in: `<per workerA evidence point: holds | weakens | fails>`
- canary (announced): `<known-false claim caught? the panel must reach ≥80%>`

### workerD — overall judgement

route: `<route title + version>` · reviewer: `D` `<external | internal fallback (reduced
diversity recorded)>` · summary id + version: `<id> <v1, v2, …>`

- overall judgement: `<accepted | rejected | gaps found, with reasons>`
- proof-step ledger: `<per claim: each proof step traced to a cited result or to a checked
  computation; blocking untraceable steps listed>`
- boundary sweep: `<edge and degenerate cases checked and recorded explicitly — zero, empty,
  trivial, extremes, equality cases; the smallest nontrivial case>`
- evidence tie-in: `<per workerA evidence point: holds | weakens | fails>`
- verdict format: `<a 'rejected' verdict names the load-bearing obstruction; a 'gaps found'
  verdict carries specific repair targets>`
- canary (announced): `<both seeded items caught?>`
- canary (unannounced, swarm stage): `<recorded by the Selector — workerD is not told and does not fill this>`

## rules that bind this artifact

- the three summaries are separate, versioned artifacts; the Selector transfers them to the PI
  as files, and the PI receives them before the 103–118 window.
- every reviewer asks questions about any aspect of the route that raises doubt, and also
  questions every statement that is non-trivial and not well clarified (hypotheses, terms,
  definitions or well-posedness not explicit) — including the rougher statements of early
  routes; a reviewer with no doubt records `no doubts found` (the §3
  questioning duty, id'd `Q-B/C/D<n>`); the PI must answer every question in the change list
  when modifying the route — `repaired` (embodied in the modified route, section cited) /
  `rebutted` (justified) / `open` (stated reason). at the vote the BCD reviewers weigh the
  quality of the PI's answers as an important point of the verdict: a weak, evasive or missing
  answer to a material question forbids that reviewer's accept vote and is recorded with the
  vote.
- the reviewer's verdict outranks the PI's confidence: the PI may repair and resubmit (change
  list + rebuttal) but may not overrule; if the PI believes a reviewer erred, that objection is
  itself a new claim sent to an independent review.
- the route is accepted only if ≥2/3 of the swarm workers (2 of 3) AND ≥2/3 of the BCD
  reviewers agree; the milestone requires 3/3 + 3/3 and the accepted routes together achieving
  the locked goal.
- the panel findings that reject a route become the failure reason of its stale entry, and the
  promoter's nearest true version note enriches the fragments sent to the Creator's second
  phase.
