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
│   ├── single.qmd                # the one qmd file (green pieces get LOCKED in place, never removed; may carry the promoter's connection annotation lines)
│   ├── fragments/                # per-fragment .qmd + .lean pieces — written by the working swarm, merged by the lean code runner
│   ├── qmd-index.md              # id list of the lemmas, definitions and theorems in single.qmd + the connections section (route bridges) — maintained by the lean code runner
│   ├── dependency-graph.json     # lean dependency tree: statement nodes (kernel | mathlib | formalized | axiom | goal) · green edges · [Hired] flags · goal node
│   └── lean/                     # lean code
├── runtime/                      # the spawn channel + resume packs (see §3)
│   ├── requests/                 # spawn requests — <territory>-<round>-<seq>.md in the locked format (§4); the Coordinator appends the status line
│   ├── briefs/                   # job briefs — locked header (label · profile · output · deadline), free-form body
│   ├── worker-registry.md        # request → task-ids → labels → output paths — the Coordinator's recovery map after a session resume
│   └── <role>-state.md           # resume packs (the four subcoordinators, the PIs, the lean code runner)
└── .kimi-code/agents/            # optional project-scoped agent profiles (see §3)
```

## 2. The 138-minute round (one route, no carried work)

| window | phase | binding notes |
|---|---|---|
| 0–20 | Creator phase 1 | n idea-workers (0–8) think (≤10) + summaries (≤10); all n fresh summaries ready ~20 |
| 20–45 | Producer report worker (25) | assigned fresh summaries + complement material → idea report |
| 45–63 | linter (layer 1 ≈3, layer 2 ≈7) + examine (cap 8) | linter first, then examine; fail → stale |
| 63–103 | Selector panel (40) | A lists by 78; B/C/D review 63–93; exchange 93–103; two panels at a time |
| 103–118 | PI rebuts + change list; promoter's nearest true version note in parallel (a high-level check) | the PI's rebuttal and the note go to the swarm |
| 118–138 | swarm (20, 3 odd) + resumed BCD (20) + the resumed promoter's connection marking (20) | accept / accept-core / reject: accept and accept-core each need ≥2/3 swarm (2 of 3) AND ≥2/3 BCD; milestone = 3/3 + 3/3 + goal achieved; the promoter marks the route's connections into the single qmd file (rules/selector.md §7.1) |

rounds ≥ 3 run 139 minutes: the Producer's phase-2 route writer spends 1 minute choosing its summary at the 20-min mark, and the windows after the choice shift +1 (21–46, 46–64, 64–104, 104–119, 119–139); one phase-1 report writer runs (4 fresh summaries per round).

Round-2+ variant: carried reviews own the critical path; Creator phase 1 + Producer run in the
background alongside; a new route's review starts only if a full 75-min review fits.

## 3. Role → agent-profile mapping

Custom agent files (`~/.kimi-code/agents/` or project `.kimi-code/agents/`), each with `tools`,
`subagents` allowlists, and `model_preference`:

| role | spawner | tools | model | resumable |
|---|---|---|---|---|
| coordinator | spawns the four subcoordinators and every non-swarm worker at a subcoordinator's request (the spawn request, §4) | full | primary | ✓ |
| creator / producer / selector / formalizer | request their workers from the Coordinator; spawn only their own swarms (the Selector: decision swarm; the Formalizer: working swarm) | Read/Grep/Glob/Write/Edit/Bash + TaskList/TaskOutput/TaskStop (no Agent/AgentSwarm except the swarm owners) | primary | ✓ (subcoordinators) |
| lean code runner | requested by the Formalizer from the Coordinator; spawns its own lean swarm | Read/Grep/Bash/Write/Edit/Agent/AgentSwarm/TaskList/TaskOutput/TaskStop | primary | ✓ |
| lean runner swarm worker | the lean code runner | Read/Grep/Bash | secondary | ✗ (30-min life) |
| PI | the Coordinator (a held-open report/route worker, birth label kept) | full (route editing) | primary | ✓ |
| report worker (Producer phase 1; assigned-summaries core) | the Coordinator | full (writes report) | secondary | ✗ (becomes PI on success) |
| route worker (Producer phase 2 — route writer of accepted revisions) | the Coordinator | full (route writing) | secondary | ✗ (becomes the new PI on an accepted revision) |
| examine worker | the Coordinator | Read/Grep | primary (quality-critical) | ✗ |
| decompose worker | the Coordinator | Read/Grep | secondary | ✗ |
| swarm worker (decision swarm 3, odd — 2/3 = 2 of 3 — and the working swarm ~4) | its owner (the Selector / the Formalizer) | Read/Grep/Glob/Write/Edit | secondary | ✗ (30-min life) |
| idea worker | the Coordinator | Read/Grep | secondary | ✗ |
| graph worker (Creator phase 2 — bridging-lemma summaries when dependency-graph.json has nodes) | the Coordinator | Read/Grep/Glob/Write | secondary | ✗ |
| panel B/C/D (BCD: votes at the swarm stage, ≥2/3 of 3 = 2; worker rules: proof-step ledger, assumption audit, counterexample duty, evidence tie-in, boundary sweep, verdict format) | the Coordinator | Read/Grep (no write) | primary | B/C: ✓ (paused across the PI window, then close after the vote); D: ✗ (exterior, invoked twice) |
| workerA | the Coordinator | Read/Grep | secondary | ✗ |
| workerD (exterior reviewer X) | the Coordinator (invokes via the configured exterior access — api / codex, modules/providers.md; captures the reply, reports the actual model; the Selector records the fallback) | Read/Grep (invocation prompt; reply captured from api response / codex stdout) | exterior — a different provider family than the panel's primary; fallback = internal reviewer, reduced diversity recorded with a confidence downgrade | ✗ (invoked twice: review 63–103, vote 118–138) |
| promoter | the Coordinator | Read/Grep | primary | ✗ |

per-phase timeouts are not config: the runtime exposes only a global `[subagent] timeout_ms`,
whose 2 h default is shorter than the 138-minute round. the Coordinator enforces the phase
windows operationally (TaskStop), per rules/timekeeping.md.

Rules encoded in profiles: **every agent file body states "your final message is the complete,
self-contained result"** (custom agents don't inherit the built-in handoff framing). the `subagents`
allowlists enforce the new spawning: the Coordinator's allowlist is the union of the four
subcoordinators and every worker profile it may be asked to spawn; a subcoordinator's allowlist
covers only its own swarm (the Selector: swarm-worker; the Formalizer: swarm-worker and
lean-code-runner); the lean code runner's allowlist covers lean-swarm-worker; every other worker is
a leaf (`subagents: []`, no Agent/AgentSwarm). a worker is spawned only at a subcoordinator's
request — a spawn request file at runtime/requests/ naming the workers by their labels, their
profiles, their output paths, and a pointer to their job brief; the Coordinator validates the
request mechanically, spawns exactly what it names, appends the status line, and never composes a
worker's job — briefs are file pointers, relayed verbatim. Every spawn and every resume (resume-by-ID) uses `run_in_background=true`.
subcoordinators and quality-critical workers (the examine worker, the panel's B/C, the PI) run on
the primary model; workerD is external (see the table). the Coordinator never assigns a
subcoordinator role to a weaker model.

The worker label — the name every spawn request carries — is a letter for the territory (c: Creator,
p: Producer, s: Selector, f: Formalizer), the birth round, the job-type number, and the order of
that job in the round: c-2-1-3 = the Creator's third idea-worker, born in round 2. job types:
c-1 idea-worker, c-2 miner, c-3 graph-worker; p-1 report-worker, p-2 route-worker, p-3 examine-worker;
s-1 worker-a, s-2 reviewer-b, s-3 reviewer-c, s-4 reviewer-d, s-5 promoter, s-6 swarm-worker;
f-1 decompose-worker, f-2 swarm-worker, f-3 lean-code-runner, f-4 lean-swarm-worker. the order
counts every instance of the type spawned in the round; a restarted worker keeps its label; the PI
keeps its birth label; the swarm workers carry the same labels, assigned by their owner at spawn.

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

**Spawn request** — the locked request format: kind (spawn | resume | stop) · requester · round ·
per-worker label/profile/output/brief (file pointers only, never inline brief text); the Coordinator
appends the status line (spawned | resumed | stopped | rejected, with the reason when rejected).
lives at runtime/requests/<territory>-<round>-<seq>.md; a request is never silently reinterpreted.

**Job brief** — a locked header (the worker's label · its profile · its output path · its deadline)
with a free-form body; lives at runtime/briefs/; the worker reads it and reports back to its
subcoordinator.

**Round-close record (single atomic write)** — fresh routes · verdicts · stale list with
fragments · phase-time table · decision list (abstracts of accepted routes; recycle/park each
unaccepted; user nominations for next-round pairings).

**question-routes.md** — main question + per accepted route: abstract.

## 5. Build order

1. **Scaffolding** — `scripts/init-project.sh` (copies the agent profiles, the dossier skeleton,
   and offers to merge the protocol config into `~/.kimi-code/config.toml`) and
   `scripts/sync-skill.sh` (keeps the packaged skill copy at `skills/spell-explore/` in sync
   with `protocol/`); goal file flow (Coordinator asks for rough idea → writes locked goal),
   dossier + Knowledge State index + split rule, question-routes/, the runtime/ scaffold
   (requests/, briefs/, the worker-registry template, the resume-pack README), `.kimi-code` config
   (`[background] max_running_tasks = 50`, `[subagent] timeout_ms = 0` — the per-phase
   budgets live in rules/timekeeping.md).
2. **Core loop** — Creator (phases 1+2: phase 1 n idea-workers 0–8, the n ideas rotated; phase 2
   from round ≥ 2 when the pool has content — 2 graph workers, active when dependency-graph.json
   has nodes, plus 2 regular miners) → Producer (two phases: phase 1 two report writers in rounds 1–2 (split as evenly as possible ±1; one
   writer from round 3 when the lane is open) — from round 3, one phase-1 writer runs (4 summaries per round) and the route writer chooses 0 or 1 summary in a 1-minute window at the 20-min mark (139-minute rounds) — [Formalized]/[Hired] premises on the goal
   path, hires-new-assumptions, provenance; phase 2 the route writer, gated on Creator phase 2 on
   AND accepted routes existing; then report) → linter (two layers) → examine (adds the
   structural-completeness check: every claim has a proof attempt, no GAP) → route. every worker
   the Creator and the Producer need is requested from the Coordinator (spawn request); the
   rotation resumes the n idea-workers through the Coordinator (resume-by-ID).
3. **Selector** — panels (two at a time), canary gate, promoter, PI rebuttal, swarm (3, odd) +
   resumed BCD (judge the route itself, the promoter's nearest true version note as a high-level
   check; 2/3 of 3 = 2 accept; verdicts accept / accept-core — the salvageable core is banked as
   a reduced route — / reject, each rejecting vote naming the load-bearing obstruction; 3/3+3/3
   milestone); sends accepted/accepted-core routes (full or core form) + the promoter's note to
   the Formalizer after the verdict; rejected pairs go to the fragment region. the panel workers
   and the promoter are requested from the Coordinator; the decision swarm is the Selector's own
   (spawned and regulated by it).
4. **Formalizer** — verdict-aware input (examine-failed lint-passed reports immediately;
   accepted/accepted-core routes' full-or-core form + the promoter's note post-verdict from the
   Selector; rejected pairs → fragment region; the note as scoping metadata, never decomposed) →
   decompose workers (10-min pairs, 10-min unpaired timeout, requested from the Coordinator) →
   mechanical working swarm (~4, 30-min life, 5-min tail; a job running >10 min is packaged and
   relayed to a free worker, 1-min wait, else fragment region; the Formalizer's own swarm) →
   single qmd → lean code runner (requested from the Coordinator; plans the verification jobs in
   advance, dispatches them to its own swarm of the required number — at most 3, unrelated to the
   working swarm — and integrates the results: locks green pieces, dependency tree with goal node
   + [Hired]); keeps the index's formalization status current — one dated line per completed batch
   (green count, [Formalized] count, fragment deposits, graph delta).
5. **Coordinator regulation** — the spawn broker: poll runtime/requests/, validate each request
   against the locked format, spawn the named workers, append the status line, execute the
   resume/stop operations the subcoordinators instruct, and keep the worker registry current (so a
   session resume restores each territory's live workers); status monitoring (incl. the bounded
   round-start Formalizer check before the clock: read the index status line + live background
   state, re-spawn any of the four subcoordinators, the PIs, or the lean code runner that a resumed
   session lost), timeline enforcement (announce, timestamps, cuts, atomic close), measurements
   (idea-yield, premature kills — never into votes), the two-consecutive-0/3 steering report (split
   the goal / nominate pairings / pause), user-facing surfacing of substantive formalization news,
   milestone → manuscript (PDF), question-routes maintenance (incl. the current-defender-PI pointer
   and the PI handover: mark the replaced PI superseded, TaskStop it, record the new defender).
6. **Protocols** — wire the persistence discipline (phase-2 + report workers) and verification
   discipline (independence, ledger, [Formalized] premise channel) into the worker prompts.
7. **Worker lifespans** — encode the hold-open invariants (report worker → PI, the Creator's
   rotation hold, the BCD pause across the PI window, the working-swarm 30-min resumable
   window, the lean code runner across rounds) in `rules/worker-lifespans.md` as **the Coordinator
   holds the tasks, the subcoordinators direct the holds**, and wire a direction clause into each
   subcoordinator's profile; subcoordinators are single-run orchestrators — never return before
   every worker they direct has produced its artifact at the assigned path and they have verified
   the write.

## 6. Validation

- **Dry-run round 1** within 138 min: Creator → Producer → linter → examine → panel → PI →
  swarm; check the phase-time table sums.
- **Canary gate**: seeded false claim + planted step-error must be caught (≥80% / 100% with
  step cited) or no route is delivered.
- **Milestone path**: an accepted route reaching 3/3 + 3/3 with the goal node reachable from
  the established base (kernel axioms + Mathlib theorems + [Formalized] pieces) and
  `#print axioms goalTheorem` containing no non-kernel axiom, with the hired set empty and the
  reachability proven in Lean → Coordinator writes the manuscript PDF.
- **Round-2+ drill**: a carried route review + concurrent Creator phase 1 + a queued report.
- **Formalizer smoke test**: two lint-passed reports → decompose → qmd → one green lemma →
  locked in the qmd → lean code in the reliable idea set → dependency edge added.
- **Relay drill**: a >10-min job is packaged, handed to a free worker (the relay restarts the
  receiving worker's 10-min clock), and only fragments if no worker is free within 1 min.
- **Lean runner dispatch drill**: a round-start resumption produces a forward plan; the lean code runner
  spawns exactly the required number of swarm agents (unrelated to the working swarm),
  integrates the green results into the reliable idea set and the dependency graph.
- **Spawn-broker drill**: a subcoordinator writes a spawn request (labels, profiles, output
  paths, brief pointers); the Coordinator validates it, spawns the workers named by their labels,
  and appends the status line; a malformed request — wrong kind, mismatched territory or round,
  a label outside the job types, a missing brief — is rejected with a reason and never
  reinterpreted; the subcoordinator directs the workers and verifies their artifacts.
- **Rotation drill**: with n idea-workers (0 ≤ n ≤ 8) the Coordinator performs the rotation
  mechanically once all n idea files are in — resume-by-ID, context preserved, the ideas rotated
  i → i+1; n = 0 produces nothing, and the two phases may use different n.
- **Restart drill**: a cut worker is re-spawned keeping its label; a genuinely new instance takes
  the next order number; the worker registry and the resume packs stay consistent.
- **Resume-collision drill**: a subcoordinator returns with its owned swarm in flight
  (lifecycle children-in-flight); the Coordinator attempts a resume and the runtime
  rejects ('already running'); the Coordinator must demonstrate the recovery — treat
  the rejection as the signal, read the role's output and its artifacts, verify by
  file, wait for self-completion — and never TaskStop the role.
- **Steering trigger**: two consecutive 0/3+0/3 rounds produce the Coordinator's steering
  report before a third such round starts.
- **Split drill**: two Producer phase-1 report writers each write an idea report from
  their assigned split of the round's summaries; check each report's core is its assigned set.
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
- **Lifespan drill**: a subcoordinator never returns before every worker it directs has produced
  its artifact at the assigned path; a resumed session restores the four subcoordinators, the
  PIs, and the lean code runner — and each territory's live workers from the worker registry.
- **No-early-return check**: a subcoordinator's final message cites verified artifact paths;
  a narrated-but-unverified worker is treated as a failure.
- **Formalizer visibility check**: at round start the Coordinator reads a current formalization
  status line in the index; a green lemma lands there and is surfaced to the user without being
  pointed out.
- **Verdict-aware input drill**: an examine-failed report reaches the Formalizer immediately; an
  accepted route's full-or-core form + the promoter's note arrive post-verdict; a rejected
  route's pair goes to the fragment region, never to the Formalizer.
- **Config parse**: `protocol/config.toml` parses under the real Kimi Code schema — real keys
  only, the invented timeout tables deleted.
- **Preflight drill**: at round start, `lean --version`, `qmd-prover`, and agent-profile
  discovery all succeed — discovery now resolves every worker profile the Coordinator may spawn,
  not just the four subcoordinators; the secondary-model flag
  (`KIMI_CODE_EXPERIMENTAL_SECONDARY_MODEL=1`) and the `[subagent] timeout_ms = 0`
  config are verified, and the restart caveat is surfaced when either is not in effect;
  the exterior reviewer X's access is re-checked at each round start — the provider env
  var present for api, or the Codex CLI installed for codex, and the provider family
  still different from the primary's (modules/providers.md); the lean-runner gate is
  applied at each round start when pending fragments exist — run now / postpone in
  manual mode, automatic run in auto mode (the round-1 runner-mode choice).
- **Sync check**: `protocol/` == the packaged skill copy
  (`skills/spell-explore/references/protocol/`), run `scripts/sync-skill.sh`.
