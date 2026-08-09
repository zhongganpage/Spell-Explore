# attempts-log.md — the heart of the persistence protocol

append-only, dated. every worker that runs the exploration loop records its outcome here before it closes. a worker's work is successful if and only if it leaves the dossier strictly more informative — "the problem is still open" is not a failed worker.

this file is the split-out attempts-log section of the dossier (see the ~30 KB split rule and the Knowledge State navigation index in ./index.md). a fresh worker reads the dossier — starting from the index — before anything else; nothing the project knows lives only in a previous context.

## the entry — five fields, no more, no less

```
### <date> — thread <T#>, move <M#>
tried:    <exactly what was attempted>
broke:    <where it failed, or "no progress">
implies:  <what this excludes / suggests / leaves open>
next:     <one concrete next action>
```

a "no progress" entry is a good entry. an entry missing `broke` or `next` is a bad one and must be completed before the worker closes.

## the rules that make the log work
- append-only: a new insight is a new entry, never an edit to an old one.
- dated; round and phase noted where relevant. entries use the locked notation (one fixed block, kept with the index; all entries must use it).
- every entry ends with a next step, even a failure entry. if you cannot write one, walk down the stuck ladder until you can.
- dead ends must be recorded (R3): an unrecorded dead end is guaranteed to be re-attempted by a future worker.
- search failures are recorded too: "searched X, found nothing relevant" prevents the same fruitless search from being repeated.
- separate "known" from "believed": entries that cite external results carry the source; entries that are the worker's own reasoning are marked as such. never reuse a stale fact — an entry is valid evidence only while its source and hypotheses still hold.
- a rejection is not a failure entry: it is a normal recorded outcome (persistence rule R3), and in the project it becomes a stale-rule entry with fragments and a revival trigger.
- mark a thread `stalled` only via stuck-ladder step 7, with the reason and a one-line "resume here"; the problem itself never becomes abandoned.
- write as you go: record each move immediately, never save up entries for the end — context compaction can destroy unrecorded thinking. the attempts-log entry is the highest-priority write.
- never re-derive locked statements: the goal statement and notation live in one locked place; restating "in your own words" is for drift-checking, not replacing.

## the exploration loop — every worker runs this
1 LOAD — read the dossier via the index; pick the top open thread / next step
2 ATTACK — apply exactly one move from the transformation toolkit
3 RECORD — append the outcome here, 2–5 lines
4 UPDATE — adjust the status line, the examples table or the reformulations if warranted
5 NEXT — write the next concrete step

start: restate the problem in your own words against the locked goal statement (catches definition drift); take the top next step written by the previous worker — never start a fresh attack from scratch while a thread is mid-flight.

end (non-negotiable): append the attempts-log entry; update the status line and any changed tables; write the next step.

## the moves (transformation toolkit, M1–M11) — every entry names its move
M1 compute examples · M2 extremes and limits · M3 specialize · M4 generalize · M5 reformulate · M6 prove partial directions · M7 key-lemma hunt · M8 extremal principle · M9 induction and monotonicity · M10 computational experiments · M11 literature triangulation.
keep a tick list of which moves a thread has seen (stuck-ladder step 1).

## the stuck ladder — escalate in order, no skipping
1 untried moves · 2 re-read the dossier · 3 new reformulation → new search · 4 reduce to a baby case · 5 split the problem (a partial result is a durable asset) · 6 the floor — produce a trial proof (every gap labelled GAP:) or a proof for a semi-explicit example, recorded as a draft · 7 only now mark the thread `stalled` with reason + "resume here", and open a new thread.

## how this log connects to the project
- the persistence discipline binds the Creator's phase-2 workers and the Producer's report worker.
- the minimum-output floor: a worker that cannot produce a good idea still returns a trial idea or a worked example instead of nothing; it is recorded as a draft, never as a claim of correctness — the verification discipline judges it.
- the fragments of the stale rule carry the "resume here" of stalled threads.
- the Coordinator reads the dossier (this log included) after each round to measure the system: the idea-yield (routes accepted vs agent-time spent), premature kills (stale or unaccepted items whose fragments later end up inside an accepted route, and whether they were killed by evidence or by opinion), and the consistency of the panel verdicts. these measurements are recorded in the dossier and may feed back into the examine worker's rigor — never into the votes, whose acceptance thresholds are fixed (a route is accepted only if ≥2/3 of the swarm workers AND ≥2/3 of the BCD reviewers agree; a milestone = 9/9 + 3/3 + the accepted routes together achieving the locked goal).
- the repair channel: a claim rejected in the verification ledger returns to the author as a repair task — an ordinary attempts-log entry — then goes back to review (at most two review rounds).

## template entries — illustrations; real history begins at round 1
### 2026-08-09 — thread T1, move M1
tried:    computed the smallest nontrivial case by hand (recorded in examples.md)
broke:    no progress — the case collapses into the general mechanism, no pattern yet
implies:  nothing excluded; leaves open whether the case hides the same obstruction
next:     run M2 on the degenerate case (zero / empty / identity) and record the result

### 2026-08-09 — thread T2, move M11
tried:    literature triangulation on reformulations.md Form 2
broke:    searched <terminology>; nothing relevant (nearest known theorem: <source, theorem>)
implies:  the claim is not ruled out by the known literature; not known ⇒ not impossible
next:     record the source in literature-map.md, then M3 specialize to the provable subfamily

### 2026-08-09 — thread T3, move M7
tried:    key-lemma hunt — stated the lemma that would solve the thread and attacked it standalone
broke:    the proof fails at the third step; the lemma needs hypothesis <H>, which fails in case <c>
implies:  the lemma is false as stated; the bottleneck is <H>, so any repair must weaken it
next:     weaken <H> to <H'> and re-run M7; if the lemma still breaks, split the thread (stuck-ladder step 5)
