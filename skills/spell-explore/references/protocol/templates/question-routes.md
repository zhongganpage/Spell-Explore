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
- acceptance: `<swarm x/3, BCD x/3 — full consensus (3/3 + 3/3) is the strongest>`
- current defender PI: `<the PI of the route's latest accepted version — named by its PI id
  and the route version — who answers every future challenge to the route, any version>`
- status: `<current | challenged | revised | superseded>`
- artifacts: `<the subfolder named by the title — summaries, idea reports, route versions,
  review reports>`

`<one entry per accepted route, each carrying its current version and its current defender
PI; when a route is revised, the new version and the new defender are recorded here — the new
PI (route writer) archives the accepted revision as the new version and marks the older version
superseded — and the older versions' artifacts stay in the subfolder, recorded, never deleted>`

## the reliable idea set (copy)

- reliable-idea-set.md: `<a copy of the full reliable idea set — the formalized pieces as lean
  code, each carrying the [Formalized] marker — kept in this folder and regenerated at round close by a
  file copy from dossier/idea-pool/reliable-idea-set/, never maintained by hand; the canonical reliable
  idea set lives in the same place as the idea pool in the dossier>`

## rules that bind this artifact

- maintained by the Coordinator, versioned like every artifact.
- only accepted routes appear here: everything before acceptance — fresh summary, idea report,
  route under review — is never treated as established.
- this map stays current because acceptance is not the end: a route may be challenged or
  revised in a later round, so the abstracts here are the current ones, and older versions are
  kept in the subfolder, never deleted.
- when a milestone is reached — all 3 swarm workers and all 3 BCD reviewers accept, and the
  accepted routes together achieve the locked goal — the Coordinator writes the manuscript (lock this name),
  a PDF report about the milestone.
