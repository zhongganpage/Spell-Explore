# Spell-Explore — the exterior reviewer (X, workerD's external path): configuration

Load this module at project start — configuring X is part of the round-1
setup (`rules/coordinator.md` §1) — or when wiring X. X is the panel's
external reviewer: workerD runs on it whenever it is configured, giving the
panel genuine model diversity — the one reviewer that does not share the
internal harness's provider family, weights, and blind spots.

## Variables (fixed once at project start, round 1)

| Variable | Meaning | Examples |
|---|---|---|
| `X_PROVIDER` | provider company | `kimi` · `openai` · `anthropic` · `google` · `deepseek` · … |
| `X_MODEL` | model name | `k2.7` · `o3` · `claude-sonnet-4` · `gemini-2.5-pro` · `deepseek-chat` · … |
| `X_ACCESS` | how X is reached | `api` (HTTP API) · `codex` (local Codex CLI) |

A working default: `X_PROVIDER=kimi`, `X_MODEL=k2.7`, `X_ACCESS=api` (key in
`MOONSHOT_API_KEY`). The `api` mode has no sandbox issues — a plain HTTP call
cannot be blocked by a read-only sandbox — and is used unless Codex is
actually required. When the Codex CLI is installed (`codex exec`), an
OpenAI-family model via `X_ACCESS=codex` needs no API key.

## Access modes

- **`api`** — an HTTP call to the provider's API; the key lives in the
  provider's environment variable (table below) or a secrets store. If the
  variable is unset, X is unavailable. Most providers expose an
  OpenAI-compatible chat-completions endpoint; the Coordinator follows the
  provider's official docs for the call shape. The reply body is the
  artifact: the Coordinator extracts the message text, persists it verbatim
  at the assigned path, and marks the record `recovered from agent output`.
- **`codex`** — the locally installed OpenAI Codex CLI: X is invoked as
  `codex exec "<phase prompt>"` and the reply on stdout is captured as the
  written artifact. Authenticates through Codex's own login or
  `OPENAI_API_KEY`; `X_MODEL` is whatever Codex is configured to use. Codex
  may run in a read-only sandbox (`sandbox_mode: read-only`, approval
  `never`) that blocks file writes — then stdout is the artifact: the prompt
  asks for a **summary + inline reports** rather than the full artifact, the
  reply is delimited with **standardized markers** (e.g. `<<<D-REPORT>>>` /
  `<<<D-END>>>`), captured, and persisted verbatim at the assigned path,
  marked `recovered from agent output`.

Credentials are never written into the dossier, a report, or any record.

## Common providers

Env var names follow each provider's official docs (the ones shown are the
common conventions). "Aggregators" expose many models behind one key.

| Provider | Company | Model family | Access (typical env var / command) |
|---|---|---|---|
| OpenAI | OpenAI | GPT · o-series · Codex | `OPENAI_API_KEY` or `codex exec` (installed) |
| Anthropic | Anthropic | Claude (Sonnet · Opus) | `ANTHROPIC_API_KEY` |
| Google | Google DeepMind | Gemini (Pro · Flash) | `GEMINI_API_KEY` |
| Kimi | Moonshot AI | k2.x | `MOONSHOT_API_KEY` |
| DeepSeek | DeepSeek | deepseek-chat · deepseek-reasoner | `DEEPSEEK_API_KEY` |
| Qwen | Alibaba Cloud | qwen-max · qwen3 | `DASHSCOPE_API_KEY` |
| GLM | Zhipu AI | GLM-4.x | `ZHIPUAI_API_KEY` |
| Grok | xAI | Grok | `XAI_API_KEY` |
| Mistral | Mistral AI | Mistral Large · Medium | `MISTRAL_API_KEY` |
| Aggregators | OpenRouter · Groq · Together | many models | `OPENROUTER_API_KEY` · `GROQ_API_KEY` · `TOGETHER_API_KEY` |

## Diversity enforcement

At round-1 setup — as part of the exterior-agent question — the Coordinator
verifies that `X_MODEL` is **not the same provider family as the primary
model's** (one-line check, non-negotiable). If it is, or if X is unavailable
(the env var unset, codex missing, or the call fails), workerD falls back to
an internal reviewer, the run is auto-labeled `reduced diversity` with a
confidence downgrade, and the fallback is recorded in the archive. The panel
row records **which model actually ran** for workerD — the model identifier
returned by the provider — so a same-family or absent X is always visible;
there is no silent same-model panel (this also catches exterior-agent drift:
the provider returning a different model than configured).

## Availability

X is invoked twice per panel: the review (63–93) and exchange/summary
(93–103) in one call, and the vote (118–138) in a second call with a
consolidated prompt. If X cannot be reached at panel start — or never
launches — workerD is filled by the internal D-internal reviewer
(`reviewer-bcd.md`) and the panel runs B, C, D-internal with the reduced
diversity recorded and a confidence downgrade; X's absence is recorded as a
ledger event (including `never launched`). A failed invocation may be retried
once within the window before the fallback. If X fails mid-run, the written
artifacts up to the failure point stand and the partial participation is
recorded.
