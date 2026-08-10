# timekeeping — the Coordinator's clock loop

this file is the operational clock loop of the round: announce the round start,
timestamp every phase boundary, poll at every window end, and cut the phases that
overrun. it is the companion of the timeline table in the Coordinator rule (§5) —
the windows there are the binding per-phase limits; this file is how the Coordinator
keeps the clock. it is written for the Coordinator agent to read and act on.

## 1. before any spawn — the round start

- before any agent spawns, the Coordinator records the round start in the dossier —
  `date +%FT%T` — and announces it to the user; the 138-minute budget counts from
  that timestamp.

## 2. at each phase boundary — the phase-time table

- at each phase boundary the Coordinator records the phase's start and end
  timestamps into the phase-time table; the table lives in the round-close record
  (templates/round-close.md) and is filled in as the round runs — timestamps are
  never reconstructed after the fact.
- the recorded line follows the table's columns: phase · window · start · end · cut?
  · partial output.

## 3. at each window end — poll and cut

- between the window ends the Coordinator services the spawn channel: it polls the
  spawn-request directory (runtime/requests/), validates each request against the
  locked format, spawns the requested workers named by their labels, appends the
  status line, and executes the resume/stop operations the subcoordinators instruct
  (the spawn broker, Coordinator rule §3).
- at each window end the Coordinator polls the live state (TaskList); any worker of
  the phase still running is stopped (TaskStop), and the cut is recorded in the
  phase-time table together with the partial output path — the Coordinator's
  TaskList covers only the tasks it spawned; owner-spawned swarms are cut by their
  owners (the Selector its decision swarm at the window end, the Formalizer its own
  swarm's limits). the partial output itself
  is recorded per the cut rule of the Coordinator rule (§5).
- a round close never cuts the Formalizer's swarm: the Formalizer is not bound by
  the round budget.

## 4. the binding phase-budget table

the table below is moved here from the old config.toml: the binding per-phase limits
of the 138-minute round (critical path, one route). changing any window means the
138-minute budget no longer holds. rounds ≥ 3 add the Producer's 1-minute
choice at the 20-min mark: the windows after it shift +1 (21–46, 46–64,
64–104, 104–119, 119–139) and the total is 139 minutes; rounds 1–2 run 138.

| window | phase | binding notes |
|---|---|---|
| 0–20 | Creator phase 1 | n idea-workers (0 ≤ n ≤ 8) think ≤10 min, write their summaries ≤10 min; fresh summaries ready by ~20 min |
| 20–45 | Producer report worker | writes the idea report, 25 min |
| 45–63 | hygiene linter + examine | linter layer 1 ≈3 min, layer 2 ≈7 min, then the examine worker (cap 8 min) |
| 63–103 | Selector panel | workerA lists the evidence points by 78 min; workerB/C/D review 63–93 min (workerD: exterior invocation); exchange + review summaries 93–103 min |
| 103–118 | PI rebuttal + promoter note | in parallel, the promoter's nearest true version note in the same window |
| 118–138 | decision swarm + BCD vote | decision swarm 20 min + BCD reviewers 20 min (B/C resumed; workerD re-invoked externally) |

off the critical path and in the background: the Creator's phase 2, the Formalizer —
not bound by the round budget, and a round close never cuts its swarm — and any
additional report workers.

## 5. optional — a subagent-completion hook

an optional hook appends a timestamped line to the phase-time table automatically
whenever a subagent completes, instead of a manual record at each boundary. the
phase-time table is the round-close record's table at the project root — the
scaffold does not ship templates/ — and the appended line follows the table's
columns: phase · window · start · end · cut? · partial output. a bash example:

```bash
# subagent-completion hook: append a timestamped line to the phase-time table
# (the table lives in the round-close record, round-close.md at the project root).
phase="$1"; worker="$2"; status="$3"
printf '%s | %s | %s | %s\n' "$(date +%FT%T)" "$phase" "$worker" "$status" \
  >> round-close.md
```

## 6. the clock watcher — belt and suspenders

the window-end polls of §3 are executed by the Coordinator when it is active; a
turn that ends before a window end leaves the round silent until something wakes
it. the clock watcher guarantees a wake every 2 minutes regardless of turn
endings:

- at round start, right after the round-start timestamp is recorded, the
  Coordinator spawns a background sleep of 2 minutes — `sleep 120` via the shell.
  a pure sleep: no model, no artifact, no context.
- the sleep's completion wakes the Coordinator every 2 minutes; on each wake it
  computes the elapsed time from the round-start timestamp, runs the §3 procedure
  for every window boundary that has passed since the last recorded boundary —
  poll the live state (TaskList), TaskStop the still-running workers of the phase,
  record the cut and the partial output path in the phase-time table, timestamp
  the boundary — and checks for stalls (expected artifacts missing with nothing
  running → restart per rules/coordinator.md §4), then re-spawns the watcher for
  the next 2 minutes; at the final boundary (138 / 139) it closes the round
  atomically instead.
- a wake that arrives while the Coordinator is mid-turn is held by the runtime and
  delivered at the next turn boundary — it never interrupts work in progress, and
  it is never lost: the wake procedure is idempotent, recording only the boundaries
  not yet present in the phase-time table, so a delayed wake catches up on every
  boundary that passed meanwhile in a single pass (if the Coordinator's own turn
  already handled a boundary, the row exists and the wake is a no-op for it), and
  the watcher is re-spawned on every processed wake — the cadence resets to 5
  minutes from the wake moment, and drift from long turns is acceptable.
- every wake opens with a current-status table, shown to the user and mirrored
  into runtime/coordinator-state.md, so the round's live state is always visible
  and always resumes from a file: `round clock` <minute>/<total> · `current
  phase` <window> · `subcoordinators` the Creator / Producer / Selector /
  Formalizer stages (the Formalizer's status line: green count, [Formalized]
  count, goal distance) · `live workers` <label> — running | done | cut, with
  task-ids and output paths · `pending artifacts` <paths> · `last boundary`
  <min>: cut? partial output · `next action` spawn | resume | cut | close. the
  table is compact — one row per item, the details live in the files.
- the watcher is a registered live worker, not a background assumption:
  runtime/coordinator-state.md records `watcher-spawned-at <timestamp>`, and
  every wake and the round-start check verify the watcher task is alive in
  TaskList, re-spawning it when missing — a missing watcher is a stalled worker
  like any other (rules/coordinator.md §4).
- every wake first verifies the previous wake's duty by file before doing its
  own: the boundary rows for the elapsed interval are recorded in the phase-time
  table and the watcher row is present in the registry — anything missing is
  repaired in this wake and recorded in the dossier, never assumed ('verify and
  continue', never redo). a wake that finds the previous wake's outputs absent
  records the gap in the dossier: the audit trail is the files.
- the status table is the user-visible canary: if the chain breaks, tables stop
  appearing within 2 minutes, and the user's next prompt resumes the round from
  runtime/coordinator-state.md — the files, never the watcher, are the recovery
  path.
- the watcher is recorded in the worker registry (runtime/worker-registry.md) and
  in runtime/coordinator-state.md; the round-start check re-spawns it whenever a
  resumed session lost it. if the watcher's wake still fails to re-engage the
  Coordinator (a runtime behavior outside the protocol's control), the round
  resumes from coordinator-state.md on the next prompt — the watcher is
  belt-and-suspenders, never the only recovery path.
