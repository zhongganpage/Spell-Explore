# Knowledge State — navigation index (dossier/index.md)

this file is the Knowledge State navigation index: the conjectures registry, the obstructions register, the champion-route pointer, the formalization status (the green count, the [Formalized] count, the hired count, the kernel+mathlib base count, the goal distance, and the integration-report summary — nodes, edges), and the pointers to the split files. the Coordinator and every fresh worker read this file first, before anything else in the dossier — a fresh worker loads it, then follows the pointers it needs; no worker has to read the whole history. in this package the file is protocol/dossier/index.md; in a project it sits at dossier/index.md, one level below the locked goal file (../goal.md).

the top-level dossier keeps only this index. Status, Notation and the open-threads list stay here at the top level; everything else — the idea pool, the attempts log, the verification ledger, the version inventory, the examples & computations, the reformulations & connections, the literature map — lives in the split files pointed to below. the dossier is one living file until it exceeds ~30 KB, and then it splits into those files, all reachable from this index; the rule that governs both states is the same: append-only, dated, every entry ends with a next step, and the dossier is the memory — a fresh worker reads it before anything else, and nothing the project knows lives only in a previous context.

## status

OPEN — <N> threads active · last session <date>. the status line is never "abandoned": the project never runs autonomously across days, but it always continues — a stalled thread is a storage state with a "resume here", never a verdict.

## problem statement and notation

problem statement: the locked goal file (../goal.md) — the single source; every entry in this dossier points back to it and never re-derives it.

notation: one fixed block, established at round-1 start in the locked goal file and used by every entry and every artifact. the block is notation-locked: it changes only by recording the change as a dated entry here, never by editing the goal file.

## conjectures registry

every conjecture the project records gets an entry here — an intuition is a conjecture, not a fact (record it, then attack it or search for its counterexample before building on it), and so are the conjectures carried by the fresh summaries, the idea reports and the routes. each entry carries its statement, its source and its status in the verification lifecycle: claimed → under-review → accepted | rejected | counterexample. a conjecture in claimed or under-review is never used as a premise — not by later work, not in reporting to the user. the verification ledger (below) holds the review rows; the registry is the list, the ledger is the history.

## obstructions register

every obstruction the project has met is registered here: the obstruction of a stale entry, with the closest technique and the sub-results that still hold, and a pointer into the fragment region where its fragments live, and the load-bearing obstructions named by the rejecting votes of the Selector's swarm — the single missing lemma, false step, or unproved claim whose absence makes the route fail — which the Selector aggregates into the stale entry's failure reason and this register. the register feeds the Producer's pairing — fresh summaries are distributed to its report writers (split as evenly as possible), each assigned set completed by other fresh summaries or by an obstruction and its closest technique from the fragment region, so the report is directed rather than random — and the Creator's second phase, which mines the fragments directly. obstruction-touching and revival-triggered fragments score higher in the goal-frontier score the Producer maintains for every pool idea, which also counts the [Formalized] or [Hired] premises an idea can cite on the goal path and rewards ideas that would hire new axiom-class nodes.

## residual registry (subgoals)

the residual registry holds the bounded subgoal list toward the locked goal: the dossier file dossier/residual-registry.md, whose entries are subgoals — major steps toward the goal. the champion-route defender PI proposes the subgoals — a clear list of major steps toward the goal, e.g. at route acceptance or at round close; the Coordinator inspects the support of each proposal against the route material and the verification-ledger rows and economizes — merges overlapping proposals, drops unsupported ones, trims to the cap; the Coordinator records the survivors as subgoals in dossier/residual-registry.md. the active list is bounded at the cap: at most 5 active subgoals at any time. the registry feeds the round's residual targets — the 0–2 subgoals the Coordinator names at round start — and the Creator's phase-2 mining.

## champion-route pointer

the champion route is the current best accepted route: the accepted route — named by its title and its version — that stands closest to the locked goal, together with the set of accepted routes that together cover it. the pointer names the champion and points into the question-routes folder, into the subfolder named by the title of that route, where the summaries, the idea reports, the route with its versions and the review reports of the route live; the Coordinator maintains it and updates it as routes are accepted. the pointer also records the current defender PI — the PI of the route's latest accepted version, named by its PI id and the route version — who answers every future challenge to the route, any version; superseded versions stay archived in the subfolder, recorded, never deleted. acceptance is the double gate: ≥2/3 of the swarm workers and ≥2/3 of the resumed BCD reviewers, with the panel's three review summaries and the promoter's nearest true version note (a high-level check on the route's claims) in front of the swarm, which judges the route itself. the project reaches a milestone only on full consensus — 3/3 + 3/3 — with the accepted routes achieving the locked goal — operationally, the goal node of the Integrator's report reachable from the established base (kernel axioms + Mathlib theorems + [Formalized] pieces), with `#print axioms goalTheorem` containing no non-kernel axiom, and a full manuscript claim requires the hired set empty and the reachability proven in Lean; at that point the pointer records the achieving set and the Coordinator writes the manuscript (PDF).

## formalization status

the formalization status block holds the green count, the [Formalized] count, the hired count, the kernel+mathlib base count, the declared-axiom footprint count (the unformalized declared nodes on which green results depend), the goal distance — the explicit blocking set on the path to the goal node: the unformalized declared nodes plus the named open windows, refreshed at each round close — the fragment deposits and the integration-report summary — nodes and edges. the Formalizer keeps the formalization status in the Knowledge State index current: after each completed batch — a decompose run, a swarm batch that writes its per-fragment files, or a lean code runner wake that greens a piece or deposits fragments — it writes one dated line recording the green count, the [Formalized] count, the fragment deposits and the integration-report summary delta, so the index always reflects the current formalization state and the Coordinator's round-start check reads a live number. the Coordinator reads it in its bounded round-start check — a bounded read that, like the round-1 setup, is not counted in the 138-minute budget — and every fresh worker reads this file first and sees the citable [Formalized] state.

## open threads / next steps

the attack queue stays with this index. every thread ends with a concrete next step; a worker that cannot write one walks down the stuck ladder until it can. a new worker takes the top next step — never a fresh attack from scratch while a thread is mid-flight.

## pointers to the split files

- idea pool — ../idea-pool/ — the fixed well-known location of the pool, resolved through this index after the split; it holds the fresh summaries, the reliable idea set with its [Formalized] markers, and the fragment region, and it stays part of the dossier (see ../idea-pool/README.md).
- attempts log — ../attempts-log.md — the heart of the persistence protocol; entries with exactly five fields: tried / broke / implies / next.
- verification ledger — ../verification-ledger.md — one row per review round: date | claim | status | reviewer | verdict & reasons | repair targets; append-only, and the verdict column carries the reviewer's reasons, never the author's.
- version inventory — ../version-inventory.md — every versioned artifact: fresh summaries, idea reports, routes, review summaries, change lists, stale entries, qmd file updates, reliable idea set entries, fragment region updates, report updates, ITG.lean, ITG-1.lean / ITG-2.lean, question-routes.md, and the manuscript.
- examples & computations — ../examples.md — dated table: case, computed value, pattern observed.
- reformulations & connections — ../reformulations.md — numbered forms, each with "useful because…" and a date; every reformulation is recorded, even the ones that go nowhere.
- literature map — ../literature-map.md — source, theorem, what it leaves open; one new source per worker until the area is covered.
- residual registry — ../residual-registry.md — the bounded subgoal list toward the locked goal (PI-proposed, Coordinator-curated).

## how the rest of the dossier connects

the fixed sequence the dossier serves: Creator → Producer → Selector. the Creator produces the fresh summaries; the Producer pairs them by complementarity and its report worker writes the idea report — which must satisfy the hygiene linter's layer-2 format: every claim, lemma, theorem and proposition with a precise statement, its assumptions explicitly listed, and its implications — and the successful report is renamed a route with a title; the Selector runs the adversarial panel, the PI rebuts, the swarm decides. the Formalizer and the feedback lanes (failures and rejections marked stale, mined again by the Creator's second phase) branch off this main sequence. the Coordinator measures the system — idea-yield, premature kills, the consistency of the panel verdicts — and records the measurements in the dossier; they may feed back into the examine worker's rigor, never into the votes, whose acceptance thresholds are fixed.

related files outside the dossier: the Formalizer's single qmd file, the integration report (formalizer/Integrator/integration-report.md — statement nodes with their status classes kernel | mathlib | formalized | axiom | goal, green edges, [Hired] flags, goal node) and the integration working lean file (formalizer/Integrator/ITG.lean) live in the formalizer folder of the project; the question-routes folder holds question-routes.md — the living map of the main question and the accepted-route abstracts — a copy of the full reliable idea set, and the per-accepted-route subfolders named by their titles.
