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

the Selector only runs two panels at a time. in a normal round two route reviews fit:
the two panels run 63–103, the two PI rebuttals run in parallel 103–118, and the two
decision swarms run together in the same window 118–138 as background workers. a third
fresh route's review is carried to the next round.

carried-over work is handled first at the start of a round: the Selector resumes queued
route reviews. in rounds ≥ 2, when the Selector has unfinished work, the carried review
owns the critical path — its panel, PI rebuttal and swarm run in their windows first,
while the Creator's phase 1 and the Producer's report run in the background alongside.
a new route's review starts only if the remaining budget fits a full review (75 min:
panel 40 + PI 15 + swarm 20); otherwise the round closes with the carried verdict and
the new report queued.

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

timing within the 63–103 window: workerA lists the evidence points by 78 min; workerB/C/D
review from 63 min, and pivot to workerA's list when it arrives; the exchange runs 93–103
min. a phase that reaches its window end is cut and its partial output recorded.

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

the panel workers receive the route and the statements of the cited results only, in
fresh contexts — never the expected outcome and never the author's reasoning. panel
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
it.

## 6. the PI rebuttal and the change list

the PI has 15 minutes, the window 103–118. the PI modifies the route and rebuts the
report, and makes a change list. the change list is a versioned artifact that states,
point by point, which review summary findings were accepted and repaired in the
modified route, which were rebutted and why, and which remain open. the modified route
is a new version of the route; the change list cites the review summaries and the route
versions it responds to. the PI may repair and resubmit (change list + rebuttal) but may
not overrule: the reviewers' verdicts outrank the PI's confidence, and if the PI
believes a reviewer erred, that objection is itself a new claim and follows the
verification protocol — it is not a way to set the vote aside.

## 7. the promoter

a fresh-context promoter worker has the duty to promote the route. it works during
103–118 min, at the same time as the PI, reading the route and the three review summaries
and writing a nearest true version note — the strongest claim the route can honestly
make, and the exact point where it breaks. the note is a high-level check the reviewers
and the swarm refer to: whether the route over-claims, and the strongest true version
its material supports. the note is given to the swarm together with the PI's rebuttal.
the core may be accepted in reduced form, grounded in the route's material: when the
double gate votes accept-core, the core becomes the accepted route, versioned, with
its own title, and its abstract enters question-routes.md. the promoter is
read-only (Read/Grep) and runs in a fresh context; its note is a versioned artifact
written at an assigned output path (recovered from agent output if the promoter
cannot write). if the route is rejected, the note also enriches the fragments sent
to the Creator's second phase.

## 8. the decision swarm and the resumed BCD vote

at 118–138, the Selector runs its own swarm of 3 (odd number) workers to review the panel,
the original route, the modified route and the rebuttals, and judge the route itself —
its claims, proofs and evidences — referring to the promoter's nearest true version
note as a high-level check on the route's claims: whether the route over-claims, and
the strongest true version its material supports. the swarm then votes accept,
accept-core, or reject — acceptance needs 2/3 of the swarm, 2 of 3 workers, to vote accept, and the BCD gate must clear the same bar (§9). the swarm has 20 minutes to make a decision.

every rejecting vote names the load-bearing obstruction — the single missing lemma,
false step, or unproved claim whose absence makes the route fail.

at the same stage the Selector instructs the Coordinator to resume workerB and workerC — they keep their panel context
and also have 20 minutes — and to re-invoke workerD externally with a consolidated
vote prompt (the route, D's own raw report and review summary, the PI's rebuttal and
change list, and the promoter's nearest true version note — the modules/providers.md
access, reply captured as before), and they vote as well. workerB and workerC do not
close after writing their summaries: they pause to wait for the PI's rebuttals, vote
at the swarm stage, and only then close. the Selector directs the Coordinator to hold
workerB and workerC paused, with their
panel context, across the PI rebuttal window — they are resumed for the vote, not
re-created, because a fresh reviewer would lack the panel context. workerD is not
held across the window: its context is reconstructed from files — the Coordinator
re-invokes it externally with the consolidated prompt, retries a lost vote invocation
once within the window, then records the vote as absent with the reason. a phase that reaches
its window end is cut and its partial
output recorded; the round closes atomically at 138 min even if a phase is mid-flight.

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
nearest true version note to the Formalizer, the note as scoping metadata; a rejected
route's pair enriches the fragment region instead.

every unaccepted route is marked stale, and the stale marking records three things: the
failure reason (the panel findings that rejected it, including the load-bearing
obstruction named by the rejecting votes), a revival trigger (re-examine
when <event>), and the fragments of the work — the sub-results that still hold, the
obstruction, and the closest technique; the load-bearing obstructions named by the
rejecting votes are aggregated into the obstructions register (dossier/index.md). when
the route is rejected, the promoter's note
enriches the fragments. the fragments are archived in the fragment region of the idea
pool in the dossier, so the Producer's report worker can use them like
any other idea in the dossier, and the Creator's second phase mines them directly. a
round may deliver no accepted route: in that case the round delivers the round-close
record with the decision list.

## 11. the round close and the Selector's records

every round ends with a single atomic round close written in one pass: the fresh
routes, the verdicts, and the stale list with their fragments, together with a
phase-time table. the Selector contributes the verdicts and the stale entries for the
routes it reviewed, and its phase start/end timestamps are recorded at each boundary in
the phase-time table; timestamps are never reconstructed after the fact. the Selector's
running records — the panel records (with the workerD fallback notes), the canary
detection rates, the acceptance numbers, and the quality ranking — are kept in the
archive as versioned artifacts.
