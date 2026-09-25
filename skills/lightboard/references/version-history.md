# Version History

## Unreleased

- Added nested field groups to TOON tabular arrays and keyed tabular objects to `prelude.toon.encode()` and `prelude.toon.decode()`.

## 4.5.4

- Added callback context to `onOutput`, matching `onValidate`. Pure modules receive it as the third argument, side-effect modules as the fifth.

## 4.5.2

- Added validation context to `onValidate`, including type and the previous module node for interactions.

## 4.4.0

- Added `prelude.getLoreBooks()` and single-level `<!-- lb:require:NAME -->` and `<!-- lb:require:all:NAME -->` expansion to both Prelude lorebook getters.

## 4.3.0

- Changed `prelude.toon.encode()` to write line feeds as `\u000A` and added matching support to `prelude.toon.decode()`. The decoder continues to accept `\n` for compatibility.

- Added the optional `onInstructions` callback for preprocessing a module's format, guideline, and thoughts instructions once per request.
- Added interaction context to `onMutation`, including the pipeline output and the replaced module node.
- Added `prelude.applyJSONPatch()` for immutable `add`, `remove`, and `replace` operations.

## 4.2.0

- Added configurable `VERBOSE`, `INFO`, and `NONE` diagnostic logging through the Lightboard Prelude.
- Added the optional `friendlyName` manifest field for user-facing module names.
- Added line-based Lightboard command parsing for messages wrapped by edit transforms.
- Added styled command output blocks that stay outside model requests.
- Added visible `⇥` indentation marker support to `prelude.toon.decode()` for transports that discard leading spaces.
