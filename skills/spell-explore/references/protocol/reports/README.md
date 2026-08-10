# idea reports — protocol/reports/

Versioned idea reports live in the project folder (not in the dossier). an idea
report (lock this name) is what the Producer's report worker writes from a
triple of three fresh summaries and its complement material; it becomes a route only after it passes
the hygiene linter and the examine worker.

## What lives here

- idea reports, each carrying a version (v1, v2, …); nothing is cited or built
  on without its version.
- a report is well-organized with precise citations and makes a clear promise
  about how to achieve the ultimate goal through its work (with confidence and
  evidence). its definitions, lemmas and theorems are well stated, with their
  assumptions explicitly given — otherwise it will be difficult to pass the
  hygiene linter.

## Who writes

- the Producer's report worker: the triple of three fresh summaries and its complement
  material are the main core; archived dossier ideas — including the fragments deposited by
  stale reports, summaries and routes — may be used.
- the Producer archives reports properly with versions.

## Who reads

- the hygiene linter, before the examine worker. layer 1 is a deterministic
  mechanical pass (no AI): every citation resolves to a real source with a
  locator, every claim's proof is inline or present in the dossier, the locked
  names are used consistently, and numbers, brackets and constants are
  internally consistent. layer 2 produces the format (lock this name): every
  claim, lemma, theorem and proposition has a uniform structure — a precise
  statement, its assumptions explicitly listed, and its implications — and the
  linter groups them so that the decompose workers and the swarm workers in the
  Formalizer can easily process them. the linter never judges correctness. a
  report that does not pass the quick lint is stale: it does not move on, and
  the round produces no route from it.
- the examine worker (cap 8 min): it decides one thing only — is the material
  sufficient enough to become an approach? it never judges the correctness of
  the idea.
- the Formalizer: the input is verdict-aware. an examine-failed lint-passed
  report is copied to it immediately — its raw form is its final form. a
  successful report reaches the Formalizer only post-verdict, as an
  accepted/accepted-core route (full or core form) together with the promoter's
  nearest true version note. a rejected pair enriches the fragment region
  instead.
- the Creator: unsuccessful reports are sent back and processed in its second
  phase; they are marked stale with the failure reason, a revival trigger and
  their fragments (see protocol/stale/).

## Handoff

- a successful report is renamed a route (lock this name) with a title, to
  distinguish it from other routes; the worker who produced it remains and is
  called the PI (lock this name). the route moves to protocol/routes/.
