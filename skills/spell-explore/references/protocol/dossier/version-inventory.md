# version-inventory.md — everything is versioned

the goal file is excluded from this rule: it is locked and the project never changes it. every other artifact carries a version (v1, v2, …); nothing is cited or built on without its version. this file is the split-out version-inventory section of the dossier (see the ~30 KB split rule and the Knowledge State navigation index in ./index.md). append-only: a new version is a new row, never an edit of history.

## artifacts that carry versions (the full list)
every fresh summary · idea report · route · review summary · change list · stale entry · qmd file update · reliable idea set entry · fragment region update · dependency graph update · question-routes.md · the manuscript.

## who versions what
- the Creator archives the fresh summaries in the idea pool in the dossier (append-only for workers — no worker may delete anything in the idea pool; the Creator's phase-2 summaries are fresh too).
- the Producer archives every idea report and every route with versions; a route keeps its title, and an accepted route is marked a new version by the Producer.
- the Selector marks the routes accepted / unaccepted in the archive.
- a stale entry records the failure reason, the revival trigger ("re-examine when <event>"), and the fragments — the sub-results that still hold, the obstruction, and the closest technique; the fragments are archived in the fragment region of the idea pool in the dossier.
- the Formalizer's single qmd file (there is only one): every update is a new version; whenever a qmd piece is lean-green, the lean code runner locks that piece in the qmd file (green pieces are locked in place, never removed) and places the corresponding lean code in the reliable idea set — a new entry, with its version, carrying the [Formalized] marker.
- the lean code runner builds and updates the dependency graph: a node is a statement (in the lean code format, not qmd) carrying a status class — kernel | mathlib | formalized | axiom | goal — and an edge is "the proof of the conclusion references the premise," derived from Lean (`#print axioms`), never from qmd citations; an axiom-class node becomes [Hired] iff some green lean code whose conclusion is that node's statement is implied by the established base, and the main goal is a distinguished node of the tree. each graph update is a new version.
- the Coordinator maintains question-routes.md — the living map of the main question and the abstract of every accepted route — and, at a milestone (3/3 + 3/3 + the accepted routes together achieving the locked goal — operationally, the goal node of dependency-graph.json reachable from the established base — kernel axioms + Mathlib theorems + [Formalized] pieces — with `#print axioms goalTheorem` clean of non-kernel axioms), writes the manuscript (PDF).

## register

| artifact | identifier | current version | history | owner | updated (round, date) | status / notes |

rules:
- nothing is cited or built on without its version: any reference to a fresh summary, idea report, route, review summary, change list, stale entry, qmd file update, reliable idea set entry, fragment region update, dependency graph update or question-routes.md must name its version.
- every versioned artifact is a file written to its assigned output path by its worker, and the worker confirms the write in its final message; a worker that cannot write includes the complete artifact text in its final message and the responsible subcoordinator persists it verbatim, marked recovered from agent output. nothing starts the next phase or handoff on a missing artifact.
- version numbers never restart; an artifact's history lives with it (versioned files in the reports/, routes/ and stale/ folders and in question-routes/<title>/ subfolders), and this register holds the pointer.
- the round-close record (fresh routes · verdicts · stale list with fragments · phase-time table) is a single atomic write at 138 min; phase start and end timestamps are recorded at each boundary in the phase-time table, never reconstructed after the fact. the round start is announced and written in the dossier before any agent spawns. the round's timeline windows are 0–20, 20–45, 45–63, 63–103, 103–118, 118–138.

## template rows — illustrations
| fresh summary | <fs-id> | v1 | v1 → … | Creator | round 1, 0–20 | archived in the idea pool; round ≥ 2 summaries are novelty-checked against the pool |
| idea report | <report-id> | v1 | v1 → … | Producer | round 1, 20–45 | versioned; linted, then renamed a route on success |
| route | <title> | v1 | v1 → v2 … | Producer / PI | round 1 | accepted → marked a new version by the Producer; artifacts live in question-routes/<title>/ |
| review summary | <route> B/C/D | v1 | v1 → … | Selector | 63–103 | three summaries per panel |
| change list | <route> | v1 | v1 → … | PI | 103–118 | with the rebuttal; feeds the swarm decision |
| stale entry | <id> | v1 | v1 → … | Producer / Selector | round close | fragments → fragment region, with revival trigger |
| qmd file update | single.qmd | v1 | v1 → … | Formalizer | any round | green pieces LOCKED in place, never removed |
| reliable idea set entry | <formalized id> | v1 | v1 → … | lean code runner | on green | lean code carrying the [Formalized] marker |
| fragment region update | <fragment id> | v1 | v1 → … | swarm / stale rule | any round | unformalized bits, partial work, unclustered material |
| dependency graph update | dependency-graph.json | v1 | v1 → … | lean code runner | on new green lean code | nodes + green edges; [Hired] flags; goal node |
| question-routes.md | question-routes.md | v1 | v1 → … | Coordinator | on each accepted route | living map: main question + accepted-route abstracts |
| manuscript | manuscript.pdf | v1 | v1 → … | Coordinator | at milestone | the milestone report (3/3 + 3/3 + goal achieved) |
