# integration report — template

the integration report is the Integrator's chain/atlas report: the graph-like structure built from `formalizer/Integrator/ITG.lean`, with div-id node identity, that replaces `dependency-graph.json` as the milestone source. it is kept consistent with `ITG.lean` — the Integrator checks the report against `ITG.lean` before the implementation/merge step. this file is the template the Integrator fills in; the filled file becomes the artifact at `formalizer/Integrator/integration-report.md`, versioned (v1, v2, …), and rewritten as the integration grows.

## who, when, where

- produced by: the Integrator, each round, from `formalizer/Integrator/ITG.lean`; it rewrites the report whenever a connection proof is merged into `ITG.lean` and greened.
- inputs: `ITG.lean` (the merged integration working lean file), the `#print axioms` footprints of the green proofs, and the hired set the hire test computed.
- where it lives: `formalizer/Integrator/integration-report.md`, versioned (v1, v2, …).
- read by: the Coordinator at the milestone check (the goal node reachable from the established base), and the Formalizer for the merge queue.

## the format

### nodes

`<div-id> — <class: kernel | mathlib | formalized | axiom | goal> — <status: formalized | hired | axiom | base | goal> — <lean declaration name (attribute, updated on rename — never the node id)>`

### edges

`<from div-id> → <to div-id> — <source: lean-axioms | proves>` · the `proves` edge class is the green connection proof (`X → Y via <route> v<n>`).

### hired set

`[Hired] <div-id> — <the established nodes that imply it> — <#print axioms footprint>` — `[Hired]` appears only in `ITG.lean`, never `single.lean`.

### distance to the established base

`goal node <div-id> — distance to the established base: <k> (kernel + mathlib + formalized)`

### proved connection pairs

`<X div-id> → <Y div-id> via <route> v<n> — <proof state: green | non-green>` — mirrored in `formalizer/connection-proofs.md`.

## rules that bind this artifact

- the report is the milestone source: the goal node is reachable from the established base (kernel + mathlib + formalized), `#print axioms goalTheorem` contains no non-kernel axiom, and a full manuscript claim requires the hired set empty and the reachability proven in Lean. `dependency-graph.json` is retired as the workflow source.
- graphify on `ITG.lean`, if produced, is visualization-only and never joins the workflow.
- the report is kept consistent with `ITG.lean`: the Integrator checks consistency before the implementation/merge step, and never cites a node or edge the report does not carry with its version.
- everything is versioned (v1, v2, …); nothing is cited or built on without its version.
