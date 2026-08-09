# question-routes.md — template

the Coordinator maintains a dedicated folder named question-routes (lock this name). it holds
this file — question-routes.md — which is the living map of the main question and the current
accepted-route abstracts, and, for every accepted route, all artifacts related to it (the
summaries, the idea reports, the route with its versions, and the review reports) in a subfolder
named by the title of that route. a copy of the full reliable idea set is also stored as a file
in the question-routes folder. accepted routes are not completely trustworthy and acceptance is
not the end of a route: a route may be challenged or revised in a later round, so this map is
updated with every acceptance, challenge, and revision. this file is the template the
Coordinator maintains.

## the main question

`<the main question, stated exactly as the locked goal file states it — the locked goal file is
the single source of the problem statement and notation, is cited by every worker, and is never
edited>`

## accepted routes (living map)

### `<route title>` — `<current version>`

- abstract: `<the abstract of the route — what it claims, its assumptions, its promise toward
  the goal>`
- acceptance: `<swarm x/9, BCD x/3 — full consensus (9/9 + 3/3) is the strongest>`
- status: `<current | challenged | revised | superseded>`
- artifacts: `<the subfolder named by the title — summaries, idea reports, route versions,
  review reports>`

`<one entry per accepted route; when a route is revised, the new version is recorded here and
the older versions' artifacts stay in the subfolder>`

## the reliable idea set (copy)

- reliable-idea-set.md: `<a copy of the full reliable idea set — the formalized pieces as lean
  code, each carrying the [Formalized] marker — kept in this folder and refreshed as the lean code runner
  locks new green pieces; the canonical reliable idea set lives in the same place as the idea pool in
  the dossier>`

## rules that bind this artifact

- maintained by the Coordinator, versioned like every artifact.
- only accepted routes appear here: everything before acceptance — fresh summary, idea report,
  route under review — is never treated as established.
- this map stays current because acceptance is not the end: a route may be challenged or
  revised in a later round, so the abstracts here are the current ones, and older versions are
  kept in the subfolder, never deleted.
- when a milestone is reached — all 9 swarm workers and all 3 BCD reviewers accept, and the
  accepted routes together achieve the locked goal — the Coordinator writes the manuscript (lock this name),
  a PDF report about the milestone.
