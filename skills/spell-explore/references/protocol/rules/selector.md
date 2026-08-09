# Selector rules

The Selector is the third subcoordinator, third in the standard
sequence Creator → Producer → Selector. its territory is review and acceptance. this
file is the complete operating rule for the Selector: the panel, the canary gate, the
promoter, the PI rebuttal, the decision swarm, and the disposition of every route. an
agent asked to run the Selector, a panel worker, the promoter, or a swarm worker acts
on this file. the spec (planning-idea.md) is authoritative; where this file is silent,
the spec governs.

## 1. the Selector's job

whenever the Producer has a fresh route, the Producer sends the route to the Selector.
the Selector:

- runs a multi-worker adversarial review panel to process the fresh route and make a
  report — see §2–§3;
- sends the three review summaries to the route's PI, who modifies the route, rebuts
  the report, and makes a change list — see §6;
- runs, in parallel, the promoter worker and then a decision swarm of ~9 workers plus
  the resumed BCD reviewers, who decide accept, accept-core, or reject — see §7–§8;
- marks the route accepted (full or core form) / unaccepted in the archive; an
  accepted route is marked a new version by the Producer (the Producer owns that
  marking, the Selector records the verdict);
- an accepted route is presented to the user (with the decision list); an unaccepted
  route is sent back to the Creator for the second phase unless the user parks it — see
  §10.

as a subcoordinator the Selector regulates its own workers within its domain: it
monitors their status, enforces the time limits and the artifact rules, and solves
issues inside its territory, subject to the Coordinator. every worker it spawns is
spawned in the explicit background mode, never the blocking foreground. the Selector
is resumable: it runs each review phase to completion in one run — waiting for every
worker's artifact before returning — and is resumed by the Coordinator for the next
phase; it never returns early, and a narrated step is not a done step.

## 2. two panels at a time

the Selector only runs two panels at a time. in a normal round two route reviews fit:
the two panels run 58–98, the two PI rebuttals run in parallel 98–113, and the two
decision swarms run together in the same window 113–133 as background workers. a third
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

timing within the 58–98 window: workerA lists the evidence points by 73 min; workerB/C/D
review from 58 min, and pivot to workerA's list when it arrives; the exchange runs 88–98
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

with two panels at a time, two external reviewers are needed. if only one is available,
the second panel's workerD falls back to an internal reviewer, and the reduced diversity
is recorded (in the archive, with the panel record).

### artifact and context rules for the panel

the panel workers receive the route and the statements of the cited results only, in
fresh contexts — never the expected outcome and never the author's reasoning. panel
B/C/D are read-only (Read/Grep, no write); workerD runs on an external provider when
available. every worker that produces an artifact is spawned with an explicit output
path and must write its artifact there and confirm the write in its final message. a
worker that cannot write — a read-only profile, or the external workerD — includes the
complete artifact text in its final message, and the Selector persists that text
verbatim at the assigned path, marked recovered from agent output. the Selector checks
that every artifact exists after each worker completes and never starts the next phase
or handoff on a missing artifact; documents move between stages only as files. every
review summary and every artifact carries a version (v1, v2, …); nothing is cited or
built on without its version.

## 4. the canary gate

each panel carries a canary gate: a seeded known-false claim and one planted step-error
ride in the review batch. both are excluded from the real record and from the route.
the route may not be accepted unless the panel catches the claim (≥80%) and the
step-error (100%, with the step cited). the running detection rate is recorded in the
archive (per panel, per round). a panel that fails the gate produces no acceptance: the
route under that panel cannot be accepted in that review, regardless of the votes, and
the failure is recorded with the panel record. the canary material is a control, not a
verdict on the route: it is seeded by the Selector, rides with the real review batch so
that the panel cannot distinguish it from the route's content, and is stripped from the
record and the route before anything downstream.

## 5. handoff to the PI

when the exchange is done, the Selector sends the three review summaries (of workerB,
workerC, workerD) to the PI of the route. the summaries, the raw review reports and the
panel report are versioned artifacts; the PI receives the summaries and the route, in
fresh context, together with workerA's list when the summaries rely on it.

## 6. the PI rebuttal and the change list

the PI has 15 minutes, the window 98–113. the PI modifies the route and rebuts the
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
98–113 min, at the same time as the PI, reading the route and the three review summaries
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

at 113–133, the Selector runs a swarm of ~9 (odd number) workers to review the panel,
the original route, the modified route and the rebuttals, and judge the route itself —
its claims, proofs and evidences — referring to the promoter's nearest true version
note as a high-level check on the route's claims: whether the route over-claims, and
the strongest true version its material supports. the swarm then votes accept,
accept-core, or reject. the swarm has 20 minutes to make a decision.

every rejecting vote names the load-bearing obstruction — the single missing lemma,
false step, or unproved claim whose absence makes the route fail.

at the same stage the Selector resumes the BCD reviewers — they keep their panel context
and also have 20 minutes — and they vote as well. the BCD reviewers do not close after
writing their summaries: they pause to wait for the PI's rebuttals, vote at the swarm
stage, and only then close. the Selector holds the BCD reviewers paused, with their
panel context, across the PI rebuttal window — they are resumed for the vote, not
re-created, because a fresh reviewer would lack the panel context. a phase that reaches
its window end is cut and its partial
output recorded; the round closes atomically at 133 min even if a phase is mid-flight.

## 9. acceptance, milestone, and quality ranking

the decision is three-way: accept, accept-core, or reject. a route is accepted when
at least 2/3 of the swarm workers and at least 2/3 of the BCD reviewers vote accept;
it is accepted in reduced form when at least 2/3 of the swarm workers and at least
2/3 of the BCD reviewers vote accept-core and it is not already accepted; otherwise
it is rejected. an accepted-core route is the promoter's salvageable core, grounded
in the route's material (surfaced by the promoter's high-level check, verified by the
double gate) and verified as a genuine, correctly-proven contribution: the core
becomes the accepted route, versioned, with its own title, and its abstract enters
question-routes.md. this
acceptance rule is fixed; the Coordinator's measurements feed the workers' rigor,
never the votes. the acceptance numbers rank the quality of an accepted
route: full consensus (9/9 + 3/3) is the strongest, lower counts are accepted but
weaker. the quality ranking is recorded with the verdict in the archive, and the
decision list shows it with the route's abstract.

the project reaches a milestone only if all 9 swarm workers and all 3 BCD reviewers
accept, and the accepted routes together achieve the locked goal. a milestone is a
Coordinator matter: the Selector reports the counts and the verdicts; the Coordinator
verifies the goal and writes the manuscript as a PDF.

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
obstruction, and the closest technique. when the route is rejected, the promoter's note
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
