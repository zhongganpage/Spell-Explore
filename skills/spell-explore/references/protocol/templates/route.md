# route — template

a route (lock this name) is an idea report that passed the hygiene linter and the examine
worker, renamed with a title (lock this name) to distinguish it from other routes. the worker
who produced the successful report remains and is called the PI (lock this name). the route is
the unit the Selector reviews; only an accepted route is presented to the user. this file is
the template the Producer and the PI maintain; the filled file becomes the artifact.

## who, when, where

- created by: the Producer, from a successful report — the report is renamed a route with a
  title; the Producer archives it properly with versions.
- the PI: the worker who produced the successful report remains and is called the PI; it
  defends and modifies the route in the 103–118 window, makes a change list, and stays resumable.
- where it lives: the project folder (routes/), versioned; once accepted, all its artifacts are
  gathered in the question-routes folder, in a subfolder named by the title of that route.
- the Selector reviews each fresh route as it becomes ready; an accepted route is marked a new
  version by the Producer.

## the format

### title (lock this name)

`<the route's title — short, and it distinguishes this route from every other route>`

### version

`<v1, v2, …>` — every route carries a version; nothing is cited or built on without its version.

### provenance

- idea report: `<report id + version it was renamed from>`
- paired fresh summaries / fragments: `<summary ids + versions, or fragment ids>`
- PI: `<PI id>`

### body

`<the report content, now as the route: the groups of claims in the format — statement,
assumptions, implications — with precise citations and the promise toward the goal. revisions
are applied here, never silently: every modification after review is a new version.>`

### review record (filled as the route moves)

- review summaries: `<the three review summaries, B/C/D, ids + versions, once produced>`
- canary outcome: `<announced — known-false claim caught? step-error caught with the step
  cited? · unannounced swarm-stage canary detection when carried>`
- change list + rebuttal: `<version + pointer, after the PI's 103–118 window>`
- promoter's nearest true version note: `<pointer, written in the same 103–118 window>`
- promoter's connection marks: `<pointer — the connection report written in the 118–138
  window, and the `[<route title>-T-<implied id>]` / `[<route title>-F-<initial id>]`
  marks the promoter wrote into the single qmd file>`
- verdicts: `<swarm count x/3, BCD count x/3, accepted / not accepted>`
- defender: `<current defender PI id>` · superseded versions: `<older versions of this title
  already handed over>`
- formalization watch: `<acceptedR pieces: green/total · watch state: none | no-green>`

### status

`<under review | accepted | unaccepted | stale>` — an accepted route may additionally carry
the transient watch marker [no-green] (no [acceptedR] piece green in the latest lean-runner
batch — the status stays `accepted` until a second consecutive no-green batch,
rules/formalizer.md); a staled accepted route is demoted like any stale route.

## rules that bind this artifact

- only the Selector's accepted routes are presented to the user, and the user sees the accepted
  route before it is marked a new version.
- acceptance = ≥2/3 of the swarm workers (2 of 3) AND ≥2/3 of the BCD reviewers. the counts
  rank the quality of an accepted route: full consensus (3/3 + 3/3) is the strongest; lower
  counts are accepted but weaker. the milestone = 3/3 + 3/3 and the accepted routes together
  achieving the locked goal.
- acceptance is not the end of a route: a route may be challenged or revised in a later round,
  so question-routes.md stays a living map of the main question and the current accepted-route
  abstracts.
- an unaccepted route is sent back to the Creator for the second phase unless the user parks
  it; either way it is marked stale with a stale entry — failure reason, revival trigger, and
  fragments (the sub-results that still hold, the obstruction, the closest technique).
- each review of the route carries the canary gate: a seeded known-false claim and one planted
  step-error ride in the review batch (both excluded from the real record and the route); the
  route may not be accepted unless the panel catches the claim (≥80%) and the step-error (100%,
  with the step cited).
