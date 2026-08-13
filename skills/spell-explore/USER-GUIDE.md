# Spell-Explore — user's guide (from agents to hands-free)

Spell-Explore runs a project of background agents against a locked goal in
138-minute rounds. This guide gets you from a fresh machine to a round running
hands-free.

## The cast — names and jobs

| role | job |
|---|---|
| **Coordinator** | top agent — runs each round, enforces the timeline, regulates the five subcoordinators, measures the system, writes the manuscript at a milestone |
| **Creator** | idea generation — phase-1 idea-workers think around the goal and write fresh summaries; phase-2 miners + graph workers mine stale material and bridging lemmas (graph workers read `formalizer/Integrator/ITG.lean`), and read the connection marks in single.qmd/qmd-index — a route's ideas connect the marked statements, and they may use those ideas |
| **Producer** | pairing and reports — report workers write idea reports from summary triples; the route writer revises accepted routes; the hygiene linter + examine worker gate them |
| **Selector** | adversarial review — workerA evidence list, B/C/D reviews (each also asks questions about any doubtful aspect), the promoter's nearest-true-version note, the PI rebuttal (answers the questions), then the decision swarm + BCD vote (answer quality weighs in): accept / accept-core / reject — with the re-invoked promoter marking, in the same window, every statement-pair the route's results or techniques bridge in the single qmd file (`[route-T-implied]` / `[route-F-initial]`) |
| **Formalizer** | Lean formalization — decompose workers split reports into fragments; the working swarm writes .qmd/.lean pieces; the lean code runner merges, verifies, and locks green pieces; the connection marks the promoter writes into single.qmd are mirrored into qmd-index.md at each merge |
| **Integrator** | fifth subcoordinator — owns the dependency graph as `formalizer/Integrator/ITG.lean` and the integration report (`formalizer/Integrator/integration-report.md`, the milestone source); runs two ephemeral workers (worker-1 = 45-min primary proof writer, worker-2 = 15-min secondary lean-run/fix) with a stable ID across rounds; writes `hireable-registry.md` and `connection-proofs.md`, second writer of the reliable idea set |
| **PI** | route owner — defends and modifies its route, rebuts the panel, writes the change list answering the reviewers' questions |
| **workerA / B / C / D** | evidence list / inconsistencies / counterexamples / overall judgement (D = the exterior reviewer X) — B/C/D also raise questions about any doubtful aspect |
| **swarm worker** | two lives — decision votes (3) or mechanical fragment transformation (working swarm ~4) |
| **lean code runner + swarm** | plans and dispatches lean verification, merges the single qmd, version-marks single.qmd / single.lean |
| **clock watcher** | not an agent — one-shot wakes at every window end and handoff checkpoint, plus a recurring 10-minute backstop (`*/10 * * * *`) that wakes the Coordinator, quietly unless it cut a boundary, fixed a stall, or closed the round (fallback: a background `sleep 600`) |

## 1. Installation

ask any agent to install the skill:

> "install the skill https://github.com/zhongganpage/Spell-Explore/"

the agent clones the repository, merges the protocol config into
`~/.kimi-code/config.toml` (`[subagent] timeout_ms = 0`, the secondary model), and
scaffolds a project folder. then start kimi in the project folder; the Coordinator
handles the round-1 setup from there.

## 2. Round 1 — five minutes of interaction, then hands-free

The Coordinator (the top agent) asks, in order:

1. your rough idea → written into the locked `goal.md` (never changed afterwards);
2. the number of rounds — the binding cap: the Coordinator runs that many rounds hands-free, auto-starting each next round at the close;
3. whether to add the exterior reviewer X for workerD (`X_PROVIDER` / `X_MODEL` /
   `X_ACCESS`, or none → internal reviewer, reduced diversity recorded);
4. the runner-mode: auto-run the lean code runner at each round start from round 2
   (resumed automatically whenever pending lean work exists), or ask run-or-postpone
   each time (manual — the default).

After that the round clock starts and the Coordinator runs the pipeline. You do
not drive it — you supervise it.

## 3. Hands-free operation

- At round start the Coordinator creates the **clock watcher** — one-shot wakes
  at every window end and handoff checkpoint, plus a recurring 10-minute
  backstop. Each wake: poll the workers, cut overruns at window ends, check for
  stalls, and mirror everything to
  `runtime/coordinator-state.md`. Wakes are **quiet by default** — a
  **status table** is shown to you only when the wake cut a boundary, repaired
  a stall, saw a worker complete, or closed the round; otherwise it logs a
  `no-op` line and stays out of the way. The watcher is self-arming — there is nothing
  to re-spawn; the Coordinator only verifies it is still scheduled (and
  re-creates a missing job). A wake that finds the Coordinator busy is held and
  caught up on — it never interrupts.
- **Rounds auto-continue**: at each round close the Coordinator starts the next
  round immediately when the count allows — stopping early only at a milestone,
  the two-consecutive-0/3 steering stop, or when you say stop. your per-close
  decisions (recycle/park, pairings) are presented at the close and never block
  the next round: unaccepted routes default to park until you answer.
- At each round close the Coordinator also asks you to run **`/compact`** with a
  given instruction — it frees the session's context so later rounds re-read a
  bounded history; it never blocks the next round if you skip it. the
  subcoordinators are bounded the same way: at each round boundary each closes
  and is spawned fresh from its resume pack, so the pipeline's contexts stop
  growing across rounds.
- Subagents run in the background; nothing closes early. The Coordinator's every
  turn ends with a lifecycle line, so the round always resumes from a file.
- What you actually look at:
  - the status table — shown only when a wake cut a boundary, repaired a
    stall, saw a worker complete, or closed the round (round clock, phases,
    live workers, pending artifacts, next action);
  - at round close, the **decision list** — abstracts of accepted routes; for each
    unaccepted route, **recycle or park**; your nominations for next-round pairings;
  - formalization news as it happens (a new green lemma, a new `[Formalized]`
    premise, the goal node's distance shrinking).

## 4. Milestone

The project reaches a milestone when the goal node of the integration report (`formalizer/Integrator/integration-report.md`) is
reachable from the established base (kernel axioms + Mathlib + `[Formalized]`
pieces) with a clean `#print axioms`, and the round closes with full consensus
(3/3 swarm + 3/3 BCD). The Coordinator then writes the **manuscript** (PDF).

Want to read before the milestone? Check any accepted routes, and then ask the
Coordinator to resume the PI to write a human readable report!

Expectations: early rounds may deliver zero accepted routes — the unit of progress
is a dossier entry, not a route. Nothing is lost; stale material is fragmented and
re-mined.
