# Integrator rule

this rule specifies the fifth subcoordinator, the Integrator: what it receives, how it snapshots the single qmd and lean into its sandbox, how its two ephemeral workers write and verify the connecting proof code, how it merges the green proofs into its own `ITG.lean` under the binding merge rules, and what it outputs — the chain/atlas report, the hire test on `ITG.lean`, the two registries, and the merge-queue handoff. it is authoritative on the Integrator's territory and consistent with `references/integrator-spec-v1.md` (the design; where they differ, the spec governs) and construction-plan §1 (whose tree gains `formalizer/Integrator/`). the Integrator is subordinated to the Coordinator, which regulates all five subcoordinators and enforces the 138-minute round timeline — the Integrator is not bound by it.

## territory and lifecycle

the Integrator is a subcoordinator. it does not do the work itself: it regulates its two workers within integration — monitoring their status, enforcing the time limits and the artifact rules, and solving issues inside its territory, while the Coordinator regulates it. every worker it directs is spawned by the Coordinator in the explicit background mode, never the blocking foreground. the Integrator is resumable: it runs its procedure to completion in one run — waiting for every worker's artifact before returning — and is resumed by the Coordinator for the next round; it never returns early, and a narrated step is not a done step.

the Integrator runs in the background across rounds: it is not bound by the round budget — its two workers need 45 + 15 = 60 minutes, which cannot fit the 0–20 window, so they run off the critical path. the Coordinator spawns it at the start of each round. unlike the other subcoordinators, it keeps a **stable ID across rounds** (an exception to the round-boundary fresh-spawn rule of rules/coordinator.md §3) with its own resume pack (`runtime/integrator-state.md`) and a lifecycle contract: it is resumed by ID across rounds, and after a session resume it is restored from its resume pack like the other long-lived roles. its workers are ephemeral — no stable IDs, no resume packs — and close when their job is done. the Integrator winds down only when the project ends: it finishes its existing work — the current round's integration — before closing.

## sandbox and files

the Integrator changes nothing outside `formalizer/Integrator/` except the sanctioned out-of-subfolder writes below — the reliable idea set deposit, `formalizer/hireable-registry.md`, and `formalizer/connection-proofs.md`. files:

- `formalizer/Integrator/single-int.qmd` — snapshot of `formalizer/single.qmd` (renamed copy; the Integrator never reads the original after the copy and sticks to this version).
- `formalizer/Integrator/single-int.lean` — snapshot of `formalizer/lean/single.lean`.
- `formalizer/Integrator/ITG.lean` — its own integration working lean file.
- `formalizer/Integrator/ITG-1.lean` — worker 1's green proofs; `formalizer/Integrator/ITG-2.lean` — worker 2's green proofs.
- `formalizer/Integrator/symbol-list.md` — its own precise symbol dictionary (seeded from `formalizer/symbol-list.md`; workers stick to ITG symbols).
- `formalizer/Integrator/integration-report.md` — the chain/atlas report, kept consistent with `ITG.lean`; the milestone source.

## version gating

the runner marks versions of `formalizer/single.qmd` and `formalizer/lean/single.lean` on every update. version unchanged → the Integrator does nothing; updated → it works only on the new items (delta). after the workers finish, the Integrator marks versions of `ITG-1.lean`, `ITG-2.lean`, and `ITG.lean`.

## per-round procedure

1. inspect `single-int.qmd` + `single-int.lean`; identify all marks, especially connection marks and their statements.
2. unify symbols from `single-int.lean` into `ITG.lean`; update `symbol-list.md`; workers stick to ITG symbols.
3. plan connection jobs; request the two worker spawns from the Coordinator.
4. run the workers (strict windows; the Integrator is not responsible for unreachable work):
   - worker 1 (45 min): T/F-completeness check (only T or only F → do nothing); read the marked qmd codes + the promoter's connection-report + related artifacts (accepted routes, review reports) for the prose proofs; write the lean proof code connecting the T/F statements; does not run lean. bonus if time remains: best-effort inspect adapting its proofs to non-connection-marked statements (not required to finish).
   - worker 2 (15 min): run the lean code, identify green, fix non-green by run→fix→run (no fixing at the start); keep green results.
   - both: never change statements/axioms/theorems — only create/modify proof code.
5. integration step: merge `single-int.lean` + `ITG-1` + `ITG-2` into `ITG.lean` under the merge rules below; never change `single-int` content.
6. maintain `integration-report.md` consistent with `ITG.lean`. graphify on `ITG.lean`, if produced, is visualization-only and never joins the workflow.

## merge rules (binding)

- never change `single-int` content — neither in `single-int.qmd` / `single-int.lean` themselves nor in the portions copied into `ITG.lean`.
- the Integrator may modify content that came from `ITG-1.lean` / `ITG-2.lean`.
- if a modification turns a green proof non-green: revert it, keep the green, and mark the non-green modification stale (discard).
- check consistency (the report against `ITG.lean`) before the implementation/merge step.

## duties moved from the runner to the Integrator

the Integrator owns: the chain/atlas report build (from `ITG.lean`, div-id node identity — the graph-like structure that replaces `dependency-graph.json`), the hire test (on `ITG.lean`: `#print axioms` footprints + established nodes → `[Hired]` count), the green connection proofs → the Formalizer's merge queue (via the D-QUEUE handoff artifact + a `runtime/requests/` request), `formalizer/hireable-registry.md`, `formalizer/connection-proofs.md`, and direct deposit of its new green codes to `dossier/idea-pool/reliable-idea-set/` (second writer, the Formalizer deposit pattern).

the runner drops: graph build, `[Hired]`-marking in `single.lean`, proves/`connection-proofs.md` maintenance, and the hire test. the runner adds: version marking on every `single.qmd` / `single.lean` update. the runner keeps: plan/convert/symbols/verify/lock+deposit/watch — it still converts `single.qmd` → `single.lean` and maintains `formalizer/symbol-list.md`.

## locked decisions

- version marking: after the workers finish, the **Integrator** marks versions of `ITG-1.lean`, `ITG-2.lean`, `ITG.lean`.
- D1 chain/atlas report: **kept** as an Integrator deliverable.
- D2: **no `[Hired]` in `single.lean`** (it is a dictionary); `[Hired]` appears only in `ITG.lean`.
- D-GRAPH: graphify is visualization-only, out of workflow; the **milestone reads the report**; the **miners read only `ITG.lean`**; `dependency-graph.json` is retired as the workflow source.
- D-REG: the Integrator writes **both** `hireable-registry.md` and `connection-proofs.md`.
- D-RIS: direct (second writer). D-QUEUE: merge-handoff artifact + `runtime/requests/` request. D-BUDGET: background budget.
- cautions: no forced chains, no re-verification, no locking.

## file ownership deltas

- `dossier/idea-pool/reliable-idea-set/` — runner only → runner + Integrator (second writer).
- `formalizer/hireable-registry.md` → the Integrator.
- `formalizer/connection-proofs.md` — runner → the Integrator.
- `[Hired]` marks — `single.lean` (runner) → `ITG.lean` (Integrator).
- `formalizer/dependency-graph.json` — retired as the milestone/miner source; the report + `ITG.lean` replace it.

## artifact rules and versioning

- artifacts are files, and the Integrator guarantees them: every worker it directs is spawned with the explicit output path it assigns and must write its artifact there and confirm the write in its final message; a worker that cannot write includes the complete artifact text in its final message and the Integrator persists that text verbatim at the assigned path, marked recovered from agent output. the Integrator checks that every artifact exists after each worker completes and never starts the next step on a missing artifact.
- everything is versioned: every `single-int` snapshot, `ITG` update, report update, registry update and reliable idea set deposit carries a version (v1, v2, …); nothing is cited or built on without its version. the goal file is excluded: it is locked and the project never changes it.

## relationship to the Coordinator and the Formalizer

the Coordinator regulates the Integrator like the other subcoordinators: it spawns it at the round start (stable ID, resume pack `runtime/integrator-state.md`), brokers its worker spawns from `runtime/requests/`, and enforces the background budget and the artifact rules. the Integrator consumes the snapshots the runner version-marked and the promoter's connection-report (via the Formalizer, which passes it as scoping input); it feeds the Formalizer's merge queue with its green connection proofs (the D-QUEUE handoff artifact + a `runtime/requests/` request) and deposits its green codes directly to the reliable idea set. the milestone reads the Integrator's report; the miners read only `ITG.lean`.
