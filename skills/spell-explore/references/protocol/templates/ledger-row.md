# verification ledger row — template

the verification ledger is append-only and dated, one row per review round — history is
preserved, never overwritten. the verdict column carries the reviewer's reasons, never the
author's. a claim is established only after an independent review accepted both the claim and
the proof; author confidence — "I checked this", intuition — is never recorded as a verdict.
this file is the template for a single row; rows are appended to the ledger as reviews resolve.

## who, when, where

- maintained by: the Coordinator and the subcoordinators, at every review that resolves a
  claim.
- where it lives: the verification ledger in the dossier (split out into its own file once the
  dossier exceeds ~30 KB).
- which reviews write rows: the examine worker's sufficiency verdict, each of the three review
  summaries' judgements, each swarm decision, each canary detection, and the lean code runner's
  green results — a [Formalized] piece enters as accepted-by-lean, and an assumption becomes
  [Hired] when it is implied through a green lean code by an existing assumption (node).

## the row

| date | claim | status | reviewer | verdict & reasons | repair targets / notes |

- **date**: `<date of the review round, not of the claim>`
- **claim**: `<the claim as stated — statement, the version of the artifact that carries it,
  and its location>`
- **status**: `<claimed | under-review | accepted | rejected | counterexample>`
- **reviewer**: `<the independent reviewer id — it had no access to the author's context,
  reasoning, false starts, or confidence; a different agent/backend/model when the harness
  allows it, at minimum a fresh context window>`
- **verdict & reasons**: `<the reviewer's verdict and reasons — accepted, or rejected with
  specific repair targets, or gaps found with non-blocking notes; never the author's belief or
  "this should be right">`
- **repair targets / notes**: `<for rejected: the step, the missing hypothesis, the
  counterexample; for accepted: what may now build on it>`
- convention: accepted rows record the route's declared-axiom dependence (`footprint: none |
  declared: <list>`) and its residual delta (`delta: <subgoal + measure> | none`); a
  [Formalized] row always carries `footprint: none`.

## rules that bind this artifact

- a claim in claimed or under-review is never used as a premise — not by later work, not in
  reporting to the user. only an accepted claim (including the [Formalized] pieces and the
  [Hired] assumptions of ITG.lean (the Integrator)) may be treated as established.
- the repair loop is bounded: at most two review rounds, then the claim is parked as rejected
  with its full history, and a fresh attack starts a new thread.
- the reviewer's verdict outranks the author's confidence: the author may repair and resubmit,
  may not overrule; if the author believes the reviewer erred, that objection is itself a new
  claim sent to an independent review.
- the lifecycle is realized in this architecture as fresh summary → idea report → route →
  accepted route. the hygiene linter is the first gate (it cuts failures); the examine worker
  is the first independent review gate — it checks sufficiency only and does not judge
  correctness; the panel implements the reviewer checklist — workerA checks the claims and
  whether the evidence really supports them (the claim), workerB checks proofs and
  inconsistencies (the proof), workerC hunts counterexamples (the boundary), workerD makes the
  overall judgement (the verdict); the swarm's ≥2/3 verdict together with the resumed BCD
  reviewers' ≥2/3 vote outranks the PI's rebuttal. the milestone is 3/3 + 3/3 with the accepted
  routes together achieving the locked goal.
- a rejection is not a failure entry — it is a normal recorded outcome (R3 of the persistence
  protocol).
