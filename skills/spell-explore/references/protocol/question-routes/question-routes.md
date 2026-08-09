# question-routes — living map of the main question and the accepted routes (template)

This file is the living map maintained by the Coordinator. It holds the main question
and, as each route is accepted, the abstract of that route. It lives in the
question-routes folder in the project folder, together with the per-accepted-route
artifact subfolders and the copy of the reliable idea set. It carries a version; every
change to it is a new version (v1, v2, …) and nothing is overwritten without
versioning.

## The main question

The single source of the main question is the locked goal file (goal.md): the precise
statement and notation. The Coordinator writes the main question here at round-1 setup
by copying it from the locked goal file; workers cite the locked goal file, never
this copy. If the statement below ever disagrees with the locked goal file, the locked
goal file wins.

- Version: (v1 at instantiation)
- Main question: (placeholder — the precise statement and notation of the locked
  goal, copied by the Coordinator at round-1 setup)

## Accepted routes

Accepted routes are not completely trustworthy, and acceptance is not the end of a
route: a route may be challenged or revised in a later round. This map is living — it
shows the current accepted-route abstracts, and an abstract here can change (as a new
version) when its route is revised. Each accepted route has a subfolder in the
question-routes folder, named by the title of that route, holding all artifacts
related to it: the summaries, the idea reports, the route with its versions, and the
review reports.

### <Route 1 title> — accepted (route v<version>)

- Accepted in: (round number, decision-list entry)
- Abstract: (placeholder — the abstract of the route, written when the route is
  accepted and kept current when the route is revised)
- Artifacts: question-routes/<Route 1 title>/ (summaries · idea reports · route
  versions · review reports)

### <Route 2 title> — accepted (route v<version>)

- Accepted in: (round number)
- Abstract: (placeholder)
- Artifacts: question-routes/<Route 2 title>/

(Add one entry per accepted route, in the order the routes were accepted. When a route
is challenged or revised in a later round, update its abstract as a new version of
this file; do not delete the old entries' history.)

## Reliable idea set copy

A copy of the full reliable idea set is stored as a file in this folder
(reliable-idea-set.md). The Coordinator keeps the copy current — it mirrors the full
reliable idea set in the dossier's idea pool, including its [Formalized] markers.
