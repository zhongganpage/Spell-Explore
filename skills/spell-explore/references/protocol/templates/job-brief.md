# job brief — worker <label>
label: <c|p|s|f|i>-<round>-<type>-<order>
# label codes: c creator · p producer · s selector · f formalizer · i integrator — i-1 = integrator-worker-1, i-2 = integrator-worker-2
profile: <...>
output: <...>
deadline: <...>
---
# <body — the job content, authored by the subcoordinator that directs this worker. free-form.>

# contract: write your artifact to the assigned output path as you go and confirm the write in your final message; the file is the artifact and must land on disk even if your subcoordinator's run ends.
