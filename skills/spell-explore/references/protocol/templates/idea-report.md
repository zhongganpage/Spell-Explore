# idea report — template

an idea report (lock this name) is written by the Producer's report worker from a triple of three fresh
summaries and its complement material — another fresh summary, or an obstruction and its closest technique
from the fragment region — so the report is directed rather than random. it must satisfy the
format (lock this name) below, which is what the hygiene linter's layer 2 checks: every claim,
lemma, theorem and proposition carries a uniform structure — a precise statement, its
assumptions explicitly listed, and its implications — grouped so that the Formalizer's decompose
workers and swarm workers can easily process them. the report must then pass the examine worker
and be renamed a route with a title.

## who, when, where

- produced by: the Producer's report worker, in the 20–45 window (21–46 in rounds ≥ 3), at most 25 minutes, strictly
  from the triple and its complement material — the main core is what is in the triple; other
  dossier ideas (including the fragments deposited by stale reports, summaries and routes) may
  support it but do not replace the core.
- before writing: the report worker actively reviews the reliable idea set and the current
  dependency graph, and finds the interesting ideas according to its own reasoning about the
  summaries it received — the goal-frontier score guides the pairing but does not dictate the
  worker's synthesis.
- where it lands: the Producer archives the report in the project folder (reports/), versioned;
  the Formalizer's inputs are verdict-aware: examine-failed lint-passed reports go immediately;
  accepted/accepted-core routes (full or core form) together with the promoter's note go
  post-verdict from the Selector; rejected pairs go to the fragment region; the note is
  scoping metadata, never decomposed.
- after the examine: a successful report is renamed a route with a title, and the worker who
  produced it remains and is called the PI. an unsuccessful report is sent back to the Creator
  for the second phase and marked stale.

## the format (lock this name)

the report is organized as: header, groups of claims, precise citations, promise toward the
goal, completeness. every claim/lemma/theorem/proposition appears inside exactly one group and
carries the uniform three-part block statement → assumptions → implications.

### header

- title: `<a working title for the approach>`
- triple: `<summary-id + version>` ×3 · complement material: `<fragment
  ids from the fragment region>`
- goal-frontier context: `<the goal-frontier score of the triple, as given by the Producer>`
- version: `<v1, v2, …>`

### groups of claims

the report is organized in numbered groups. each group bundles the claims that belong together
— the linter's layer 2 identifies the assumptions and implications of every claim and groups
them, so the decompose workers and the swarm workers in the Formalizer can easily process them.

#### group `<G1, G2, …>` — `<group title>`

for each claim/lemma/theorem/proposition inside the group, the uniform block:

##### `<claim | lemma | theorem | proposition>` `<id>`

- statement: `<precise statement — no unfinished sentences, equations or diagrams>`
- assumptions: `<every assumption explicitly listed; none hidden in the prose>`
- implications: `<what this claim implies, and what it is implied by; where the proof lives —
  inline or a pointer into the dossier>`

definitions are stated the same way: statement, assumptions, implications. the report writer
must make sure the definitions, lemmas and theorems are well stated and their assumptions
explicitly given — otherwise the report will not pass the hygiene linter.

### precise citations

every citation carries a source and a locator (so linter layer 1 can resolve it), and names
what that source leaves open. proofs of the report's claims are inline or present in the dossier
with a pointer.

### promise toward the goal

`<how this work achieves the ultimate goal: the clear promise, with confidence and evidence.
state the confidence honestly and name the evidence — the definitions, lemmas and theorems
above — that support it. the promise must be explicit; the examine worker checks whether the
claims about the ultimate goal are conveyed clearly>`

### completeness

`<the report is complete: no unfinished sentences, equations or diagrams; every claim carries a
structurally complete proof attempt — a proof present for every lemma, theorem and proposition,
no GAP markers, no claim without a proof; numbers, brackets and constants internally consistent;
the locked names used consistently. the examine worker checks completeness directly — incomplete
reports fail sufficiency>`

## rules that bind this artifact

- the hygiene linter runs before the examine worker, on every idea report. layer 1 is a
  deterministic mechanical pass (no AI): every citation resolves to a real source with a
  locator; every claim's proof is inline or present in the dossier; the locked names are used
  consistently; numbers, brackets and constants are internally consistent. layer 2 produces the
  format above. the linter is not a reviewer: it never judges the correctness of the
  mathematics, and layer 2 is never delegated to a swarm — the swarms are purely mechanical.
- a report that does not pass the quick lint is stale: it does not move on, and the round
  produces no route from it.
- the examine worker then judges one thing only: is the material sufficient enough to become an
  approach? it checks accurate literature, good quality of statement and proofs (no immediate
  mistakes), whether every claim carries a structurally complete proof attempt — every lemma,
  theorem and proposition has a proof present, no GAP markers, no claim without a proof — clear
  claims about the ultimate goal, and completeness. it never judges
  correctness. it has an 8-minute cap in the 45–63 window (46–64 in rounds ≥ 3).
- an unsuccessful report is marked stale: the stale entry records the failure reason (including
  the examine's sufficiency finding), a revival trigger, and the fragments — the sub-results
  that still hold, the obstruction, and the closest technique — deposited in the fragment
  region.
- when the report is renamed a route, the route keeps this report's version lineage.
