# LightBoard Backend

LightBoard is a framework that runs auxiliary LLM requests alongside the main chat model in Risuai. Frontend modules register manifests; the backend orchestrates prompt assembly, LLM calls, validation, and result insertion.

## Architecture

```
init.lua          Entry point. Hooks into onOutput, onStart, onButtonClick, listenEdit.
manifest.lua      Discovers and parses module manifests from lorebooks.
prompts.lua       Assembles the full prompt (system intro, chat logs, output schema, extras).
pipeline.lua      Runs the prompt through LLM, cleans the result, retries on validation failure.
lbdata.lua        Manages the [LBDATA START]..[LBDATA END] block in chat messages.
sideeffect.lua    Handles manifests flagged as sideEffect (modify chat content directly).
constants.lua     Config keys and LBDATA markers.
```

## Execution Modes

### Generation (`onOutput`)

Triggered automatically after the main model replies.

1. Inserts an empty `[LBDATA START]..[LBDATA END]` placeholder into the last assistant message.
2. Collects all active manifests, splits them into normal and sideEffect groups.
3. Runs normal manifests through the pipeline in parallel (bounded by `concurrent` config).
4. Concatenates results and replaces the LBDATA placeholder.
5. Runs sideEffect manifests, which receive the pipeline output and directly mutate chat content via their `onOutput` callback.

### Reroll (`onButtonClick` with `lb-reroll__` prefix)

Triggered by the user pressing a reroll button on a specific module block.

1. Locates the target chat and strips the existing block(s) for the given module identifier.
2. Inserts a pending-state message.
3. Re-runs the pipeline for that single manifest using the chat context up to the target.
4. Inserts the new result at the position where the old block was removed.
5. Removes the pending message.

Supports targeting a specific block by appending `#blockID` to the identifier.

### Interaction (`onButtonClick` with `lb-interaction__` prefix, then `onStart`)

Triggered by the user selecting an action on a module block, optionally followed by a free-text direction message.

1. The button click either:
   - (immediate mode) Runs the interaction pipeline right away, or
   - (default) Posts a hidden message containing the identifier and action, then waits for the user to send a direction message.
2. `onStart` detects the pending interaction messages and calls `interact`.
3. `interact` appends the action name, user direction, and the module's interaction guideline (`*.lb.interaction`) as extra prompt context, then runs the pipeline.
4. The result replaces (or is appended after, if `preserve` modifier is set) the existing block in the target chat.

Action string modifiers (prefixed before `#`): `preserve`, `immediate`, `id=<blockID>`.

## Manifest

Manifests are stored as lorebooks keyed `manifest.lb`. Each manifest is a key=value text block. Key fields:

| Field | Description |
|---|---|
| `identifier` | Unique module ID. Used as the XML tag name wrapping output. |
| `mode` | LLM routing. `1` = primary, `2` = auxiliary. |
| `maxCtx` | Max context tokens for this module. |
| `maxLogs` | Max chat log entries to include. |
| `lazy` | If true, skip LLM call during generation and emit a `<lb-lazy>` placeholder instead. |
| `sideEffect` | If true, output is processed by `onOutput` callback to mutate chat directly. |
| `insertOrder` | Controls ordering among manifests. Higher = earlier. |

Optional callbacks loaded from lorebooks (`<id>.lb.<name>`): `onInput`, `onOutput`, `onValidate`, `onMutation`.

## Pipeline

`pipeline.lua` handles prompt submission and result processing:

1. If `lazy` and not an interaction, return a `<lb-lazy>` placeholder immediately.
2. Build the prompt via `prompts.make`.
3. Send to LLM (primary or auxiliary based on mode).
4. Strip markdown fences and internal process tags from the response.
5. Run `onValidate` if provided. On validation failure, retry up to `maxRetries` times, appending the error as a correction prompt.
6. Run `onOutput` post-processor if provided.

## Prompt Structure

Assembled by `prompts.lua`:

1. System intro (jailbreak, job instruction, universe settings, persona/character descriptions).
2. Lorebooks (if enabled for the module).
3. Author's note (if enabled).
4. Chat log (last N entries, bounded by `maxLogs` and context token budget). Each log is wrapped in `<!-- Log #N -->` markers. The module's own tags are stripped from context to avoid self-reference.
5. Output instruction (data format schema, generation guideline, optional thinking process instructions).
6. Extra lorebooks (`<id>.lb.extra`).
7. Extras (interaction prompt, if applicable).
8. Language directive.
9. Prefill (if provided via `<id>.lb.prefill`).

## Config Keys

All stored as global variables (`toggle_lightboard.<key>`):

| Key | Values | Default |
|---|---|---|
| `active` | `0` off, `1` on | `0` |
| `position` | `0` append, `1` prepend, `2` separated | `0` |
| `concurrent` | 1-5 | 1 |
| `maxRetries` | 0+ | 0 |
| `retryMode` | `0` same, `1` primary, `2` auxiliary | `0` |
| `thoughts` | `0` process tag, `1` off, `2` guideline only | `0` |
| `sendAsChar` | `0` extract to system, `1` keep as char | `0` |

## `listenEdit` Hook

When `sendAsChar` is `0`, the `editRequest` listener extracts LBDATA blocks from assistant messages and re-inserts them as system messages. This prevents LBDATA from being treated as character dialogue by the main model.
