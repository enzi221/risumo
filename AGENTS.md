# Risuai Lightboard modules

Risuai modules consist of Lua codes (bundled as one Lua file), module level "toggles" (preferences), regex replacement patterns, and a HTML file mainly for `<style>`.

Global Risuai built-in Lua API definitions are available in `lib`.

Read [CHARX.md](CHARX.md) before changing CharX manifests, module layouts, or packaged module sources.

Use the root package scripts for tooling. Bundle standalone Lua artifacts with `npm run bundle:lua -- <entry.lua> <output.lua>`. Build distributable CharX modules with `npm run build:charx -- <charx.json>`.

All lorebook contents are agent-facing texts.

## Lightboard skill

[lightboard](skills/lightboard) is an official Lightboard development skill. Reflect significant changes or new features of `lb--be`, the backend, into the skill and [version history](skills/lightboard/references/version-history.md), if and only if external frontend module developers should be aware of it.

## Bumping version

Each module's version is defined in `charx.json` AND `toggles.txt`. Bump them simultaneously.
