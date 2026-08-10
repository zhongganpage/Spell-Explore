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
| 63–103 | Selector panel | workerA lists the evidence points by 78 min; workerB/C/D review 63–93 min; exchange + review summaries 93–103 min |
| 103–118 | PI rebuttal + promoter note | in parallel, the promoter's nearest true version note in the same window |
| 118–138 | decision swarm + resumed BCD | decision swarm 20 min + resumed BCD reviewers 20 min |

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
