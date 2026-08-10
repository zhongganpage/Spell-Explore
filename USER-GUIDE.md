# Spell-Explore — user's guide (from agents to hands-free)

Spell-Explore runs a project of background agents against a locked goal in
138-minute rounds. This guide gets you from a fresh machine to a round running
hands-free.

## The cast — names and jobs

| role | job |
|---|---|
| **Coordinator** | top agent — runs each round, enforces the timeline, regulates the four subcoordinators, measures the system, writes the manuscript at a milestone |
| **Creator** | idea generation — phase-1 idea-workers think around the goal and write fresh summaries; phase-2 miners + graph workers mine stale material and bridging lemmas |
| **Producer** | pairing and reports — report workers write idea reports from summary triples; the route writer revises accepted routes; the hygiene linter + examine worker gate them |
| **Selector** | adversarial review — workerA evidence list, B/C/D reviews, the promoter's nearest-true-version note, the PI rebuttal, then the decision swarm + BCD vote: accept / accept-core / reject |
| **Formalizer** | Lean formalization — decompose workers split reports into fragments; the working swarm writes .qmd/.lean pieces; the lean code runner merges, verifies, and locks green pieces |
| **PI** | route owner — defends and modifies its route, rebuts the panel, writes the change list |
| **workerA / B / C / D** | evidence list / inconsistencies / counterexamples / overall judgement (D = the exterior reviewer X) |
| **swarm worker** | two lives — decision votes (3) or mechanical fragment transformation (working swarm ~4) |
| **lean code runner + swarm** | plans and dispatches lean verification, merges the single qmd, updates the dependency graph |
| **clock watcher** | not an agent — a background `sleep 120` that wakes the Coordinator every 2 minutes |

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
2. the number of rounds;
3. whether to add the exterior reviewer X for workerD (`X_PROVIDER` / `X_MODEL` /
   `X_ACCESS`, or none → internal reviewer, reduced diversity recorded).

After that the round clock starts and the Coordinator runs the pipeline. You do
not drive it — you supervise it.

## 3. Hands-free operation

- At round start the Coordinator spawns the **clock watcher** — a background
  `sleep 120` that wakes it every 2 minutes. Each wake: poll the workers, cut
  overruns at window ends, check for stalls, show you a **status table**, mirror
  everything to `runtime/coordinator-state.md`, and re-spawn the watcher. A wake
  that finds the Coordinator busy is held and caught up on — it never interrupts.
- Subagents run in the background; nothing closes early. The Coordinator's every
  turn ends with a lifecycle line, so the round always resumes from a file.
- What you actually look at:
  - the 2-minute status table (round clock, phases, live workers, pending
    artifacts, next action);
  - at round close, the **decision list** — abstracts of accepted routes; for each
    unaccepted route, **recycle or park**; your nominations for next-round pairings;
  - formalization news as it happens (a new green lemma, a new `[Formalized]`
    premise, the goal node's distance shrinking).

## 4. Interruptions and stalls

- Session interrupted? Just prompt "continue" — the round-start check reads
  `runtime/coordinator-state.md` and resumes the exact mid-flight phase,
  re-spawning any lost worker.
- Status tables stop appearing for more than a couple of minutes? The chain broke
  — prompt once; the file-based resume takes over.
- Two consecutive rounds with every route rejected → the Coordinator writes a
  **steering report** (split the goal / nominate pairings / pause) and will not
  start a third such round on its own. The project never runs autonomously across
  days: rounds end at decision points that are yours.

## 5. Milestone

The project reaches a milestone when the goal node of `dependency-graph.json` is
reachable from the established base (kernel axioms + Mathlib + `[Formalized]`
pieces) with a clean `#print axioms`, and the round closes with full consensus
(3/3 swarm + 3/3 BCD). The Coordinator then writes the **manuscript** (PDF).

## 6. PDF exposition of an accepted route

As soon as a route is accepted, you can ask for a human-readable PDF of it — no
milestone needed:

> ask the Coordinator to have the route's PI write a human-readable PDF report of
> the accepted route.

The PI is the route's owner (it holds the route and its authoring context), so the
Coordinator directs the PI to produce a PDF exposition: the statement, the
assumptions, the proof outline, and what the route contributes toward the goal.
The milestone manuscript (section 5) remains the full project report; this is the
per-route exposition, on demand.

Expectations: early rounds may deliver zero accepted routes — the unit of progress
is a dossier entry, not a route. Nothing is lost; stale material is fragmented and
re-mined.
