# question-routes — protocol/question-routes/

The dedicated folder the Coordinator maintains. it holds the living map of the
main question and the accepted routes, and every artifact related to each
accepted route.

## What lives here

- question-routes.md — the main question and, as each route is accepted, the
  abstract of that route. accepted routes are not completely trustworthy and
  acceptance is not the end of a route: a route may be challenged or revised in
  a later round, so question-routes.md stays a living map of the main question
  and the current accepted-route abstracts.
- reliable-idea-set.md — a copy of the full reliable idea set (lock this name).
- one subfolder per accepted route, named by the title of that route, holding
  all artifacts related to it: the summaries, the idea reports, the route with
  its versions, and the review reports (including the review summaries of the
  BCD reviewers).

## Who writes

- the Coordinator: question-routes.md updates, the reliable idea set copy, and
  the per-route subfolders with their artifact copies — transferred between
  stages only as files, every artifact checked to exist before the next phase or
  handoff starts.

## Who reads

- the user: every accepted route is presented together with the decision list,
  which covers the abstracts of the accepted routes (and recycle / park for each
  unaccepted route).
- the Coordinator, and any worker that needs the current accepted-route state.

## Note

- everything in this folder is versioned (question-routes.md included); nothing
  is cited or built on without its version. at a milestone — all 9 swarm workers
  and all 3 BCD reviewers accept and the accepted routes together achieve the
  locked goal — the Coordinator writes the manuscript (lock this name), the
  report about the project in PDF.
