# question-routes — protocol/question-routes/

The dedicated folder the Coordinator maintains. it holds the living map of the
main question and the accepted routes, and every artifact related to each
accepted route.

## What lives here

- question-routes.md — the main question and, as each route is accepted, the
  abstract of that route. accepted routes are not completely trustworthy and
  acceptance is not the end of a route: a route may be challenged or revised in
  a later round, so question-routes.md stays a living map of the main question
  and the current accepted-route abstracts. each accepted-route entry carries
  its current version and its current defender PI — the PI of the latest
  accepted version, named by its PI id and the route version — who answers
  every future challenge to the route, any version. superseded versions are
  recorded, never deleted.
- reliable-idea-set.md — a copy of the full reliable idea set (lock this name),
  regenerated at round close by a file copy from
  dossier/idea-pool/reliable-idea-set/, never maintained by hand.
- one subfolder per accepted route, named by the title of that route, holding
  all artifacts related to it: the summaries, the idea reports, the route with
  its versions, and the review reports (including the review summaries of the
  BCD reviewers). superseded versions stay archived in the subfolder, recorded
  and never deleted; when a revision is accepted, the new PI (the route writer)
  writes it in as the new version and marks the older version superseded (old
  files never edited).

## Who writes

- the Coordinator: question-routes.md updates, the reliable idea set copy — a
  file copy from dossier/idea-pool/reliable-idea-set/ at round close, never
  maintained by hand — the per-route subfolders with their artifact copies —
  transferred between stages only as files, every artifact checked to exist
  before the next phase or handoff starts — and the handover bookkeeping after
  an accepted revision is seen by the user: verify the new version is archived,
  mark the replaced PI superseded, TaskStop its task, record the new defender in
  question-routes.md and the champion-route pointer.
- the new PI (the route writer of an accepted revision): archives the accepted
  revision in question-routes/<title>/ as the new version, marking the older
  version superseded.

## Who reads

- the user: every accepted route is presented together with the decision list,
  which covers the abstracts of the accepted routes (and recycle / park for each
  unaccepted route).
- the Coordinator, and any worker that needs the current accepted-route state.

## Note

- everything in this folder is versioned (question-routes.md included); nothing
  is cited or built on without its version. at a milestone — all 3 swarm workers
  and all 3 BCD reviewers accept and the accepted routes together achieve the
  locked goal — the Coordinator writes the manuscript (lock this name), the
  report about the project in PDF.
