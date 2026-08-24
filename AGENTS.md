# Risuai LightBoard modules

Risuai modules consist of Lua codes (bundled as one Lua file), module level "toggles" (preferences), regex replacement patterns, and a HTML file mainly for `<style>`.

Global Risuai built-in Lua API definitions are available in `lib`.

Read [CHARX.md](CHARX.md) before changing CharX manifests, module layouts, or packaged module sources.

Use the root package scripts for tooling. Bundle standalone Lua artifacts with `npm run bundle:lua -- <entry.lua> <output.lua>`. Build distributable CharX modules with `npm run build:charx -- <charx.json>`.

All lorebook contents are agent-facing texts.