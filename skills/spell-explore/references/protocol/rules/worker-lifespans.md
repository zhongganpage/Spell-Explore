# Worker lifespans — hold-open connections across the pipeline

## the invariant — no worker that a later stage of the same pipeline still needs is closed; the Coordinator holds every task, and the subcoordinators direct the holds.

## the report worker → PI connection (Producer → Selector)

the Producer does not close a successful report worker — it becomes the PI. the Producer directs the Coordinator to hold the worker open as the PI, resumable across the Selector's review and any later revision of the route; the worker keeps its birth label.

## the PI across rounds (Selector → later rounds) and the handover

an accepted route may be challenged or revised in a later round; the Coordinator re-invokes the route's PI (resume-by-ID, context preserved) for that defense, on the Selector's instruction — the Coordinator holds the task. the route's defender is the PI of its latest accepted version: it defends the route — any version — against every future challenge.

when a revision of an accepted route is accepted and the user has seen it, a handover happens: the new PI — the Producer phase-2 route writer of the accepted revision — writes the accepted revision into question-routes/<title>/ as the new version and marks the older version superseded (old files are never edited — immutability preserved). the Coordinator records the current-defender-PI pointer, marks the replaced PI's resume pack (runtime/<title>-pi-state.md) superseded, and TaskStops the replaced PI task. the new PI takes over as the defender for all versions of the route; the replaced PI closes — its defense is finished and the handover is complete. hard invariant: the replaced PI is TaskStopped immediately at the handover and is never held open or resumed; only the current defender PIs of the accepted routes stay held.

resume packs are recorded per version: runtime/<title>-pi-state.md carries the route version it defends, and a superseded pack stays recorded, never deleted.

same-title serialization: no two reviews of the same route title run concurrently; an in-flight challenge finishes before a handover starts.

## the Creator's rotation hold

the rotation is Coordinator-owned and mechanical: the Coordinator holds all n idea-workers open from thinking (phase 1) or searching (phase 2) through the rotation to the summaries — no idea-worker closes mid-rotation — and when all n idea files are in it builds the per-worker rotation briefs (each carrying the preceding worker's idea) and resumes the workers (resume-by-ID, context preserved). the Creator is not resumed for the rotation: its phase runs may end once their spawn requests are filed, and the Coordinator resumes it after the summaries land to verify, archive, and hand off.

## the BCD pause (Selector-internal)

workerB and workerC do not close after their review summaries — the Selector directs the Coordinator to hold them paused, with their panel context, across the PI rebuttal window, and to resume them for the vote at 118–138; only then they close. workerD (the exterior reviewer) is not a held subagent: the Coordinator invokes it twice — the review and exchange (63–103) and the vote (118–138) with a consolidated prompt — and its context is reconstructed from files, never from a paused task (modules/providers.md).

## the working swarm's resumable window

a working-swarm agent lives 30 minutes and is resumable within that window — the working swarm is the Formalizer's own (spawned and regulated by it), so the Formalizer resumes a cut agent inside the window directly so its context continues; the 5-minute tail is its end-of-life handoff to the fragment region.

## the lean-runner swarm's work handoff

unfinished verification work of a closed lean-runner swarm agent returns to the lean code runner's next plan. the lean code runner's swarm is its own: it spawns and regulates it, and the Coordinator does not intervene.

## the lean code runner across rounds

the lean code runner is resumable across rounds; the Coordinator resumes it once per round at the round start — batched, never on every qmd file update — subject to the lean-runner gate (rules/coordinator.md §1: manual mode asks run-or-postpone, auto mode resumes automatically per the round-1 runner-mode), and restores it — with the four subcoordinators and the PIs — after a session resume. a postponed runner is recorded paused (worker registry + the Formalizer's resume pack) and is not resumed on any trigger until the user runs it.

## resume packs and the worker registry — recovery after a process restart

resume-by-ID is the fast path within a live process; background tasks do not survive a process restart — the runtime treats the tasks of a previous process as lost, so their IDs no longer resolve. every long-lived role therefore maintains a resume pack: a versioned state file at runtime/<role>-state.md recording its current stage, its directed workers with their labels, their output paths, and the file pointers it needs to continue. after a restart the Coordinator re-spawns the role fresh and hands it the resume pack instead of resuming it by ID. the Coordinator also keeps the worker registry (runtime/worker-registry.md): the mapping request → task-ids → labels → output paths for every worker it has spawned, so a session resume restores each territory's live workers — a subcoordinator's pack records what it directs, the registry records what the Coordinator spawned. the PI's resume pack is thin: it points at the route file, the change lists and the review summaries — the state lives in the files. a subcoordinator's resume pack records its territory status and the pending artifacts it is waiting on (paths, never contents — the context economy rule, rules/coordinator.md §3). the Coordinator's own pack (runtime/coordinator-state.md) records its lifecycle — children-in-flight (<task-ids>, <pending artifact paths>) | awaiting-resume at <window> | round-closed — and the pending artifacts of the phase it left mid-flight, so a resumed prompt resumes the round from a file. the lean code runner's resume pack records its current verification plan and the qmd/dependency-graph pointers. resume packs are versioned like every artifact and live in the runtime/ directory the scaffold creates. a re-spawned Formalizer checks which per-fragment files exist under formalizer/fragments/ and re-assigns only the missing ones.

## relationship to the lifecycle rule

the subcoordinators, the PIs, and the lean code runner are single-run orchestrators: each runs its phase to completion in one run (requesting its workers from the Coordinator, waiting for every artifact, integrating, then returning) and is resumed by the Coordinator for the next phase; a subcoordinator never returns early — a narrated step is not a done step, and its final message comes only after every worker it directs has produced its artifact at the assigned path and it has verified the write. it polls TaskList/TaskOutput while its workers are in flight; closing while a worker it directs is unverified is an early return and a protocol violation, and the Coordinator records it; yielding is not closing — a role with in-flight owned children yields with lifecycle children-in-flight and auto-continues when they land (the lifecycle contract below). the one exception is the Creator's phase runs: they may end once their spawn requests are filed, because the mechanical rotation and the summary collection are Coordinator-owned steps; the Coordinator resumes the Creator after the summaries land to verify, archive, and hand off — this return is the phase boundary, not an early return. ## the lifecycle contract — yield vs close

a resumable role with in-flight owned children — the Selector with its decision swarm, the Formalizer with its working swarm, the lean code runner with its own swarm — does not close when its run returns: it yields (its final message states children-in-flight) and, when its owned children complete, the instance auto-continues to integrate their artifacts and closes by itself. the Coordinator must not resume such a role while it is in flight — the runtime rejects the resume ('already running'), and the rejection is the signal that the role is self-regulating: the Coordinator reads the role's latest output and the artifacts it owns, verifies by file, and waits for the role's self-completion; it never TaskStops a role that is actively producing artifacts. a role without in-flight owned children — the Creator, whose workers are Coordinator-spawned — closes at its phase boundary and is resumed later. every resumable role writes or updates its resume pack (runtime/<role>-state.md) at every phase boundary, so the Coordinator's next move is decided from a file, never from task-state inference; and each phase run's final message states its lifecycle: awaiting-resume | closed | children-in-flight. the Coordinator is the turn-based top agent and carries the same contract for its own turns: it writes its lifecycle to runtime/coordinator-state.md at every turn end and never ends a turn that leaves the round mid-flight undriven (rules/coordinator.md §3, "the Coordinator's own turn discipline").

this file lists the workers whose lives the stages must direct the Coordinator to hold open. the stale-worker — the dedicated worker that marks a staled accepted route on the Coordinator's instruction (rules/coordinator.md §3) — is a leaf worker: it closes once its job is done (stale entry written, fragments archived, paths confirmed), and nothing holds it open.
