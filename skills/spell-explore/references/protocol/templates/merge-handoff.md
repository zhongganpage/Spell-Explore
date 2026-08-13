# merge handoff — template

the merge handoff is the D-QUEUE artifact the Integrator writes to hand its green connection proofs to the Formalizer's merge queue. it travels with a `runtime/requests/` request — a file pointer, never inline text — so the Coordinator brokers the handoff as a spawn request in the locked format. this file is the template the Integrator fills in; the filled file is versioned (v1, v2, …).

## who, when, where

- produced by: the Integrator, after the integration step, when it has green connection proofs to hand to the Formalizer's merge queue.
- inputs: `formalizer/Integrator/ITG.lean` (the green connection proofs), and the proved connection pairs in `formalizer/Integrator/integration-report.md`.
- where it lives: `formalizer/Integrator/merge-handoff-<round>-<seq>.md`, versioned (v1, v2, …); a pointer to it is filed as a `runtime/requests/` request (requester: `i`, kind: spawn or resume as the Formalizer directs).
- read by: the Formalizer (the merge queue), which consumes the green connection proofs and integrates them into the single qmd merge.

## the format

### green connection proofs

`<X div-id> → <Y div-id> via <route> v<n> — proof code in `ITG.lean` — green` · each proof carries its `#print axioms` footprint.

### hired marks

`[Hired] <div-id>` — established in `ITG.lean`, never `single.lean`.

### pointers

- integration working file: `formalizer/Integrator/ITG.lean`
- report: `formalizer/Integrator/integration-report.md`
- connection-proofs registry: `formalizer/connection-proofs.md`
- hireable registry: `formalizer/hireable-registry.md`

## rules that bind this artifact

- the handoff never carries inline proof text — it names the files and the proved pairs; the Formalizer reads the files.
- the merge rules of rules/integrator.md — merge rules (binding) bind the handoff: `single-int` content is immutable, green→non-green reverts, and consistency is checked before the merge.
- everything is versioned (v1, v2, …); nothing is cited or built on without its version.
