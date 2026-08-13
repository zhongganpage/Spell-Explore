# symbol list — template

the symbol list is the Formalizer's canonical symbol registry, written by the lean code
runner from this template once `formalizer/lean/single.lean` holds more than 10 lean codes:
every symbol with its precise definition, centralizing the per-fragment "Mathlib bridge" notes
into one list the whole project shares, with the rename log (old → new) of the pure renames
the runner applies when it unifies the symbols. this file is the template the runner fills in;
the filled file becomes the artifact at `formalizer/symbol-list.md`, and the runner rewrites it
as the list grows. the symbol list is a Formalizer artifact: everything in it is versioned
(v1, v2, …), and nothing is cited or built on without its version. single.lean is a
dictionary — no [Hired] here: [Hired] lives only in ITG.lean.

## who, when, where

- produced by: the lean code runner, at a resumption, once `formalizer/lean/single.lean` holds
  more than 10 lean codes; it rewrites the list whenever a symbol is added, renamed or
  proposed.
- inputs: the single lean file (`formalizer/lean/single.lean`), the per-fragment lean pieces
  under `formalizer/fragments/<fragment-id>/` (their "Mathlib bridge" notes), and the pieces
  the workers filed carrying their new-symbol definition comments.
- where it lives: `formalizer/symbol-list.md`, versioned (v1, v2, …).
- read by: all the other workers — idea workers, writers, reviewers, decompose, swarm — which
  use the symbols as defined in the list and propose new symbols when they need one.

## the format

### symbols

`<symbol> — <its precise definition, one line>`

### proposed symbols

`proposed: <symbol> — <the definition comment the proposing worker carried in its piece>`

the linters accept `proposed` symbols — they are not violations — and the runner promotes them
into the symbols section at its next resumption when it takes them in.

### rename log

`<old symbol> → <new symbol> — <the version of the sync'd artifacts: the green archive in the
reliable idea set, axioms-<piece>.txt, the 1:1 registry>`

## rules that bind this artifact

- every symbol the project uses is in this list with its precise definition; a worker that
  needs a symbol not in the list proposes it, carrying the definition comment in its piece,
  and the runner adds it to the list at its next resumption — the intake is never done by the
  proposing worker.
- a rename is a pure rename: atomic, compile-verified, and rolled back on failure — it never
  changes the mathematics, and a green piece stays green. the rename log (old → new) lives
  here, and a rename syncs the green archive in the reliable idea set (the [Formalized] lean
  copies), `axioms-<piece>.txt` and the 1:1 correspondence registry —
  all updated together, each with a version bump.
- model merging (two pieces modelling one object) is NOT a rename: it is mathematics and goes
  through the route pipeline, never the runner.
- everything is versioned (v1, v2, …); nothing is cited or built on without its version.
