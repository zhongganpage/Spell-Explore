# Selector rules

The Selector is the third subcoordinator, third in the standard
sequence Creator → Producer → Selector. its territory is review and acceptance. this
file is the complete operating rule for the Selector: the panel, the canary gate, the
promoter, the PI rebuttal, the decision swarm, and the disposition of every route. an
agent asked to run the Selector, a panel worker, the promoter, or a swarm worker acts
on this file. the spec (planning-ideas-no-push.md) is authoritative; where this file is silent,
the spec governs.

## 1. the Selector's job

whenever the Producer has a fresh route, the Producer sends the route to the Selector.
the Selector:

- requests an adversarial review panel of four workers from the Coordinator to process
  the fresh route and make a
  report — see §2–§3;
- sends the three review summaries to the route's PI, who modifies the route, rebuts
  the report, and makes a change list — see §6;
- requests a fresh-context promoter worker from the Coordinator and runs, in parallel,
  its own decision swarm of 3 workers plus
  the resumed BCD reviewers, who decide accept, accept-core, or reject — see §7–§8;
- marks the route accepted (full or core form) / unaccepted in the archive; an
  accepted route is marked a new version by the Producer (the Producer owns that
  marking, the Selector records the verdict);
- an accepted route is presented to the user (with the decision list); an unaccepted
  route is sent back to the Creator for the second phase unless the user parks it — see
  §10.

as a subcoordinator the Selector regulates its own workers within its domain: it
monitors their status, enforces the time limits and the artifact rules, and solves
issues inside its territory, subject to the Coordinator. every worker it directs is
spawned by the Coordinator in the explicit background mode, never the blocking
foreground; the decision swarm is the Selector's own and is spawned by it in the
explicit background mode. the Selector
is resumable: it runs each review phase to completion in one run — waiting for every
worker's artifact before returning — and is resumed by the Coordinator for the next
phase; it never returns early, and a narrated step is not a done step.

## 2. two panels at a time

the Selector only runs two panels at a time. in rounds 1–3 the two panels run 63–103
(40 min), the two PI rebuttals run in parallel 103–118 (15 min), and the two decision
swarms run together in the same window 118–138 as background workers (20 min). from
round 4 the round is extended +10 min and the panels run 63–108 (45 min), the PI
rebuttals 108–126 (18 min), and the swarms 126–148 (22 min) — 85 min per review. a
third fresh route's review is carried to the next round.

carried-over work is handled first at the start of a round: the Selector resumes queued
route reviews. in rounds ≥ 2, when the Selector has unfinished work, the carried review
owns the critical path — its panel, PI rebuttal and swarm run in their windows first,
while the Creator's phase 1 and the Producer's report run in the background alongside.
a new route's review starts only if the remaining budget fits a full review (75 min in
rounds 1–3 — panel 40 + PI 15 + swarm 20; 85 min from round 4 — panel 45 + PI 18 +
swarm 22); otherwise the round closes with the carried verdict and the new report
queued. from round 4, a round with two named routes must run both panels regardless of
the remaining budget.

## 3. the adversarial review panel

each panel consists of four workers — workerA, workerB, workerC, workerD — with these
roles:

- **workerA** checks the high-level ideas and the claims towards the ultimate goal and
  finds the evidences of these ideas given in the route. its main focus is the
  evidences: whether they are really the evidence of the claim. it only identifies the
  important points that lead to the ultimate goal in the paper, and it does not
  criticize them. it makes a list and asks workerB and workerC to judge. workerA has 15
  minutes.
- **workerB** specializes on inconsistencies and readability issues in the route — for
  example some theorem proves something, but the proof is not explicitly presented,
  wrongly presented, or buried in the paper. once it receives the list of workerA, it
  focuses on the list.
- **workerC** specializes on counterexamples: whenever it sees a claim, it tries to
  find a counter-example. when it receives the list from workerA, it focuses on the
  list.
- **workerD** is external and makes the overall judgement (see the fallback rule
  below).

beyond these specializations, workerB, workerC and workerD are all actively doubtful:
each of them asks questions about any aspect of the route that raises doubt — a claim,
a proof step, an evidence, a definition, an assumption, an edge case, a citation, or
the link to the locked goal. asking is a duty of clarification, not only of suspicion:
a reviewer questions not just what raises a specific doubt, but every statement that is
non-trivial and not well clarified — a statement whose hypotheses, terms, definitions
or well-posedness are not made explicit — because the lack of clarification is itself
the doubt, and this includes the rougher statements of early rounds, which are
questioned like any other. a question is concrete and tied to the route (a specific
claim, step or evidence), carries a stable id (`Q-B<n>` / `Q-C<n>` / `Q-D<n>` by
reviewer), and is listed in the raw review report and repeated in the review summary.
asking is a duty: a reviewer that read the route and found no doubt says so explicitly
(`no doubts found`) rather than staying silent, and the PI must answer every question
raised (§6).

timing: in rounds 1–2 the panel runs 63–103 (40 min) — workerA lists the evidence
points by 78 min, workerB/C/D review from 63 min and pivot to workerA's list when it
arrives, and the exchange runs 93–103 min. in round 3 these windows shift +1 (panel
64–104, workerA list by 79, exchange 94–104, PI 104–119, swarm 119–139 —
rules/timekeeping.md §4). from round 4 the panel is extended to 45 min: base windows
63–108 (workerA by 83, exchange 98–108), shifting +1 for the Producer's summary choice
(panel 64–109, workerA by 84, exchange 99–109, PI 109–127, swarm 127–149 —
rules/timekeeping.md §4). a phase that reaches its window end is cut and its partial output recorded.

workerB, workerC and workerD have 30 minutes to run the review and write a raw review
report, and an additional 10 minutes to exchange the reports — each of the three
receives the reports of the other two — and each then writes a review summary. there are
three summaries, one per reviewer: workerB's summary on the
inconsistencies and readability issues (focused on workerA's list), workerC's summary
on the counterexamples found (focused on workerA's list), workerD's summary on the
overall judgement. per the panel contract: A's list feeds B's inconsistencies, C's
counterexamples, and D's overall judgement.

### workerD fallback rule

workerD is external when it runs through the configured exterior access —
`X_PROVIDER` / `X_MODEL` / `X_ACCESS` (a provider API env var, or the local Codex
CLI; see modules/providers.md) — chosen once at round 1, on a provider family that
differs from the primary's. the Coordinator invokes the exterior reviewer itself —
the api call or `codex exec` with the worker-d-external prompt — captures the reply
(delimited by standardized markers), persists it verbatim at the assigned path
marked recovered from agent output, and reports the model identifier the provider
actually returned; the Selector records it in the panel row — there is no silent
same-model panel. when the exterior access is unavailable (env var unset, codex
missing, the call fails) or shares the primary's provider family, workerD falls
back to an internal reviewer and the reduced diversity is recorded (in the archive,
with the panel record); a failed invocation is retried once within the window
before the fallback, and an exterior failure mid-run keeps the artifacts produced
up to the failure point — `never launched` is recorded as well. with two panels at
a time, two exterior invocations are needed, and each workerD passes the same check.

### artifact and context rules for the panel

the panel workers receive the route and the statements of the cited results — never the
expected outcome, never the author's reasoning — and each B/C/D reviewer additionally
receives the scoped brief of §3, in fresh contexts. the
panel's brief is scoped: each B/C/D reviewer receives the route, the statements of
the cited results, workerA's evidence-point list (when it is ready), the examine
worker's sufficiency verdict (when one exists), and one-line abstracts of the related
prior routes — never the full report body and never the full dossier index. a
reviewer that needs more pulls the specific file on demand (Read) only when a claim's
support is in question; the scoped brief is a cost rule, never a content rule —
nothing is skipped because it was not included. panel
B/C/D are read-only (Read/Grep, no write); workerD runs through the configured
exterior access when available (modules/providers.md — invoked by the Coordinator,
never spawned). every worker that produces an artifact is spawned by the Coordinator
with the explicit output path its subcoordinator assigns and must write its artifact
there and confirm the write in its final message. a
worker that cannot write — a read-only profile — includes the complete artifact text
in its final message; the exterior workerD's reply is captured from the api response
or codex stdout, delimited by standardized markers, and the Selector persists the
text verbatim at the assigned path, marked recovered from agent output. the Selector
checks that every artifact exists after each worker completes and never starts the
next phase or handoff on a missing artifact; documents move between stages only as
files. every review summary and every artifact carries a version (v1, v2, …);
nothing is cited or built on without its version.

## 4. the canary gate

canaries are per-route, authored by the Selector from a canary bank — plausible
known-false claims and step errors targeting the route's typical error patterns — and
ride in the review batch. before planting, the Selector verifies the seed is actually false by the same proof method the
reviewers will use — a seed that turns out sound is voided, recorded separately, and
never counts; optionally a second fresh context checks the seed's falsity before
planting. the review batch — canary included — is authored by the
Selector and relayed verbatim by the Coordinator to each panel worker; the Coordinator
never composes or edits it. the B/C/D panel is told the gate exists (announced), and its
detection is recorded as announced: the panel must catch the known-false claim (≥80%)
and the step-error (100%, with the step cited). a panel that fails the announced gate
produces no acceptance: the route under that panel cannot be accepted in that review,
regardless of the votes, and the failure is recorded with the panel record. the
decision swarm stage additionally carries an unannounced canary when one is available —
the swarm is not told — and its detection is recorded separately. both canaries are
excluded from the real record and from the route; the running detection rate is
recorded in the archive (per panel, per round). the canary material is a control, not a
verdict on the route: it is authored by the Selector, rides with the real review batch
so that the panel cannot distinguish it from the route's content, and is stripped from
the record and the route before anything downstream.

## 5. handoff to the PI

when the exchange is done, the Selector sends the three review summaries (of workerB,
workerC, workerD) to the PI of the route. the summaries, the raw review reports and the
panel report are versioned artifacts; the PI receives the three review summaries and the
route with its authoring context preserved — the PI is the report worker the Producer
directed the Coordinator to hold open (rules/worker-lifespans.md); fresh context is the
panel's and the promoter's
requirement, never the PI's — together with workerA's list when the summaries rely on
it. the summaries carry the reviewers' questions for the PI (the §3 questioning duty,
id'd `Q-B<n>` / `Q-C<n>` / `Q-D<n>`); the PI answers every one of them in §6.

## 6. the PI rebuttal and the change list

the PI has 15 minutes in rounds 1–3 (window 103–118; round 3 shifts +1 to 104–119),
18 minutes from round 4 (window 108–126). the PI modifies the route and rebuts the
report, and makes a change list. the change list is a versioned artifact that states,
point by point, which review summary findings were accepted and repaired in the
modified route, which were rebutted and why, and which remain open. the change list
answers every question the reviewers raised (the §3 questioning duty, `Q-B<n>` /
`Q-C<n>` / `Q-D<n>`): each question gets one of three statuses — `repaired` (the answer
is embodied in the modified route, with the section and route version cited),
`rebutted` (the doubt is answered with a justification), or `open` (left unresolved
with a stated reason — an explicit negative at the vote). the PI answers the questions
when modifying the route: a question whose answer changes the route must be resolved
in the modified route itself, not in prose alone. the modified route
is a new version of the route; the change list cites the review summaries and the route
versions it responds to. the PI may repair and resubmit (change list + rebuttal) but may
not overrule: the reviewers' verdicts outrank the PI's confidence, and if the PI
believes a reviewer erred, that objection is itself a new claim and follows the
verification protocol — it is not a way to set the vote aside.

## 7. the promoter

a fresh-context promoter worker has the duty to promote the route. it works during
103–118 min in rounds 1–3 (round 3 shifts +1 to 104–119), and during 108–126 min from
round 4, at the same time as the PI, reading the route and the three review summaries
and writing a nearest true version note — the strongest claim the route can honestly
make, and the exact point where it breaks. the note is a high-level check the reviewers
and the swarm refer to: whether the route over-claims, and the strongest true version
its material supports. the note is given to the swarm together with the PI's rebuttal.
the core may be accepted in reduced form, grounded in the route's material: when the
double gate votes accept-core, the core becomes the accepted route, versioned, with
its own title, and its abstract enters question-routes.md. the promoter is
read-only for the note duty (Read/Grep; it gains Edit only for the connection
marking of §7.1), runs in a fresh context, and is held paused across the PI window
by the Coordinator on the Selector's instruction — it is resumed (resume-by-ID,
context preserved) for the connection marking of §7.1 and closes only after that
second duty; its note is a versioned artifact
written at an assigned output path (recovered from agent output if the promoter
cannot write). if the route is rejected, the note also enriches the fragments sent
to the Creator's second phase.

### 7.1 the promoter's connection marking (118–138 in rounds 1–3, 126–148 from round 4, parallel to the swarm and the BCD vote)

the promoter has a second duty in the 118–138 window in rounds 1–3 and the 126–148
window from round 4, at the same time as the decision
swarm and the resumed BCD vote. the promoter IS resumed in this period: it is held
paused across the PI window (like workerB and workerC — see rules/worker-lifespans.md),
so the Selector instructs the Coordinator to resume it (resume-by-ID, context preserved)
for the connection marking — one resume per route under
review. the marking promoter reads the revised route (the PI's modified route), the
change list, and the BCD review reports (the raw review reports and the three review
summaries of workerB, workerC and workerD), then inspects the single qmd file —
formalizer/single.qmd, with its id list formalizer/qmd-index.md. whenever it thinks
the route's results or some techniques in the results can be used to show a proof from
one statement to another in the single qmd file — the initial statement X implies the
statement Y — it marks the initial statement `[<route ID>-T-<the id of the implied
statement in single.qmd>]` and marks the implied statement `[<route ID>-F-<the id of
the initial statement in single.qmd>]`, writing the marks as qmd annotation lines
placed at the marked blocks. route ID = the route's title (the locked name that
distinguishes the route from every other route; the connection report carries the
version). the promoter may use some of the qmd features: the `@id` pointer syntax and
the annotation-comment convention, and it may run qmd-prover's mechanical check on
single.qmd to verify the file stays valid. the marks are annotations (provenance),
never content — they never change a block's statement — and they survive the lean code
runner's merges (the merge appends per-fragment pieces ordered by fragment id and
never removes locked content; rules/formalizer.md). the marking is verdict-independent:
it runs for every route under review, whatever the vote. the Selector verifies the
written marks by file, and the promoter's final message is the connection report — a
versioned artifact per the connection-marks template, listing every mark with its
one-line justification and its T-mark proof field — persisted verbatim at the assigned
output path (recovered from agent output, as for the note). post-verdict the report rides the handoff: for an
accepted or accepted-core route it goes to the Formalizer together with the accepted
route and the note, as scoping metadata — which existing statements the route's
results or techniques bridge; for a rejected route its connection entries enrich the
stale entry's fragments. every T (initial) mark carries a proof field in one of
three states: `route-ref:<claim-id>` — the implication is already a claim in the
revised route, no new argument needed; `full-argument` — a complete argument written
inline, using only claims already in the revised route, so the swarm can transcribe it
mechanically; `open` — no complete argument, the gap is recorded for the PI and the
mark stays annotation-only. F (implied) marks carry one line of reason only, no proof
field, and the open gaps are recorded in a dedicated open-gaps subsection of the
report. the marks stay in single.qmd either way, and the decompose worker
mirrors them into the connections section of qmd-index.md at its merge, so
the Creator's phase-2 workers are notified of the connection by the ids and may use
ideas from the route.

**the marking is an enforced deliverable.** the Selector's re-invocation request and
spawn brief for the marking promoter carry the marking instruction explicitly — the
brief names duty 2 (this §7.1) and the connection report as the deliverable, and
requires the promoter to confirm the annotation count in its final message; the
nearest-true-version brief of §7 never substitutes for it, and a re-invocation brief
that is note-only is a protocol violation. the connection-marking report is a REQUIRED
deliverable of the Selector's close checklist, like the verdict and the panel record:
before it closes, the Selector verifies by file that the marks exist in
formalizer/single.qmd and the report exists at the assigned output path with its
proof fields (L-B, §11) for every route under review; a Selector that cannot close
with the report — missing or proof-field-invalid — hands the re-invocation to the
Coordinator as a pending item — recorded in its resume pack and the round-close
record — instead of closing "complete" without it (§12).

## 8. the decision swarm and the resumed BCD vote

at 118–138 in rounds 1–3 (126–148 from round 4), the Selector runs its own swarm of
3 (odd number) workers to review the panel, the original route, the modified route
and the rebuttals, and judge the route itself — its claims, proofs and evidences —
referring to the promoter's nearest true version note as a high-level check on the
route's claims: whether the route over-claims, and the strongest true version its
material supports. the swarm then votes accept, accept-core, or reject — acceptance
needs 2/3 of the swarm, 2 of 3 workers, to vote accept, and the BCD gate must clear
the same bar (§9). the swarm has 20 minutes in rounds 1–3 and 22 minutes from round 4
to make a decision.

in the same window (118–138 rounds 1–3, 126–148 from round 4) the Selector re-invokes
the promoter in a fresh context
for the connection marking of §7.1 — the promoter reads the revised route, the change
list and the BCD review reports, inspects the single qmd file, and marks every
statement-pair the route's results or techniques bridge, so the vote runs in parallel
with the marking and neither waits for the other.

every rejecting vote names the load-bearing obstruction — the single missing lemma,
false step, or unproved claim whose absence makes the route fail.

at the same stage the Selector instructs the Coordinator to resume workerB and workerC — they keep their panel context
and also have 20 minutes in rounds 1–3 and 22 minutes from round 4 — and to re-invoke workerD externally with a consolidated
vote prompt (the route, D's own raw report and review summary, the PI's rebuttal and
change list, and the promoter's nearest true version note — the modules/providers.md
access, reply captured as before), and they vote as well. when the BCD reviewers vote, the quality of the PI's answers to their questions is an important point of the verdict: each reviewer evaluates, for every question it raised, whether the answer resolves the doubt — by repair in the modified route or by a sound rebuttal — or leaves it hanging. a weak, evasive or missing answer to a material question (one whose answer determines whether the route establishes its claim) is treated like a blocking gap: it forbids that reviewer's accept vote and is recorded with the vote; questions resolved by repair or sound rebuttal support the accept vote. the answer-quality assessment is part of each BCD vote's reasons. workerB and workerC do not
close after writing their summaries: they pause to wait for the PI's rebuttals, vote
at the swarm stage, and only then close. the Selector directs the Coordinator to hold
workerB and workerC paused, with their
panel context, across the PI rebuttal window — they are resumed for the vote, not
re-created, because a fresh reviewer would lack the panel context. workerD is not
held across the window: its context is reconstructed from files — the Coordinator
re-invokes it externally with the consolidated prompt, retries a lost vote invocation
once within the window, then records the vote as absent with the reason. a phase that reaches
its window end is cut and its partial
output recorded; the round closes atomically at 138 min in rounds 1–2, 139 min in round 3, and 149 min
from round 4 (148-min base + the Producer's 1-minute summary choice persisting from
round 3) even if a phase is mid-flight.

## 9. acceptance, milestone, and quality ranking

the decision is three-way: accept, accept-core, or reject. a route is accepted when
at least 2/3 of the swarm workers and at least 2/3 of the BCD reviewers vote accept;
it is accepted in reduced form when at least 2/3 of the swarm workers and at least
2/3 of the BCD reviewers vote accept-core and it is not already accepted; otherwise
it is rejected. the verdict levels are ordered: 3/3 accept > (2/3 accept = 3/3 accept-core) > 2/3
accept-core > reject — a unanimous accept-core weighs the same as a two-of-three
accept. when both gates clear ≥2/3 on accept-or-better but at different levels, the
weaker common level is the verdict — e.g. the swarm votes 2/3 accept while the BCD
reviewers vote 3/3 accept-core, equal tiers, so the weaker common verdict
(accept-core) wins — and the split is recorded with the verdict; that accept-core
outcome only when the route is not already accepted: for a revision of an
already-accepted route the route stays accepted and the split is recorded. every
other combination — a gate below 2/3 accept-or-better, or a reject — makes the route
rejected: it goes stale. an accepted-core route
is the promoter's salvageable core, grounded
in the route's material (surfaced by the promoter's high-level check, verified by the
double gate) and verified as a genuine, correctly-proven contribution: the core
becomes the accepted route, versioned, with its own title, and its abstract enters
question-routes.md. this
acceptance rule is fixed; the Coordinator's measurements feed the workers' rigor,
never the votes. the acceptance numbers rank the quality of an accepted
route: full consensus (3/3 + 3/3) is the strongest, lower counts are accepted but
weaker — 3/3 is the maximum a gate clears. the quality ranking is recorded with the
verdict in the archive, and the decision list shows it with the route's abstract.

the project reaches a milestone only if all 3 swarm workers and all 3 BCD reviewers
accept — 3/3 + 3/3 — and the accepted routes together achieve the locked goal. a
milestone is a Coordinator matter: the Selector reports the counts and the verdicts;
the Coordinator verifies the goal and writes the manuscript as a PDF.

### same-title serialization

no two reviews of the same route title run concurrently — a challenge to an older
version and a review of a revision of the same title never share a panel window. when
a challenge to an older version is in review and a revision of the same title is
accepted, the in-flight review runs to completion first — the old PI defends the older
version — and only then does the handover to the revision happen.

## 10. disposition of routes

the Selector marks the routes accepted / unaccepted in the archive. an accepted route is
presented to the user before it is marked a new version: the round close carries the
decision list, which covers the abstracts of the accepted routes and, for each
unaccepted route, the choice recycle / park. an accepted-core route is also presented
to the user with the decision list, its abstract (the core's) entering
question-routes.md. the user decides on each unaccepted route: recycle it back to the
Creator, or park it (the fragments are kept but it is not auto-recycled). unless the
user parks it, an unaccepted route is sent back to the Creator for the second phase.

after the verdict, the Selector sends the accepted route — full form (the PI's modified
route) or core form (the accepted salvageable core) — together with the promoter's
nearest true version note to the Formalizer, the note as scoping metadata, and with
the promoter's connection report (§7.1) — which existing statements in the single qmd
file the route's results or techniques bridge; a rejected route's pair enriches the
fragment region instead, and its connection entries join the stale entry's fragments.

on the Coordinator's instruction the Selector also executes the stale marking of an accepted route whose formalization failed — the accepted-route watch of rules/formalizer.md, the Formalizer's stale signal: two consecutive lean-runner batches with no green [acceptedR] piece — using the same mechanics as an unaccepted route: the stale entry per the stale-entry template (source item `route <title> v<n>`; failure reason `formalization failed — none of the accepted route's lean codes is green after two consecutive lean-runner batches (killed by evidence: lean)`; revival trigger; fragments), the fragments archived in the fragment region; the Coordinator handles the question-routes superseding and the PI retirement. when the Selector is mid-panel or in a window, the Coordinator spawns a dedicated stale-worker for the marking instead, so the demotion completes by the end of the round. every unaccepted route is marked stale, and the stale marking records three things: the
failure reason (the panel findings that rejected it, including the load-bearing
obstruction named by the rejecting votes), a revival trigger (re-examine
when <event>), and the fragments of the work — the sub-results that still hold, the
obstruction, and the closest technique; the load-bearing obstructions named by the
rejecting votes are aggregated into the obstructions register (dossier/index.md). when the route is rejected, the promoter's note
and its connection report
enrich the fragments. the fragments are archived in the fragment region of the idea
pool in the dossier, so the Producer's report worker can use them like
any other idea in the dossier, and the Creator's second phase mines them directly. a
round may deliver no accepted route: in that case the round delivers the round-close
record with the decision list.

## 11. the mechanical linters (L-A, L-B)

before the handoff to the Formalizer, at the Selector close, the Selector runs two
mechanical linters on the artifacts it hands over. L-A — the accepted route plus the
PI's change list: every change-list item lands in the route (the ids exist and the
numbering is consistent), the claim structure is uniform, the citations and the locked
names are consistent, and the symbols conform to the symbol list
(formalizer/symbol-list.md — the symbols as defined there, `proposed` symbols
accepted, not violations). L-B — the connection report: the T/F pairs are complete,
both ids exist in the route, each proof field is one of the three states and valid
(`route-ref` resolves to a claim in the route, `full-argument` cites only route
claims, `open` is recorded in the open-gaps subsection), and the report is
cross-checked against the route. both are deterministic mechanical checks — no new
subagent, no AI judgment: the Selector runs them itself, or its own workers per the
existing gate pattern. a failing artifact stays at the Selector — a failing report
goes back to the promoter, a failing route back to its writer (the PI) — and the
failure is recorded pending like the other per-close decisions, non-blocking for the
next round's start.

## 12. the round close and the Selector's records

every round ends with a single atomic round close written in one pass: the fresh
routes, the verdicts, and the stale list with their fragments, together with a
phase-time table. the Selector contributes the verdicts and the stale entries for the
routes it reviewed, and its phase start/end timestamps are recorded at each boundary in
the phase-time table; timestamps are never reconstructed after the fact. the Selector's
running records — the panel records (with the workerD fallback notes), the canary
detection rates, the acceptance numbers, the quality ranking, and the promoter's
connection reports — are kept in the archive as versioned artifacts.

at the round close the Selector closes once its reviews and verdicts are recorded and
the connection-marking reports are verified by file with their proof fields (L-B, §11)
for every route under review (§7.1 — the report is a REQUIRED close deliverable, like
the verdict and the panel record); a close without a complete marking report — missing
or proof-field-invalid — records the pending re-invocation for the Coordinator, never
"complete" without it; the two mechanical linters of §11 run before the handoff to the
Formalizer, and a failing artifact stays at the Selector, recorded pending like the
other per-close decisions — non-blocking for the next round's start; the next round
spawns it fresh from its resume pack — never resume-by-ID across rounds (rules/coordinator.md §3,
the round-boundary bounded context). resume-by-ID stays the within-round fast path: the
phase-to-phase resumption (raw reports → exchange → swarm) and the held B/C/D panel pause across
the PI window.
