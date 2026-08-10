# Worker lifespans — hold-open connections across the pipeline

## the invariant — no subcoordinator closes a worker that a later stage of the same pipeline still needs; every held-open worker is either resumed or explicitly closed.

## the report worker → PI connection (Producer → Selector)

the Producer does not close a successful report worker — it becomes the PI, resumable across the Selector's review and any later revision of the route.

## the PI across rounds (Selector → later rounds) and the handover

an accepted route may be challenged or revised in a later round; the Coordinator or the Selector re-invokes the route's PI (resume-by-ID, context preserved) for that defense. the route's defender is the PI of its latest accepted version: it defends the route — any version — against every future challenge.

when a revision of an accepted route is accepted and the user has seen it, a handover happens: the new PI — the Producer phase-2 route writer of the accepted revision — writes the accepted revision into question-routes/<title>/ as the new version and marks the older version superseded (old files are never edited — immutability preserved). the Coordinator records the current-defender-PI pointer, marks the replaced PI's resume pack (runtime/<title>-pi-state.md) superseded, and TaskStops the replaced PI task. the new PI takes over as the defender for all versions of the route; the replaced PI closes — its defense is finished and the handover is complete. hard invariant: the replaced PI is TaskStopped immediately at the handover and is never held open or resumed; only the current defender PIs of the accepted routes stay held.

resume packs are recorded per version: runtime/<title>-pi-state.md carries the route version it defends, and a superseded pack stays recorded, never deleted.

same-title serialization: no two reviews of the same route title run concurrently; an in-flight challenge finishes before a handover starts.

## the Creator's rotation hold

the Creator holds all n idea-workers open from thinking (phase 1) or searching (phase 2) through the rotation to the summaries — it waits for all n ideas before rotating, and for all n summaries before archiving; no idea-worker closes mid-rotation.

## the BCD pause (Selector-internal)

workerB, workerC and workerD do not close after their review summaries — the Selector holds them paused, with their panel context, across the PI rebuttal window, and resumes them for the vote at 118–138; only then they close.

## the working swarm's resumable window

a working-swarm agent lives 30 minutes and is resumable within that window — the Formalizer resumes a cut agent inside the window so its context continues; the 5-minute tail is its end-of-life handoff to the fragment region.

## the lean-runner swarm's work handoff

unfinished verification work of a closed lean-runner swarm agent returns to the lean code runner's next plan.

## the lean code runner across rounds

the lean code runner is resumable across rounds; the Coordinator resumes it on every qmd file update and restores it — with the four subcoordinators and the PIs — after a session resume.

## resume packs — recovery after a process restart

resume-by-ID is the fast path within a live process; background tasks do not survive a process restart — the runtime treats the tasks of a previous process as lost, so their IDs no longer resolve. every long-lived role therefore maintains a resume pack: a versioned state file at runtime/<role>-state.md recording its current stage, its spawned workers with their output paths, and the file pointers it needs to continue. after a restart the Coordinator re-spawns the role fresh and hands it the resume pack instead of resuming it by ID. the PI's resume pack is thin: it points at the route file, the change lists and the review summaries — the state lives in the files. a subcoordinator's resume pack records its territory status and the pending artifacts it is waiting on. the lean code runner's resume pack records its current verification plan and the qmd/dependency-graph pointers. resume packs are versioned like every artifact and live in the runtime/ directory the scaffold creates.

## relationship to the lifecycle rule

the subcoordinators, the PIs, and the lean code runner are single-run orchestrators: each runs its phase to completion in one run (spawning its workers in the background, waiting for every artifact, integrating, then returning) and is resumed by the Coordinator for the next phase; a subcoordinator never returns early — a narrated step is not a done step. this file lists the workers whose lives the stages must hold open.
