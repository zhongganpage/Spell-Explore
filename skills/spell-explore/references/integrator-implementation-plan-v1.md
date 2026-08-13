# Integrator — implementation plan & impact analysis v1 (2026-08-13, for the repair session)

complements `references/integrator-spec-v1.md` (the design). this is the rollout plan: what changes, in what order, and every component that touches a moved/renamed artifact. implement only after the spec is approved; every edit stays versioned.

## 1. change summary (one line per decision)

- new **Integrator** subcoordinator: round-start spawn, stable ID, two ephemeral workers, sandbox `formalizer/Integrator/`.
- snapshots `single.qmd` / `single.lean` → `single-int.qmd` / `single-int.lean`; working files `ITG.lean`, `ITG-1.lean`, `ITG-2.lean`, its own `symbol-list.md`.
- binding merge rules: `single-int` immutable (in place and in `ITG`); `ITG-1`/`ITG-2` editable; green→non-green reverts (keep green, stale the edit); consistency checked before merge.
- milestone source moves from `dependency-graph.json` to the Integrator's report; miners read `ITG.lean`; graphify = visualization only.
- hire test moves to the Integrator on `ITG.lean`; `[Hired]` appears only in `ITG.lean`, never `single.lean`.
- runner drops graph build / `[Hired]`-in-`single.lean` / proves / connection-proofs / hire test; adds version marking.
- Integrator writes `hireable-registry.md` + `connection-proofs.md`; deposits green codes to the reliable idea set (second writer).

## 2. component-by-component impact

paths below are relative to `references/protocol/`; the same edits apply to the live `protocol/` tree and are synced per §2.8.

### 2.1 graph source change (highest impact)
- `.kimi-code/agents/graph-worker.md` — reads `dependency-graph.json` → reads `ITG.lean` (nodes, green edges, `[Hired]`, goal).
- `.kimi-code/agents/creator.md` (phase-2 dispatch) — pass the report / `ITG.lean` pointers to miners and graph workers.
- `rules/coordinator.md` (milestone check), `templates/round-close.md`, `config.toml`, `goal.md` — "goal node reachable" from `dependency-graph.json` → from the report.
- `.kimi-code/agents/lean-code-runner.md` + `rules/formalizer.md` — the runner's graph reads for not-green/reverse-edge closure now point at `ITG.lean` / the report.

### 2.2 hire test and [Hired]
- `rules/formalizer.md` — `[Hired]` marking moves from `single.lean` to `ITG.lean`; hire test moves to the Integrator.
- `templates/ledger-row.md`, `dossier/index.md`, `dossier/idea-pool/README.md` — `[Hired]` provenance references.
- `templates/symbol-list.md` + the filled `formalizer/symbol-list.md` — the dictionary role; no `[Hired]` there.

### 2.3 registries
- `formalizer/hireable-registry.md` — ownership → Integrator (currently the Formalizer files justifications and the runner syncs renames).
- `formalizer/connection-proofs.md` — ownership → Integrator.
- `references/patch-spec-connection-proofs-v1.md` — amended: proves/connection-proofs maintenance moves runner → Integrator.

### 2.4 reliable idea set (second writer)
- `rules/core-loop.md` §8 — `dossier/idea-pool/reliable-idea-set/` gains the Integrator as a second writer (direct deposit).

### 2.5 single.lean as dictionary + version marking
- `rules/formalizer.md` + `.kimi-code/agents/lean-code-runner.md` — the runner stops `[Hired]`-marking in `single.lean`; adds version marking on `single.qmd` / `single.lean`.

### 2.6 lifecycle + budget
- `rules/coordinator.md` (registration/preflight) + `rules/worker-lifespans.md` — stable-ID-across-rounds exception + background budget + resume pack.
- `rules/timekeeping.md` — background window for the 60-minute worker pair.

### 2.7 new agent artifacts
- three profiles: `.kimi-code/agents/integrator.md`, `.kimi-code/agents/integrator-worker-1.md`, `.kimi-code/agents/integrator-worker-2.md`; `rules/integrator.md`; templates for the report and the merge handoff. registered in the Coordinator and preflight.

### 2.8 docs and sync
- `README.md`, `USER-GUIDE.md`, `SKILL.md`, `construction-plan.md`, `spec-amendments.md` (add the "Integrator owns the graph" row), `CHANGELOG.md`.
- `formalizer/lean/README.md` — update the graph/single.lean description to the report + `ITG.lean`.
- `dossier/version-inventory.md` — add version rows for `ITG.lean`, `ITG-1.lean` / `ITG-2.lean`, and the report.
- both protocol trees (`protocol/` and `skills/spell-explore/references/protocol/`), `scripts/sync-skill.sh`, `scripts/init-project*.sh`.

## 3. rollout order

1. approve this plan + the spec.
2. add the three profiles + `rules/integrator.md` + templates; register in the Coordinator and preflight.
3. revise the runner (version marking; drop graph/`[Hired]`/proves/connection-proofs/hire).
4. wire milestone → report; miners/graph-workers → `ITG.lean`; retire `dependency-graph.json` as the workflow source.
5. move `hireable-registry.md` + `connection-proofs.md` to the Integrator; grant the reliable-idea-set second-writer exception.
6. define the merge-queue handoff artifact + `runtime/requests/` request; set the background budget + stable-ID lifecycle.
7. update `symbol-list.md`, both protocol trees, docs, and scripts.
8. verify: hire test on `ITG.lean`, report↔`ITG.lean` consistency, milestone + miners read the correct sources.

## 4. verification

run `scripts/sync-skill.sh` (must exit 0), then `scripts/check-skill.sh`. the project mirror is synced afterwards by the Coordinator-level sync.
