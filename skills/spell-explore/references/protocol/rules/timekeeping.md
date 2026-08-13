# timekeeping — the Coordinator's clock loop

this file is the operational clock loop of the round: announce the round start,
timestamp every phase boundary, poll at every window end, and cut the phases that
overrun. it is the companion of the timeline table in the Coordinator rule (§5) —
the windows there are the binding per-phase limits; this file is how the Coordinator
keeps the clock. it is written for the Coordinator agent to read and act on.

## 1. before any spawn — the round start

- before any agent spawns, the Coordinator records the round start in the dossier —
  `date +%FT%T` — and announces it to the user; the round budget counts from
  that timestamp (138 min in rounds 1–2, 139 min in round 3, 149 min from round 4).

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
of the round (critical path, one route). changing any window means the round budget
no longer holds. round 3 runs 139 minutes (the Producer's 1-minute choice at the
20-min mark: the windows after it shift +1 — 21–46, 46–64, 64–104, 104–119,
119–139); from round 4 the rounds run 149 minutes (148-min base + the persisting
choice, with the same shifted windows: 21–46, 46–64, 64–109, 109–127, 127–149).

| window (rounds 1–2) | window (round 3) | window (rounds ≥ 4) | phase | binding notes |
|---|---|---|---|---|
| 0–20 | 0–20 | 0–20 | Creator phase 1 | n idea-workers (0 ≤ n ≤ 8) think ≤10 min, write their summaries ≤10 min; fresh summaries ready by ~20 min |
| 20–45 | 21–46 | 21–46 | Producer report worker | writes the idea report, 25 min |
| 45–63 | 46–64 | 46–64 | hygiene linter + examine | linter layer 1 ≈3 min, layer 2 ≈7 min, then the examine worker (cap 8 min) |
| 63–103 | 64–104 | 64–109 | Selector panel | workerA lists the evidence points by 78 / 79 / 84 min; workerB/C/D review 63–93 / 64–94 / 64–99 min (workerD: exterior invocation); exchange + review summaries 93–103 / 94–104 / 99–109 min |
| 103–118 | 104–119 | 109–127 | PI rebuttal + promoter note | in parallel, the promoter's nearest true version note in the same window |
| 118–138 | 119–139 | 127–149 | decision swarm + BCD vote | decision swarm 20 / 20 / 22 min + BCD reviewers 20 / 20 / 22 min (B/C resumed; workerD re-invoked externally); in the same window the resumed promoter marks the route's connections into the single qmd file (rules/selector.md §7.1) |

off the critical path and in the background: the Creator's phase 2, the Formalizer —
not bound by the round budget, and a round close never cuts its swarm — the
Integrator (its 45 + 15 = 60-minute worker pair runs off the critical path, in the
background), and any
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

## 6. the clock watcher — event-driven, never zero

the window-end polls of §3 are executed by the Coordinator when it is active; a
turn that ends before a window end leaves the round silent until something wakes
it. the clock watcher guarantees the round is watched at every fixed boundary and
handoff even when its turn ended earlier or a wake was missed. the watcher is a
set of scheduled jobs — one-shot fires at the round's fixed moments plus one
recurring backstop — not a single one-shot background task, so it is self-arming
by construction and cannot be forgotten the way a manual re-spawn can. the
cadence exists to cut boundaries and service handoffs, and it is the dominant
measured Coordinator cost (the token analysis: ~30% of Coordinator turns and of
its token spend were watcher wakes), so it is set as low as the timeline's
variable handoffs allow — a wake every ~3 minutes is only needed where a handoff
can complete mid-window, not everywhere:

- at round start, right after the round-start timestamp is recorded, the
  Coordinator computes the round's wall-clock schedule from that timestamp and
  the binding timeline (§4) and creates the watcher set on the engine's
  scheduler:
  - **boundary one-shots** — a one-shot scheduled job (`recurring = false`) at
    every binding window end: rounds 1–2 at 20, 45, 63, 78, 93, 103, 118, 138
    minutes into the round; round 3 at 21, 46, 64, 79, 94, 104, 119, 139; rounds
    ≥ 4 at 21, 46, 64, 84, 99, 109, 127, 149 — so each boundary is cut at its
    exact minute;
  - **handoff checkpoints** — one-shot jobs at 3-minute spacing inside the two
    variable-handoff windows, 0–20 (the Creator's phase-1 rotation — when all n
    idea files are in, the Coordinator builds the rotation briefs and resumes the
    workers) and 45–63 (the linter→examine handoff — the Producer files the
    examine request when the linter is done, and the Coordinator spawns it on the
    next fire); in the rounds ≥ 3 variant the gate window shifts +1 (46–64), the
    Creator window does not. a handoff that completes mid-window is serviced
    within ~3 minutes, as the old 2-minute poll served it before;
  - **the backstop** — one recurring job firing every 10 minutes —
    `CronCreate(cron = "*/10 * * * *", prompt = "clock watcher wake — run the
    wake procedure of this section for the current round", recurring = true)` —
    self-arming by construction, so a missed or held one-shot never leaves the
    round unwatched for more than 10 minutes; a delayed backstop fire catches up
    on every boundary that passed in one pass (the wake procedure is idempotent,
    below). off-critical-path work (the Creator's phase 2, the Formalizer's
    decompose and swarm) is served by the backstop and tolerates its cadence —
    none of it is bound by the round budget.
  - every job above carries the locked wake prompt — the Coordinator uses it
    verbatim and verifies each by CronList; the job ids are recorded in
    runtime/coordinator-state.md (`watcher-boundary-<min> <job-id>`,
    `watcher-checkpoint-<min> <job-id>`, `watcher-backstop <job-id>`).
- each fire is a wake delivered by the runtime: a fire that arrives while the
  Coordinator is mid-turn is held and delivered at the next turn boundary — it
  never interrupts work in progress, and it is never lost. one-shot fires
  auto-delete after firing; the backstop keeps firing on schedule; there is no
  re-arm step. at the atomic round close the Coordinator deletes the backstop
  job and cancels any not-yet-fired one-shot (CronDelete), so nothing fires
  after the round closes — the next round creates its own set
  (rules/coordinator.md §6).
- on each wake the Coordinator computes the elapsed time from the round-start
  timestamp, runs the §3 procedure for every window boundary that has passed
  since the last recorded boundary — poll the live state (TaskList), TaskStop
  the still-running workers of the phase, record the cut and the partial output
  path in the phase-time table, timestamp the boundary — services pending spawn
  requests (the spawn broker of Coordinator rule §3), and checks for stalls
  (expected artifacts missing with nothing running → restart per
  rules/coordinator.md §4). at the final boundary (138 / 139 / 149) it closes the
  round atomically instead, and the final-boundary check verifies the
  decision-stage artifacts for every route under review — the swarm votes, the BCD
  votes, the verdict, and the resumed promoter's connection-marking report with
  its marks in formalizer/single.qmd (rules/selector.md §7.1): a route whose marking
  report is missing at the final boundary is recorded as a pending item in the
  phase-time table and handed to the next round (or the repair session) at the close
  — the round closes atomically all the same, but a missing marking is never silently
  dropped.
- the wake procedure is idempotent: it records only the boundaries not yet
  present in the phase-time table, so a delayed or duplicated wake (a stale
  fallback completing while a scheduled job also fired) catches up on every
  boundary that passed in a single pass, and a row the Coordinator's own turn
  already handled makes the wake a no-op for it.
- wakes are quiet by default: the current-status table — `round clock`
  <minute>/<total> · `current phase` <window> · `subcoordinators` the Creator /
  Producer / Selector / Formalizer / Integrator stages (the Formalizer's status line: green
  count, [Formalized] count, goal distance; the Integrator's status line: integration-report summary — nodes, edges) · `live workers` <label> — running
  | done | cut, with task-ids and output paths · `pending artifacts` <paths> ·
  `last boundary` <min>: cut? partial output · `next action` spawn | resume |
  cut | close — is shown to the user only when the wake did something real: it
  cut a boundary (a new row in the phase-time table), repaired a stall, saw a
  worker complete since the last wake, or closed the round. the table is always
  mirrored into runtime/coordinator-state.md, so the round's live state always
  resumes from a file. a wake with nothing new to report writes one line `wake
  <ts> no-op` to runtime/coordinator-state.md and ends without a user-visible
  table — a no-op wake still ran the §3 procedure and the verify-and-continue
  duty check above. the table is compact — one row per item, the details live
  in the files.
- every wake first verifies the previous wake's duty by file before doing its
  own: the boundary rows for the elapsed interval are recorded in the phase-time
  table and the watcher row is present in the registry — anything missing is
  repaired in this wake and recorded in the dossier, never assumed ('verify and
  continue', never redo). a wake that finds the previous wake's outputs absent
  records the gap in the dossier: the audit trail is the files.
- the watcher's liveness is part of the Coordinator's turn discipline, not only
  of wakes (rules/coordinator.md §3): before ending any turn that leaves the
  round mid-flight, the Coordinator verifies the watcher set is live — the
  `watcher-backstop` row present in CronList with the locked wake prompt, and
  every not-yet-fired boundary and checkpoint one-shot still scheduled — and
  re-creates any missing job in the same turn; the round-start check does the
  same when a resumed session lost them. a missing watcher is a stalled worker
  like any other (rules/coordinator.md §4). a backstop job that a long-lived
  session let go stale (the scheduler's 7-day auto-delete) is re-created by the
  same guard at the next turn end or round start.
- fallback: on an engine without a scheduler, or when CronCreate fails, the
  Coordinator uses the one-shot background `sleep 600` instead — a pure sleep:
  no model, no artifact, no context — re-spawned on every completion AND by the
  turn-end liveness guard above; runtime/coordinator-state.md records
  `watcher-spawned-at <timestamp>` and the task id, and the round-start check
  re-spawns it whenever a resumed session lost it. the fallback is
  belt-and-suspenders: the invariant is never zero watchers, enforced by the
  liveness guard at every mid-round turn end.
- the status table is the user-visible canary, now event-driven: quiet wakes
  show nothing, so a broken chain surfaces at the next event wake (a boundary
  cut, a stall repair, a worker completion, the close) or at the user's next
  prompt, and the round resumes from runtime/coordinator-state.md — the files,
  never the watcher, are the recovery path. if a wake still fails to re-engage
  the Coordinator (a runtime behavior outside the protocol's control), the
  round resumes from coordinator-state.md on the next prompt — the watcher is
  belt-and-suspenders, never the only recovery path.

## 7. the round-close context compaction

the Coordinator's context grows across rounds, and every later turn — a user turn
or a wake alike — re-reads all of it: the dominant measured cost of the system
(the token analysis). each atomic round close is a safe compaction point: every
artifact is a file, the round resumes from runtime/coordinator-state.md and the
resume packs, and the next round re-reads the dossier from disk — nothing lives
only in the conversation. so at each close the protocol asks the user to compact:

- at the atomic round close, when rounds remain and no stop condition applies,
  the Coordinator asks the user to run `/compact` with the locked instruction
  below — relayed verbatim — together with the decision list. the request is
  recorded as `pending-compact` in the round-close record and never blocks the
  next round's start: if the user does not compact, the next round starts anyway
  on the un-compacted context, and the Coordinator re-asks at the next close.
- the locked instruction:
  `Compact the conversation context to free token usage. Preserve: the locked goal (goal.md), the round ledger and lifecycle line in runtime/coordinator-state.md, the dossier index and Knowledge State pointers, the worker registry and every resume pack in runtime/, and any pending user decisions (recycle/park, pairings). All project state is on disk — re-read from the files, never re-derive.`
- compaction loses nothing: the round resumes from files, never from the
  conversation, and `/compact` with the instruction above keeps the pointers the
  next round needs to find them.
