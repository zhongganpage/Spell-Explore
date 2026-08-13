# Integrator subcoordinator — design spec v1 (2026-08-13, user decision; implementation at the repair session)

authoritative design for the new **Integrator** subcoordinator of Spell-Explore. the protocol source is `references/protocol/` (the packaged skill's protocol tree); this spec lives at `references/`, a sibling of `patch-spec-connection-proofs-v1.md`. it consolidates the user's change ideas and the adopted suggestions. the change record is the "Integrator owns the dependency graph" row to be added to `spec-amendments.md`; where this file and `spec-amendments.md` differ, this file (newer) governs. style: lowercase, dense, single long paragraphs; every artifact is versioned (v1, v2, …).

## 1. the problem

marks, notations and statements are scattered across `formalizer/single.qmd` and the generated lean in `formalizer/lean/single.lean`; the dependency graph (`formalizer/dependency-graph.json`) shows no useful long connecting paths. fix: a new subcoordinator, the **Integrator**, that integrates the statements of qmd and lean with two workers, realizes the connection marks as green connecting proofs, and maintains the chain report plus the hire test.

## 2. role and lifecycle

the Integrator is a subcoordinator, spawned by the Coordinator at the start of each round; it keeps a **stable ID across rounds** (an exception to the round-boundary fresh-spawn rule) with its own resume pack + state file and a lifecycle contract. it requests its worker spawns from the Coordinator. its workers are **ephemeral** (no stable IDs). it runs in the background — the two workers need 45 + 15 = 60 minutes, which cannot fit the 0–20 window. every spawn is in the explicit background mode.

## 3. sandbox and files

the Integrator changes nothing outside `formalizer/Integrator/` except the sanctioned out-of-subfolder writes below — the reliable idea set deposit, `formalizer/hireable-registry.md`, and `formalizer/connection-proofs.md`. files:

- `formalizer/Integrator/single-int.qmd` — snapshot of `formalizer/single.qmd` (renamed copy; the Integrator never reads the original after the copy and sticks to this version).
- `formalizer/Integrator/single-int.lean` — snapshot of `formalizer/lean/single.lean`.
- `formalizer/Integrator/ITG.lean` — its own integration working lean file.
- `formalizer/Integrator/ITG-1.lean` — worker 1's green proofs; `formalizer/Integrator/ITG-2.lean` — worker 2's green proofs.
- `formalizer/Integrator/symbol-list.md` — its own precise symbol dictionary (seeded from `formalizer/symbol-list.md`; workers stick to ITG symbols).
- `formalizer/Integrator/integration-report.md` — the chain/atlas report, kept consistent with `ITG.lean`; the milestone source.

## 4. version gating

the runner marks versions of `formalizer/single.qmd` and `formalizer/lean/single.lean` on every update. version unchanged → the Integrator does nothing; updated → it works only on the new items (delta).

## 5. per-round procedure

1. inspect `single-int.qmd` + `single-int.lean`; identify all marks, especially connection marks and their statements.
2. unify symbols from `single-int.lean` into `ITG.lean`; update `symbol-list.md`; workers stick to ITG symbols.
3. plan connection jobs; request the two worker spawns from the Coordinator.
4. run the workers (strict windows; not responsible for unreachable work):
   - worker 1 (45 min): T/F-completeness check (only T or only F → do nothing); read the marked qmd codes + the promoter's connection-report + related artifacts (accepted routes, review reports) for the prose proofs; write the lean proof code connecting the T/F statements; does not run lean. bonus if time remains: best-effort inspect adapting its proofs to non-connection-marked statements (not required to finish).
   - worker 2 (15 min): run the lean code, identify green, fix non-green by run→fix→run (no fixing at the start); keep green results.
   - both: never change statements/axioms/theorems — only create/modify proof code.
5. integration step: merge `single-int.lean` + `ITG-1` + `ITG-2` into `ITG.lean` under the merge rules of §6; never change `single-int` content.
6. maintain `integration-report.md` consistent with `ITG.lean`. graphify on `ITG.lean`, if produced, is visualization-only and never joins the workflow.

## 6. merge rules (binding)

- never change `single-int` content — neither in `single-int.qmd` / `single-int.lean` themselves nor in the portions copied into `ITG.lean`.
- the Integrator may modify content that came from `ITG-1.lean` / `ITG-2.lean`.
- if a modification turns a green proof non-green: revert it, keep the green, and mark the non-green modification stale (discard).
- check consistency (the report against `ITG.lean`) before the implementation/merge step.

## 7. duties moved from the runner to the Integrator

the Integrator owns: the chain/atlas report build (from `ITG.lean`, div-id node identity — the graph-like structure that replaces `dependency-graph.json`), the hire test (on `ITG.lean`: `#print axioms` footprints + established nodes → `[Hired]` count), the green connection proofs → the Formalizer's merge queue (via the D-QUEUE handoff artifact + `runtime/requests/` request), `formalizer/hireable-registry.md`, `formalizer/connection-proofs.md`, and direct deposit of its new green codes to `dossier/idea-pool/reliable-idea-set/` (second writer, Formalizer deposit pattern).

the runner drops: graph build, `[Hired]`-marking in `single.lean`, proves/`connection-proofs.md` maintenance, and the hire test. the runner adds: version marking on every `single.qmd` / `single.lean` update. the runner keeps: plan/convert/symbols/verify/lock+deposit/watch — it still converts `single.qmd` → `single.lean` and maintains `formalizer/symbol-list.md`.

## 8. locked decisions

- version marking: after the workers finish, the **Integrator** marks versions of `ITG-1.lean`, `ITG-2.lean`, `ITG.lean`.
- D1 chain/atlas report: **kept** as an Integrator deliverable.
- D2: **no `[Hired]` in `single.lean`** (it is a dictionary); `[Hired]` appears only in `ITG.lean`.
- D3: spec record kept; this file is the record.
- sandbox exception: the one out-of-subfolder write is the reliable idea set deposit.
- D-GRAPH: graphify is visualization-only, out of workflow; the **milestone reads the report**; the **miners read only `ITG.lean`**; `dependency-graph.json` is retired as the workflow source.
- D-REG: the Integrator writes **both** `hireable-registry.md` and `connection-proofs.md`.
- D-RIS: direct (second writer). D-QUEUE: merge-handoff artifact + `runtime/requests/` request. D-BUDGET: background budget.
- cautions: no forced chains, no re-verification, no locking.

## 9. file ownership deltas

- `dossier/idea-pool/reliable-idea-set/` — runner only → runner + Integrator (second writer).
- `formalizer/hireable-registry.md` → the Integrator.
- `formalizer/connection-proofs.md` — runner → the Integrator.
- `[Hired]` marks — `single.lean` (runner) → `ITG.lean` (Integrator).
- `formalizer/dependency-graph.json` — retired as the milestone/miner source; the report + `ITG.lean` replace it.
