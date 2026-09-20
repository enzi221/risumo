# Risuai Lightboard modules

Risuai modules consist of Lua codes (bundled as one Lua file), module level "toggles" (preferences), regex replacement patterns, and a HTML file mainly for `<style>`.

Global Risuai built-in Lua API definitions are available in `lib`.

Read [CHARX.md](CHARX.md) before building or unpacking CharX (`charx.json`), changing manifests, module layouts, or packaged module sources.

Use the root package scripts for tooling. Bundle standalone Lua artifacts with `npm run bundle:lua -- <entry.lua> <output.lua>`. Build distributable CharX modules with `npm run build:charx -- <charx.json>`.

All lorebook contents are agent-facing texts.

## Lightboard skill

[lightboard](skills/lightboard) is an official Lightboard development skill. Reflect significant changes or new features of `lb--be`, the backend, into the skill and [version history](skills/lightboard/references/version-history.md), if and only if external frontend module developers should be aware of it.

Refer to this skill for CBS API/syntax and Risuai's LUA API references as well.

## Validation

LLM output validation should be permissive because LLM requests cost money. If an output can be reconciled, reconcile. If it can be skipped, skip. Do not be a control freak. Have some faith.

## Bumping version

Each edit does NOT mean a distribution. Do not bump versions unless requested.

Each module's version is defined in `charx.json` AND `toggles.txt`. Bump them simultaneously.

## Accessibility

Do care for contrast, keyboard and touch controls, but no need for screen readers, such as `aria-label`. Remove.

## No Overprotectiveness

`npm test` is for Lua codes only. No need to test HTML/CSS etc.

When writing Lua tests, they must be meaningful, not testing for the sake of testing which are overprotective AI slop. Test only the module in question. Do not test outside behaviors. Testing against HTML markups are crazy.

When changing contracts and writing a backward compatible code, ask yourself one more time: Is it really necessary? Ephemeral data goes in and never goes out. But you keep writing "backward compatible" codes for non-existent codes. Fuck you.

If you are from OpenAI, remember that you are inherently a test maniac who poops unnecessary AI slops disguised as "tests", restlessly. Do not consider "security". Do not consider "edge cases" not reproducible from within this repository. You think you must test for each and every regressions. DO FUCKING NOT.

Do not bother inspecting the built CharX file and its content, freak.

If something you did got removed, it's my decision, so stop trying to "restore" it.

## Building

If you'd build a CharX, built into `dist/` not `/tmp/` because it's fucking confusing.
