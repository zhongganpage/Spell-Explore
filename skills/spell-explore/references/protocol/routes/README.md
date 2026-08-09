# routes — protocol/routes/

Versioned routes live in the project folder (not in the dossier). a route (lock
this name) is a successful idea report renamed by the Producer and given a title
to distinguish it from other routes; the Producer archives it properly with
versions.

## What lives here

- the routes, each with its title and a version (v1, v2, …); nothing is cited or
  built on without its version.
- the accepted / unaccepted marks of the Selector's decision, recorded in the
  archive, and the running canary detection rate.

## Who writes

- the Producer archives each route with versions, and marks an accepted route a
  new version.
- the PI (lock this name) — the worker who produced the route and remains —
  modifies the route and rebuts within its 15 minutes (window 98–113); the
  change list and the rebuttal are handed to the decision swarm.
- the Selector marks routes accepted / unaccepted in the archive.

## Who reads

- the Selector: it reviews each fresh route as it becomes ready with a
  four-worker adversarial review panel — workerA lists the evidence points (by
  73 min), workerB checks inconsistencies and readability, workerC hunts
  counterexamples, workerD makes the overall judgement. the BCD reviewers write
  the three review summaries (lock this name), pause, and vote again at the
  swarm stage with their panel context.
- the promoter: a fresh-context worker that, in the same window as the PI
  (98–113), reads the route and the three review summaries and writes the
  nearest true version note — the strongest claim the route can honestly make
  and the exact point where it breaks.
- the decision swarm of ~9 workers (window 113–133): it reviews the panel, the
  original route, the modified route and the rebuttals.
- the user: the accepted route is presented before it is marked a new version,
  and the user decides on each unaccepted route — recycle it back to the
  Creator, or park it (the fragments are kept but it is not auto-recycled).

## Acceptance and milestone

- a route is accepted iff at least 2/3 of the swarm workers AND at least 2/3 of
  the BCD reviewers agree. acceptance numbers rank quality: full consensus
  (9/9 + 3/3) is the strongest; lower counts are accepted but weaker.
- the project reaches a milestone only if all 9 swarm workers and all 3 BCD
  reviewers accept, and the accepted routes together achieve the locked goal —
  then the Coordinator writes the manuscript (lock this name).

## Notes

- the canary gate: each panel carries a seeded known-false claim and one planted
  step-error in the review batch (both excluded from the real record and the
  route); the route may not be accepted unless the panel catches the claim
  (≥80%) and the step-error (100%, with the step cited). the running detection
  rate is recorded in the archive.
- for every accepted route, the summaries, the idea reports, the route with its
  versions and the review reports are copied to question-routes/<title>/.
