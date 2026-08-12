# verification-ledger.md — how claims become established

append-only and dated, one row per review round — history is preserved, never overwritten. the verdict column carries the reviewer's reasons, never the author's.

this file is the split-out verification-ledger section of the dossier (see the ~30 KB split rule and the Knowledge State navigation index in ./index.md). it is the project's record of the verification protocol.

## row format

| date | claim | status | reviewer | verdict & reasons | repair targets / notes |

## the review lifecycle

claimed → under-review → accepted | rejected | counterexample

- claimed — the author believes the result; recorded with the claim text and the location of its proof. nothing may build on it yet.
- under-review — handed to the independent review. still nothing may build on it.
- accepted — the independent review verified the claim *and* the proof. only now may later work treat it as established, and only now may it be reported as correct.
- rejected — the reviewer found a flaw; record the repair targets. the claim returns to the author as a repair task (an ordinary attempts-log entry), then goes back to review.
- counterexample — the claim is false as stated. either the statement was not what was wanted (fix the statement) or it is genuinely false (record it, learn from it, move on).

## the rules
- a claim in `claimed` or `under-review` is never used as a premise — not by later work, not in reporting to the user.
- the repair loop is bounded: at most two review rounds, then the claim is parked as `rejected` with its full history, and a fresh attack starts a new thread.
- the reviewer's verdict outranks the author's confidence: the author may repair and resubmit, may not overrule; if the author believes the reviewer erred, that objection is itself a new claim sent to an independent review.
- a rejection is not a failure entry (persistence rule R3): it is a normal recorded outcome, and in the project it becomes a stale-rule entry with fragments and a revival trigger.
- drafts are not reviewed: a proof is reviewed only in its final version, the one the author is prepared to call correct.
- what gets reviewed — every claimed result, not just the main goal: a theorem, proposition, lemma or corollary (its statement *and* its proof); a counterexample or refutation claimed against a statement; a reduction that later work rests on; a computation asserted as a fact inside a proof; a nonstandard definition whose well-definedness matters.

## independence — non-negotiables
the review must have: a fresh context (it has not seen the author's session, reasoning, false starts, or confidence); only the claim as stated, the proof text, the statements of the cited results (never their proofs), and the definitions used; a single question — *assuming the cited results are true, does this proof establish exactly this claim?*; a different agent/backend/model when the harness allows it (at minimum a fresh context window).
it must never receive: the expected outcome, "this should be right", the attempts log, the intuition, "the argument feels solid", or how the proof was discovered — those are the exact channels by which a verdict stops being independent.

## the reviewer's checklist (A–D)
- A — the claim: exactly what was intended — not weaker, not different; all hypotheses stated, with no hidden assumptions in the prose; all terms defined with the intended definitions; well-posed (objects exist, functions well-defined, limits make sense).
- B — the proof: every step follows from the results it cites, and only from them; the cited hypotheses hold at each point of use; no step silently assumes something unproved or unstated; the quantifiers match — a "for all" claim must cover all cases, and each case must be handled.
- C — the boundary: degenerate and edge cases (zero, empty, trivial, extremes, equality cases); check the smallest nontrivial case by direct computation where possible; hunt for a counterexample — to the claim, or to a single step.
- D — the verdict, with reasons: accepted (the proof establishes the claim, no blocking gaps) | rejected (with specific repair targets: the step, the missing hypothesis, the counterexample) | gaps found (non-blocking notes the author should still address).

## realized in this architecture
the lifecycle is realized as fresh summary → idea report → route → accepted route.
- the hygiene linter is the first gate: layer 1 (mechanical, ≈3 min) checks that every citation resolves to a real source with a locator, every claim's proof is inline or present in the dossier, the locked names are used consistently, and numbers, brackets and constants are internally consistent; layer 2 (≈7 min) produces the format — every claim, lemma, theorem and proposition with a uniform structure (a precise statement, its assumptions explicitly listed, and its implications), grouped so the Formalizer's decompose workers can split the claims into the decomposed fragments and plan the distribution to the swarm workers. it cuts failures; it never judges the correctness of the mathematics.
- the examine worker is the first independent review gate (cap 8 min): it judges one thing only — whether the material is sufficient enough to become an approach — never the correctness of the idea. when a report fails the examine, its source summaries are tagged with what was missing (the examine's sufficiency finding), so the next pairing deliberately fills the gap.
- the Selector's panel implements the checklist: workerA checks the high-level ideas and whether the evidences really support the claims (A); workerB checks inconsistencies and readability of the proofs (B); workerC hunts counterexamples (C); workerD (external) makes the overall judgement (D). the panel runs in the 63–103 window (workerA's evidence list by 78 min; B/C/D review, exchange reports 93–103, each writes a review summary). with two panels at a time, two exterior invocations are needed; any workerD falls back to an internal reviewer when the exterior reviewer (X) is unavailable or shares the primary's provider family, and the reduced diversity is recorded. independence is by construction: the panel workers receive the route and the statements of the cited results — never the expected outcome, never the author's reasoning — plus the scoped brief, in fresh contexts.
- the PI rebuts and modifies the route in the 103–118 window (15 min, change list + rebuttal); the promoter writes its nearest true version note in the same window. the BCD reviewers do not close after writing their summaries: they pause, wait for the PI's rebuttals, vote at the swarm stage, and only then close. the BCD reviewers are actively doubtful — each asks concrete questions about any doubtful aspect of the route (id'd `Q-B/C/D<n>`, in the raw report and the summary) and questions every statement that is non-trivial and not well clarified, including the rougher statements of early routes — and the PI answers every question in the change list when modifying the route; at the vote the BCD reviewers weigh the quality of the answers as an important point of the verdict.
- the swarm (3, odd) and the resumed BCD reviewers (20 min, keeping their panel context) decide in the 118–138 window. the route is accepted if and only if at least 2/3 of the swarm workers AND at least 2/3 of the BCD reviewers agree. the acceptance numbers rank the quality of an accepted route: full consensus (3/3 + 3/3) is the strongest; lower counts are accepted but weaker. the swarm's verdict, together with the BCD vote, outranks the PI's rebuttal — the PI may repair and resubmit, may not overrule.
- a milestone = all 3 swarm workers (3/3) + all 3 BCD reviewers (3/3) + the accepted routes together achieving the locked goal; then the Coordinator writes the manuscript (PDF).
- only an accepted route is presented to the user; everything before it — fresh summary, idea report, route under review — is never treated as established.
- a [Formalized] idea in the reliable idea set is an additional premise channel: it may be cited as established without further panel review and cannot be overturned by a later round. green lean codes are the only format in the reliable idea set. the goal node of the dependency tree is reachable from the established base — kernel axioms + Mathlib theorems + [Formalized] pieces — with `#print axioms goalTheorem` clean of non-kernel axioms when a green lean code connects it to an acceptable assumption.
- the canary gate is separate from this ledger: a seeded known-false claim and one planted step-error ride in the review batch (both excluded from the real record and the route); the route may not be accepted unless the panel catches the claim (≥80%) and the step-error (100%, with the step cited); the running detection rate is recorded in the Selector's archive.

## template rows — illustrations; real rows begin at round 1
| 2026-08-09 | <claim id>: <one-line statement> | claimed | — | — | proof location: <path>; nothing may build on it yet |
| 2026-08-09 | <claim id> | under-review | reviewer <id> | — | independent review, fresh context; receives only the claim, the proof, the cited statements and the definitions |
| 2026-08-09 | <claim id> | accepted | reviewer <id> | accepted — the proof establishes the claim; no blocking gaps | none |
| 2026-08-09 | <claim id> | rejected | reviewer <id> | rejected — step 3 assumes <H> without proof (checklist B) | repair target: step 3, add <H>; review round 1 of ≤2; repair task goes through the attempts log |
| 2026-08-09 | <claim id> | counterexample | reviewer <id> | counterexample: <exhibit> refutes the claim as stated (checklist C) | fix the statement, or record it and move on; becomes a stale entry with fragments |
