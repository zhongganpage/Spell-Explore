# residual-registry.md — the bounded subgoal list toward the locked goal

the residual registry holds the subgoal list toward the locked goal: bounded at the cap — at most 5 active subgoals at any time — and the source of the round's residual targets and of the Creator's phase-2 mining. this file is the split-out residual-registry section of the dossier (see the ~30 KB split rule and the Knowledge State navigation index in ./index.md). a fresh worker reads the dossier — starting from the index — before anything else.

## the cap and the ownership

the active list is bounded at the cap: at most 5 active subgoals at any time. the champion-route defender PI proposes the subgoals — a clear list of major steps toward the goal, e.g. at route acceptance or at round close; the Coordinator curates: it inspects the support of each proposal against the route material and the verification-ledger rows and economizes — merges overlapping proposals, drops unsupported ones, trims to the cap — and records the survivors as subgoals here.

## entry format

each subgoal entry carries: the statement (a major step toward the goal); proposed by (the PI id + the route version); support (what the Coordinator verified); measurable delta (how progress is measured); status (`open | in-progress | closed`); the recorded round; the rounds that named it as a round's residual target.

```
### <subgoal id> — <statement: a major step toward the goal>
- proposed by: <PI id> + <route version>
- support: <what the Coordinator verified — the route material and the verification-ledger rows behind the proposal>
- measurable delta: <how progress is measured>
- status: open | in-progress | closed
- recorded round: <round>
- named as a target: <rounds>
```

## the rules
- the active list is bounded at the cap: at most 5 active subgoals at any time.
- a subgoal closes when its measurable delta is achieved, measured via the verification ledger or the lean runner's green results; the close is recorded here with its round.
- closed entries are append-only, never edited; a subgoal that reopens is a new entry, never an edit to the old one.
- the registry feeds the round's residual targets — the 0–2 subgoals the Coordinator names at round start — and the Creator's phase-2 mining.

## template entries — illustrations; real subgoals begin at round 1

### S1 — <a major step toward the goal>
- proposed by: <PI id>, route <version>
- support: <Coordinator-verified: the route material and the verification-ledger rows>
- measurable delta: <a measure — a green lean code, an accepted claim, a counted node>
- status: open
- recorded round: R1
- named as a target: R2, R3
