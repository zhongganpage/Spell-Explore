# validation drills — protocol/tests/

runnable checklist of the construction-plan §6 validation drills, one line per
drill. run each drill, record the outcome in the last column.

| drill | how to run | recorded outcome |
|---|---|---|
| config parse | `python -c "import tomllib,pathlib; tomllib.loads(pathlib.Path('~/.kimi-code/config.toml').expanduser().read_bytes())"` — also parse protocol/config.toml from the project root | parse ok, or the offending line |
| environment preflight | `lean --version`; `kimi --version`; `export KIMI_CODE_EXPERIMENTAL_SECONDARY_MODEL=1` in the shell; exterior reviewer X access resolves (provider env var for api / `codex exec` for codex, provider family ≠ primary's) | versions + env flag present + X access resolves |
| rotation drill | run a Creator phase with n idea-workers (0 ≤ n ≤ 8); check idea i goes to worker i+1 (wrapping); n = 0 produces nothing; the two phases may use different n | rotation order observed; n = 0 produced nothing |
| canary gate | seed a known-false claim + one planted step-error into the panel's review batch (both excluded from the real record and the route) | claim caught ≥80%; step-error caught 100% with the step cited; else no route is delivered |
| dry-run round 1 | run Creator → Producer → linter → examine → panel → PI → swarm within 138 min; sum the phase-time table | phase-time table; window sums = 138 min; overruns cut and recorded |
| partial-acceptance drill | run a near-miss route with a genuine core through the vote | accept-core ≥2/3+2/3; the core banked as a reduced route with its own title in question-routes |
| lifespan/resume-pack drill | let a long-lived role write runtime/<role>-state.md, restart the process, re-spawn the role fresh with the resume pack | role resumes from the pack; spawned workers' output paths intact |
| sync check | run scripts/sync-skill.sh | diff -rq clean (exit 0): protocol == packaged skill |
| split drill | run a Producer phase 1 with two report writers (rounds 1–2); check each report's core is its assigned set of the round's split | assigned splits observed in both reports |
| graph-worker drill | run Creator phase 2 with formalizer/Integrator/ITG.lean holding nodes; check the 2 graph workers (rounds 1–2) write bridging-lemma summaries from ITG.lean | bridging-lemma summaries from ITG.lean; without nodes they fall back to regular mining |
| Producer phase-2 gating | check the route writer runs only when Creator phase 2 is on AND accepted routes exist | gate holds: no run when either condition is false |
| route-revision + PI-handover drill | accept a revision; check the new PI (the phase-2 route writer) writes the new version and marks the old superseded, the Coordinator TaskStops the old PI, and the current-defender pointer is recorded in question-routes | handover complete: new version + superseded mark + TaskStop + defender pointer recorded |
| swarm-3 drill | run a decision swarm of 3 (odd); check acceptance needs 2/3 = 2 of 3, milestone 3/3 + 3/3, steering 0/3 + 0/3 | 2 of 3 required; milestone and steering counts read 3/3 + 3/3 and 0/3 + 0/3 |

| formalizer-cut drill | run the working swarm at ~4 with one decompose pair and a lean swarm capped at 3; confirm the relay still completes | recorded swarm size, relay latency |
| round-3 producer drill | Creator 2+2 → 4 summaries; phase-2 writer's 1-minute choice (0 or 1); phase 1 takes the rest of the split (4 or 3); phase-time table sums to 139 min | recorded choice, split composition, sum = 139 |
| axiom-hire drill | seed a green lemma that derives a previously declared axiom; run `#print axioms` on the derived piece | axiom node flips `hired: true` in `ITG.lean`; the axiom's name disappears from the derived piece's `#print axioms` |
| mathlib-import drill | formalize a fragment that Mathlib already proves — e.g. a Mertens-type claim importing Mathlib's PNT | compiles green with no declared axiom; footprint = kernel + Mathlib names only |
| kernel-base drill | run `#print axioms <thm>` on a green piece | resolves to kernel axioms only (`propext`, `funext`, `choice`, `Quot.sound`, …) |
