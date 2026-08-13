# spawn request — <territory full name> → Coordinator
# the locked format. the Coordinator validates mechanically and never reinterprets;
# a violation is answered with status: rejected and a one-line reason.
kind: <spawn | resume | stop>
requester: <c | p | s | f | i>
round: <n>                                 # the current round — the birth round for new labels
workers:
  - label: <c|p|s|f>-<round>-<type>-<order>   # c-2-1-3 = Creator, round 2, idea-worker, 3rd instance; i-1 = integrator-worker-1; i-2 = integrator-worker-2
    profile: <locked worker profile name>     # spawn only
    output: <relative path>                   # spawn only
    brief: <relative path>                    # spawn and resume — a file pointer, never inline text

# the Coordinator appends on completion:
status: <spawned | resumed | stopped | rejected>
at: <ISO timestamp>
task-ids: <...>                               # spawn only
