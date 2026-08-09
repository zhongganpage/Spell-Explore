# Worker lifespans — hold-open connections across the pipeline

## the invariant — no subcoordinator closes a worker that a later stage of the same pipeline still needs; every held-open worker is either resumed or explicitly closed.

## the report worker → PI connection (Producer → Selector)

the Producer does not close a successful report worker — it becomes the PI, resumable across the Selector's review and any later revision of the route.

## the PI across rounds (Selector → later rounds)

an accepted route may be challenged or revised in a later round; the Coordinator or the Selector re-invokes the route's PI (resume-by-ID, context preserved) for that defense.

## the Creator's rotation hold

the Creator holds all n idea-workers open from thinking (phase 1) or searching (phase 2) through the rotation to the summaries — it waits for all n ideas before rotating, and for all n summaries before archiving; no idea-worker closes mid-rotation.

## the BCD pause (Selector-internal)

workerB, workerC and workerD do not close after their review summaries — the Selector holds them paused, with their panel context, across the PI rebuttal window, and resumes them for the vote at 113–133; only then they close.

## the working swarm's resumable window

a working-swarm agent lives 30 minutes and is resumable within that window — the Formalizer resumes a cut agent inside the window so its context continues; the 5-minute tail is its end-of-life handoff to the fragment region.

## the lean-runner swarm's work handoff

unfinished verification work of a closed lean-runner swarm agent returns to the lean code runner's next plan.

## the lean code runner across rounds

the lean code runner is resumable across rounds; the Coordinator resumes it on every qmd file update and restores it — with the four subcoordinators and the PIs — after a session resume.

## relationship to the lifecycle rule

the subcoordinators, the PIs, and the lean code runner are single-run orchestrators: each runs its phase to completion in one run (spawning its workers in the background, waiting for every artifact, integrating, then returning) and is resumed by the Coordinator for the next phase; a subcoordinator never returns early — a narrated step is not a done step. this file lists the workers whose lives the stages must hold open.
