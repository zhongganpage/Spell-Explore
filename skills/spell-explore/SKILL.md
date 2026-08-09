---
name: spell-explore
description: Run Spell-Explore — the adversarial multi-agent proof protocol. A Coordinator runs 133-minute rounds (Creator → Producer → Selector, plus the mandated Formalizer) against a locked goal: fresh summaries → idea reports → routes → accepted routes and Lean-verified [Formalized] ideas, with a manuscript at a milestone. Use when starting, running, or resuming a Spell-Explore mathematical project.
type: prompt
whenToUse: When the user wants to initialize or continue a Spell-Explore project — proving a mathematical goal, attacking a rough idea, or resuming existing rounds
---

# Spell-Explore — core

Adversarial multi-agent proof protocol. rough idea in → attacked, reviewed, and Lean-verified mathematics out. the output is a manuscript at a milestone; nothing is a certificate.

## Roles (all in the background; the Coordinator, the subcoordinators, the PIs, and the lean code runner never close)

- **Coordinator** — asks the user for the rough idea at round 1 and locks it as the goal file; runs each round, enforces the 133-minute timeline, regulates the subcoordinators, measures the system (never the votes), produces a two-consecutive-0/9 steering report (split the goal / nominate pairings / pause), writes the manuscript (PDF) at a milestone, maintains question-routes/. at the start of each round it performs the bounded Formalizer check before the round clock starts: it reads the formalization status line in the Knowledge State index and the live background state, verifies that the Formalizer and the lean code runner are present and working — re-spawning them if a resumed session lost them — and resolves any stall or conflict it finds; the check is a bounded read that, like the round-1 setup, is not counted in the 133-minute budget. the Coordinator also keeps the user informed of substantive formalization news as it happens and at each round close: a new green lemma, a new [Formalized] premise, a change in the goal node's distance to the acceptable set, or a significant fragment deposit — routine writes are recorded only in the dossier.
- **Creator** — phase 1: n idea-workers (0 ≤ n ≤ 8, chosen by the Creator per phase; the phases are independent) think around the locked goal (≤10 min) → rotate the n ideas (i → i+1) → summaries (≤10 min) → fresh summaries in the idea pool; phase 2: n idea-workers mine stale material + the reliable idea set + the fragment region (≤15 min) → rotate → summaries (≤10 min) → fresh summaries (n = 0 produces nothing). from round 2, phase-1 workers must find ideas that do not exist in the pool, and not even similar ones.
- **Producer** — pairs a fresh summary with its complement (another summary, or an obstruction + closest technique from the fragment region), scores pool ideas by goal-frontier ([Formalized]/[Hired] premises on the goal path; hires-new-assumptions; provenance), the report worker writes the idea report (25 min) with the paired summary + complement as core, the hygiene linter then the examine gate it; a successful report becomes a route with a title, and its writer becomes the PI.
- **Selector** — two panels at a time; each route gets a panel (workerA evidence list by 73, B/C/D review 58–88, exchange 88–98 → 3 review summaries), a canary gate, the PI rebuttal + promoter note (98–113), then the swarm of ~9 + resumed BCD vote (113–133, 20 min). verdicts accept / accept-core (the salvageable core is banked as a reduced route with its own title) / reject, each rejecting vote naming the load-bearing obstruction. the reviewers and swarm judge the route itself; the promoter's note serves as a high-level check. acceptance = ≥2/3 swarm AND ≥2/3 BCD; milestone = 9/9 + 3/3 + the accepted routes achieving the locked goal.
- **Formalizer** (mandated) — decompose workers (per pair, 10-min limit, 10-min unpaired timeout) → decomposed fragments → mechanical swarm of ~8 (a job running >10 min is packaged and relayed to a swarm worker that has done its job; 1-min wait, else the fragment region) → single qmd file → lean code runner (plans the verification jobs in advance, dispatches them to its own swarm of the required number — unrelated to the working swarm — and integrates: locks green pieces, builds the dependency tree: assumption nodes + green edges + [Hired] + the goal node) → reliable idea set (green lean only, [Formalized], un-overturnable) + fragment region. runs across rounds, unbound by the round budget. it keeps the formalization status in the Knowledge State index current: after each completed batch — a decompose run, a swarm update of the qmd file, or a lean code runner wake that greens a piece or deposits fragments — it writes one dated line recording the green count, the [Formalized] count, the fragment deposits and the dependency graph delta, so the index always reflects the current formalization state and the Coordinator's round-start check reads a live number.

## The 133-minute round (one route)

0–20 Creator phase 1 · 20–45 Producer report (25) · 45–58 linter (layer 1 ≈2, layer 2 produces the format ≈6) + examine (cap 5) · 58–98 Selector panel · 98–113 PI rebuts + promoter (parallel) · 113–133 swarm + resumed BCD. phases that overrun are cut; the round closes atomically at 133 min. the round-1 setup (asking for the rough idea → writing the goal file) happens before the clock starts.

## Invariants

- every subagent is spawned in the background, never the blocking foreground
- the idea pool is append-only for workers; nothing in it may be deleted by a worker
- everything is versioned (the goal file excepted — it is locked and never changed by the project)
- artifacts are files: every worker writes to its assigned output path and confirms; a worker that cannot write has its text persisted verbatim, marked recovered from agent output
- the votes are fixed — the Coordinator never affects the acceptance thresholds
- accepted routes are revisable, not the end of a route; only a demonstrated counterexample kills an idea
- the Formalizer keeps the Knowledge State index's formalization status current, and the Coordinator reads it at the round-start check

## Running it

1. **Start:** read the locked spec `references/planning-idea.md` and the operating rules `references/protocol/rules/*.md`; load the agent profiles from `references/protocol/.kimi-code/agents/`.
2. **Round 1:** the Coordinator asks the user for the rough idea, writes the locked goal file, and the user picks the round count.
3. **Each round:** check the Formalizer's status at round start (bounded read before the clock; re-spawn the Formalizer / lean code runner if a resumed session lost them); follow the timeline; use the templates in `references/protocol/templates/` for every artifact; enforce each subcoordinator's rules; close atomically with the decision list (abstracts of accepted routes, recycle/park for each unaccepted route, user nominations for next-round pairings).
4. **Continue:** rounds ≥ 2 resume carried-over reviews first, run the Creator alongside, and stop at a milestone (the Coordinator writes the manuscript PDF) or when the user decides.

Full detail: `references/planning-idea.md` · build plan: `references/construction-plan.md` · rules: `references/protocol/rules/` · templates: `references/protocol/templates/` · agent profiles: `references/protocol/.kimi-code/agents/` · runtime config: `references/protocol/config.toml`.
