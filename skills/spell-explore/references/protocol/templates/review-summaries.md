# review summaries — template

three review summaries (lock this name), one from each of workerB, workerC, workerD of a
Selector panel. workerA runs first in the 58–98 window — it checks the high-level ideas and
claims towards the ultimate goal, finds the evidences of these ideas given in the route (mainly
focusing on whether they really are the evidence of the claim), identifies the important points
that lead to the ultimate goal without criticizing them, and makes a list by 73 min; workerB and
workerC pivot to that list when it arrives. the Selector sends the three summaries to the PI,
who modifies the route and rebuts in the 98–113 window. the summaries travel with the PI's
rebuttal and the promoter's nearest true version note to the swarm and to the resumed BCD
reviewers when they decide. the summaries judge the route itself — its claims, proofs and
evidences — and may refer to the promoter's high-level check when available. this file is
the template each of the three workers fills in.

## who, when, where

- produced by: workerB, workerC, workerD of one panel, each in a fresh context, receiving only
  the route and the statements of the cited results — never the author's reasoning or the
  expected outcome.
- timing, 58–98 window: B/C/D have 30 minutes to run the review and write a raw review report,
  and an additional 10 minutes to exchange the reports (each receives the reports from the other
  two), then each writes its review summary.
- workerD is external and makes the overall judgement; with two panels at a time two external
  reviewers are needed — if only one is available, the second panel's workerD falls back to an
  internal reviewer and the reduced diversity is recorded.
- after writing their summaries, B/C/D do not close: they pause, keep their panel context, wait
  for the PI's rebuttal, vote at the swarm stage (20 minutes in the 113–133 window), and only
  then close.
- the canary gate rides in the review batch: a seeded known-false claim and one planted
  step-error (both excluded from the real record and the route). the route may not be accepted
  unless the panel catches the claim (≥80%) and the step-error (100%, with the step cited); the
  running detection rate is recorded in the archive.

## the three summaries

### workerB — inconsistencies and readability

route: `<route title + version>` · reviewer: `B` · summary id + version: `<id> <v1, v2, …>`

- list from workerA received: `<the evidence points it was asked to judge>`
- inconsistencies: `<each one: the claim id, the problem — e.g. a theorem whose proof is not
  explicitly presented, wrongly presented, or buried in the route; misused citations;
  readability issues>`
- canary: `<step-error caught? 100% required, with the step cited>`

### workerC — counterexamples

route: `<route title + version>` · reviewer: `C` · summary id + version: `<id> <v1, v2, …>`

- list from workerA received: `<the evidence points it was asked to judge>`
- counterexamples: `<for each claim examined: the claim id, the attempted counterexample, and
  whether it holds — or the claim survives>`
- canary: `<known-false claim caught? the panel must reach ≥80%>`

### workerD — overall judgement

route: `<route title + version>` · reviewer: `D` `<external | internal fallback (reduced
diversity recorded)>` · summary id + version: `<id> <v1, v2, …>`

- overall judgement: `<accepted | rejected | gaps found, with reasons>`
- boundary: `<edge and degenerate cases checked — zero, empty, trivial, extremes, equality
  cases; the smallest nontrivial case>`
- canary: `<both seeded items caught?>`

## rules that bind this artifact

- the three summaries are separate, versioned artifacts; the Selector transfers them to the PI
  as files, and the PI receives them before the 98–113 window.
- the reviewer's verdict outranks the PI's confidence: the PI may repair and resubmit (change
  list + rebuttal) but may not overrule; if the PI believes a reviewer erred, that objection is
  itself a new claim sent to an independent review.
- the route is accepted only if ≥2/3 of the swarm workers AND ≥2/3 of the BCD reviewers agree;
  the milestone requires 9/9 + 3/3 and the accepted routes together achieving the locked goal.
- the panel findings that reject a route become the failure reason of its stale entry, and the
  promoter's nearest true version note enriches the fragments sent to the Creator's second
  phase.
