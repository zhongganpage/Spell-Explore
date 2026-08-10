# Spell-Explore — Construction Plan

Turn `planning-ideas-no-push.md` (the single source of truth) into a buildable protocol. The design is
consistency-checked; this plan says what to build, in what order, and how to validate it.

---

## 1. Project file layout

```
<project>/
├── goal.md                       # locked goal file — Coordinator writes it at round-1 start (outside the 138-min clock)
├── dossier/                      # one living file until ~30 KB, then splits (see §5)
│   ├── index.md                  # Knowledge State: conjectures registry · obstructions register · champion-route pointer · formalization status (green · [Formalized] · graph summary)
│   ├── idea-pool/                # fresh summaries · reliable idea set ([Formalized] green lean) · fragment region (append-only for workers)
│   ├── attempts-log.md           # tried / broke / implies / next
│   ├── verification-ledger.md    # date | claim | status | reviewer | verdict & reasons | repair targets
│   ├── version-inventory.md
│   └── examples.md · reformulations.md · literature-map.md   # split-out reference sections
├── question-routes/              # Coordinator-maintained
│   ├── question-routes.md        # the main question + abstract of every accepted route (living map)
│   ├── reliable-idea-set.md      # copy of the full reliable idea set (runtime: the Coordinator creates it once [Formalized] ideas land)
│   └── <accepted route title>/   # summaries · idea reports · route (versions) · review reports
├── reports/ · routes/ · stale/   # versioned artifacts (project folder, not the dossier)
├── formalizer/
│   ├── single.qmd                # the one qmd file (green pieces get LOCKED in place, never removed)
│   ├── fragments/                # per-fragment .qmd + .lean pieces — written by the working swarm, merged by the lean code runner
│   ├── qmd-index.md              # id list of the lemmas, definitions and theorems in single.qmd — maintained by the lean code runner
│   ├── dependency-graph.json     # lean dependency tree: assumption nodes · green edges · [Hired] flags · goal node
│   └── lean/                     # lean code
└── .kimi-code/agents/            # optional project-scoped agent profiles (see §3)
```

## 2. The 138-minute round (one route, no carried work)

| window | phase | binding notes |
|---|---|---|
| 0–20 | Creator phase 1 | n idea-workers (0–8) think (≤10) + summaries (≤10); all n fresh summaries ready ~20 |
| 20–45 | Producer report worker (25) | paired summary + complement → idea report |
| 45–63 | linter (layer 1 ≈2, layer 2 ≈6) + examine (cap 8) | linter first, then examine; fail → stale |
| 63–103 | Selector panel (40) | A lists by 78; B/C/D review 63–93; exchange 93–103; two panels at a time |
| 103–118 | PI rebuts + change list; promoter's nearest true version note in parallel (a high-level check) | the PI's rebuttal and the note go to the swarm |
| 118–138 | swarm (20, 3 odd) + resumed BCD (20) | accept / accept-core / reject: accept and accept-core each need ≥2/3 swarm (2 of 3) AND ≥2/3 BCD; milestone = 3/3 + 3/3 + goal achieved |

Round-2+ variant: carried reviews own the critical path; Creator phase 1 + Producer run in the
background alongside; a new route's review starts only if a full 75-min review fits.

## 3. Role → agent-profile mapping

Custom agent files (`~/.kimi-code/agents/` or project `.kimi-code/agents/`), each with `tools`,
`subagents` allowlists, and `model_preference`:

| role | tools | model | resumable |
|---|---|---|---|
| coordinator | full | primary | ✓ |
| creator / producer / selector / formalizer | full within territory | primary | ✓ (subcoordinators) |
| lean code runner | Read/Grep/Bash/Write/Edit/Agent/AgentSwarm | primary | ✓ |
| lean runner swarm worker | Read/Grep/Bash | secondary | ✗ (30-min life) |
| PI | full (route editing) | primary | ✓ |
| report worker (Producer phase 1; triple core: 3 fresh summaries) | full (writes report) | secondary | ✗ (becomes PI on success) |
| route worker (Producer phase 2 — route writer of accepted revisions) | full (route writing) | secondary | ✗ (becomes the new PI on an accepted revision) |
| examine worker | Read/Grep | primary (quality-critical) | ✗ |
| decompose worker | Read/Grep | secondary | ✗ |
| swarm worker (decision swarm 3, odd — 2/3 = 2 of 3 — and the working swarm ~8) | Read/Grep/Glob/Write/Edit | secondary | ✗ (30-min life) |
| idea worker | Read/Grep | secondary | ✗ |
| graph worker (Creator phase 2 — bridging-lemma summaries when dependency-graph.json has nodes) | Read/Grep/Glob/Write | secondary | ✗ |
| panel B/C/D (BCD: votes at the swarm stage, ≥2/3 of 3 = 2; worker rules: proof-step ledger, assumption audit, counterexample duty, evidence tie-in, boundary sweep, verdict format) | Read/Grep (no write) | primary | ✓ (paused across the PI window, then close after the vote) |
| workerA | Read/Grep | secondary | ✗ |
| workerD | Read/Grep | secondary — external: a different provider than the panel's primary; fallback = internal reviewer, reduced diversity recorded | ✗ |
| promoter | Read/Grep | primary | ✗ |

per-phase timeouts are not config: the runtime exposes only a global `[subagent] timeout_ms`,
whose 2 h default is shorter than the 138-minute round. the Coordinator enforces the phase
windows operationally (TaskStop), per rules/timekeeping.md.

Rules encoded in profiles: **every agent file body states "your final message is the complete,
self-contained result"** (custom agents don't inherit the built-in handoff framing). `subagents`
allowlists enforce: workers may spawn workers, never judges; a reviewer can spawn nothing.
Every spawn uses `run_in_background=true`. subcoordinators and quality-critical workers (the
examine worker, the panel's B/C, the PI) run on the primary model; workerD is external (see
the table). the Coordinator never assigns a subcoordinator role to a weaker model.

## 4. Templates

**Fresh summary** — id · idea · connections · conflicts · possible directions · (round ≥ 2: novelty-checked vs pool).

**Idea report** (must satisfy linter layer 2's **format** (lock this name)) — for every claim/lemma/theorem/proposition:
uniform structure `statement → assumptions (explicit) → implications`; groups of claims; precise
citations; a clear promise about achieving the goal (with confidence + evidence); complete
(no unfinished sentences/equations/diagrams).

**Route** — title (locked term) · versioned · the renamed report + PI.

**Review summaries (B/C/D)** — per the panel contract (A's list → B inconsistencies, C
counterexamples, D overall); three summaries.

**Stale entry** — failure reason · revival trigger ("re-examine when <event>") · fragments
(sub-results that hold · obstruction · closest technique) → fragment region.

**Verification ledger row** — `date | claim | status | reviewer | verdict & reasons | repair targets`.

**Round-close record (single atomic write)** — fresh routes · verdicts · stale list with
fragments · phase-time table · decision list (abstracts of accepted routes; recycle/park each
unaccepted; user nominations for next-round pairings).

**question-routes.md** — main question + per accepted route: abstract.

## 5. Build order

1. **Scaffolding** — `scripts/init-project.sh` (copies the agent profiles, the dossier
   skeleton, and offers to merge the protocol config into `~/.kimi-code/config.toml`) and
   `scripts/sync-skill.sh` (keeps the packaged skill copy at `skills/spell-explore/` in sync
   with `protocol/`); goal file flow (Coordinator asks for rough idea → writes locked goal),
   dossier + Knowledge State index + split rule, question-routes/, `.kimi-code` config
   (`[background] max_running_tasks = 50`, `[subagent] timeout_ms = 0` — the per-phase
   budgets live in rules/timekeeping.md).
2. **Core loop** — Creator (phases 1+2: phase 1 n idea-workers 0–8, the n ideas rotated; phase 2
   from round ≥ 2 when the pool has content — 2 graph workers, active when dependency-graph.json
   has nodes, plus 2 regular miners) → Producer (two phases: phase 1 two report workers, each
   pairing a triple of 3 summaries by goal-frontier — [Formalized]/[Hired] premises on the goal
   path, hires-new-assumptions, provenance; phase 2 the route writer, gated on Creator phase 2 on
   AND accepted routes existing; then report) → linter (two layers) → examine (adds the
structural-completeness check: every claim has a proof attempt, no GAP) → route.
3. **Selector** — panels (two at a time), canary gate, promoter, PI rebuttal, swarm (3, odd) +
   resumed BCD (judge the route itself, the promoter's nearest true version note as a high-level
   check; 2/3 of 3 = 2 accept; verdicts accept / accept-core — the salvageable core is banked as
   a reduced route — / reject, each rejecting vote naming the load-bearing obstruction; 3/3+3/3
   milestone); sends accepted/accepted-core routes (full or core form) + the promoter's note to
   the Formalizer after the verdict; rejected pairs go to the fragment region.
4. **Formalizer** — verdict-aware input (examine-failed lint-passed reports immediately;
   accepted/accepted-core routes' full-or-core form + the promoter's note post-verdict from the
   Selector; rejected pairs → fragment region; the note as scoping metadata, never decomposed) →
   decompose workers (10-min pairs, 10-min unpaired timeout) → mechanical
   working swarm (~8, 30-min life, 5-min tail; a job running >10 min is packaged and relayed to
   a free worker, 1-min wait, else fragment region) → single qmd → lean code runner (plans the
   verification jobs in advance, dispatches them to its own swarm of the required number —
   unrelated to the working swarm — and integrates the results: locks green pieces, dependency
   tree with goal node + [Hired]); keeps the index's formalization status current — one dated
   line per completed batch (green count, [Formalized] count, fragment deposits, graph delta).
5. **Coordinator regulation** — status monitoring (incl. the bounded round-start Formalizer
   check before the clock: read the index status line + live background state, re-spawn any of
   the four subcoordinators, the PIs, or the lean code runner that a resumed session lost),
   timeline enforcement (announce,
   timestamps, cuts, atomic close), measurements (idea-yield, premature kills — never into
   votes), the two-consecutive-0/3 steering report (split the goal / nominate pairings /
   pause), user-facing surfacing of substantive formalization news, milestone → manuscript
   (PDF), question-routes maintenance (incl. the current-defender-PI pointer and the PI
   handover: mark the replaced PI superseded, TaskStop it, record the new defender).
6. **Protocols** — wire the persistence discipline (phase-2 + report workers) and verification
   discipline (independence, ledger, [Formalized] premise channel) into the worker prompts.
7. **Worker lifespans** — encode the hold-open invariants (report worker → PI, the Creator's
   rotation hold, the BCD pause across the PI window, the working-swarm 30-min resumable
   window, the lean code runner across rounds) in `rules/worker-lifespans.md` and wire a
   hold-open clause into each subcoordinator's profile; subcoordinators are single-run
   orchestrators — never return before every spawned worker's artifact exists and is verified.

## 6. Validation

- **Dry-run round 1** within 138 min: Creator → Producer → linter → examine → panel → PI →
  swarm; check the phase-time table sums.
- **Canary gate**: seeded false claim + planted step-error must be caught (≥80% / 100% with
  step cited) or no route is delivered.
- **Milestone path**: an accepted route reaching 3/3 + 3/3 with the goal node reachable from
  `[Formalized]`/`[Hired]` assumptions → Coordinator writes the manuscript PDF.
- **Round-2+ drill**: a carried route review + concurrent Creator phase 1 + a queued report.
- **Formalizer smoke test**: two lint-passed reports → decompose → qmd → one green lemma →
  locked in the qmd → lean code in the reliable idea set → dependency edge added.
- **Relay drill**: a >10-min job is packaged, handed to a free worker (the relay restarts the
  receiving worker's 10-min clock), and only fragments if no worker is free within 1 min.
- **Lean runner dispatch drill**: a qmd update produces a forward plan; the lean code runner
  spawns exactly the required number of swarm agents (unrelated to the working swarm),
  integrates the green results into the reliable idea set and the dependency graph.
- **Rotation drill**: with n idea-workers (0 ≤ n ≤ 8) the n ideas rotate (i → i+1); n = 0
  produces nothing, and the two phases may use different n.
- **Steering trigger**: two consecutive 0/3+0/3 rounds produce the Coordinator's steering
  report before a third such round starts.
- **Triple-pairing drill**: two Producer phase-1 report workers each write an idea report from
  a triple of 3 fresh summaries; check each report's core is the triple.
- **Graph-worker drill**: with dependency-graph.json holding nodes, the Creator phase-2 graph
  workers write bridging-lemma summaries from the graph; without nodes they fall back to
  regular mining.
- **Route-revision + PI-handover drill**: an accepted revision → the new PI (the Producer
  phase-2 route writer) writes the new version and marks the old superseded → the Coordinator
  TaskStops the old PI → the current-defender pointer is recorded in question-routes.
- **Swarm-3 drill**: the decision swarm is 3 (odd); acceptance needs 2/3 = 2 of 3; milestone
  3/3 + 3/3; steering 0/3 + 0/3.
- **Steering 0/3 drill**: two consecutive rounds of total rejection (0/3 + 0/3) produce the
  Coordinator's steering report before a third such round starts.
- **Partial-acceptance drill**: a near-miss route with a genuine core is accepted-core
  (≥2/3+2/3), and the core is banked as a reduced route with its own title in question-routes.
- **Obstruction-naming check**: a rejected route's stale entry and the obstructions register
  carry the load-bearing obstruction named by the rejecting votes.
- **Lifespan drill**: a subcoordinator never returns before every worker it spawned has
  produced its artifact at the assigned path; a resumed session restores the four
  subcoordinators, the PIs, and the lean code runner.
- **No-early-return check**: a subcoordinator's final message cites verified artifact paths;
  a narrated-but-unverified spawn is treated as a failure.
- **Formalizer visibility check**: at round start the Coordinator reads a current formalization
  status line in the index; a green lemma lands there and is surfaced to the user without being
  pointed out.
- **Verdict-aware input drill**: an examine-failed report reaches the Formalizer immediately; an
  accepted route's full-or-core form + the promoter's note arrive post-verdict; a rejected
  route's pair goes to the fragment region, never to the Formalizer.
- **Config parse**: `protocol/config.toml` parses under the real Kimi Code schema — real keys
  only, the invented timeout tables deleted.
- **Preflight drill**: at round start, `lean --version`, `qmd-prover`, and agent-profile
  discovery all succeed.
- **Sync check**: `protocol/` == the packaged skill copy
  (`skills/spell-explore/references/protocol/`), run `scripts/sync-skill.sh`.
