# Version History

## 4.3.0

- Added the optional `onInstructions` callback for preprocessing a module's format, guideline, and thoughts instructions once per request.

## 4.2.0

- Added configurable `VERBOSE`, `INFO`, and `NONE` diagnostic logging through the Lightboard Prelude.
- Added the optional `friendlyName` manifest field for user-facing module names.
- Added line-based Lightboard command parsing for messages wrapped by edit transforms.
- Added styled command output blocks that stay outside model requests.
- Added visible `⇥` indentation marker support to `prelude.toon.decode()` for transports that discard leading spaces.
