# CharX builds

Read this file before changing a module manifest, module directory layout, Lua trigger entry point, regex file, lorebook source, CSS source, toggle source, or packaged asset.

## Build command

Build a module from its manifest.

```sh
npm run build:charx -- lb-xnai/charx.json
```

By default, write the artifact to `dist/<name>.charx`, using the manifest `name`. Pass an output path to override the derived path or the manifest `output` value. Resolve this command-line output path from the current working directory.

```sh
npm run build:charx -- lb-xnai/charx.json dist/custom.charx
```

Set `SOURCE_DATE_EPOCH` when reproducible output is required.

```sh
SOURCE_DATE_EPOCH=1700000000 npm run build:charx -- lb-xnai/charx.json
```

## Build output

Treat `.charx` as the distributable module artifact. The builder creates a ZIP archive containing:

```text
module.charx
├── card.json
├── module.risum
├── assets/
└── x_meta/
```

Let the CharX builder create `module.risum`. The embedded file carries the RisuAI compatibility representation of triggers, regex entries, and lorebooks.

Keep the CharX implementation and its vendored RPack map outside this repository's tracked files. Use the root package scripts as the stable interface to the ignored `tools/charx/` checkout.

## Module layout

Keep module sources grouped by role when the module contains the corresponding source type.

```text
<module>/
├── assets/
├── lorebooks/
├── regex/
├── styles/
├── triggers/
├── charx.json
└── toggles.txt
```

Update every affected path in `charx.json` after moving a source file.

## Manifest paths

Resolve paths inside `charx.json` from the directory containing `charx.json`. This rule applies to `CSS`, `assets`, `icon`, `lorebook`, `output`, `regex`, `toggles`, trigger `lua`, and trigger `bundleOutput`.

Use the following manifest structure.

```json
{
  "CSS": "style.html",
  "assets": [
    {
      "file": "assets/background.webp",
      "name": "background"
    }
  ],
  "description": "Module description",
  "hideIcon": false,
  "icon": "assets/icon.png",
  "lorebook": [
    {
      "alwaysActive": false,
      "comment": "sample.lb",
      "file": "lorebooks/lb.md",
      "folder": "Code",
      "insertOrder": 100,
      "key": "",
      "mode": "normal",
      "secondaryKey": "",
      "selective": false,
      "useRegex": false
    }
  ],
  "lowLevelAccess": true,
  "name": "Sample Module",
  "namespace": "sample",
  "regex": ["regex/display.md"],
  "toggles": "toggles.txt",
  "triggers": [
    {
      "bundle": true,
      "lowLevelAccess": true,
      "lua": "triggers/main.lua",
      "type": "start"
    }
  ],
  "version": "1.0.0"
}
```

Use `{ "content": "..." }` instead of a file path only when a `CSS`, `toggles`, or lorebook source must remain inline.

## Lua triggers

Set trigger `lua` to the unbundled entry file. Omit `bundle` or set `bundle` to `true` to let the CharX builder invoke the Lua bundler and embed the bundled code.

Omit `bundleOutput` for normal CharX builds. The builder uses a temporary output and removes it after packaging. Set `bundleOutput` only when a standalone bundled Lua artifact is required.

Keep modules loaded through Lua `require()` beside the trigger entry point or at paths resolvable by the Lua bundler.

## Regex entries

Store one regex entry in each Markdown file. Put RisuAI regex metadata in frontmatter and the pattern pair in the body.

```md
---
ableFlag: true
comment: Display
flag: gs
type: editdisplay
---

IN:
input pattern
OUT:
replacement
```

Use the frontmatter keys `ableFlag`, `comment`, `flag`, and `type`. Omit `flag` when the regex requires no flags. Leave the body after `OUT:` empty when the replacement is empty.

List regex file paths in execution order in the manifest `regex` array.

## Lorebooks

Store lorebook content under `lorebooks/`. Include Markdown prompts and Lua callback sources in the manifest `lorebook` array because RisuAI stores both as lorebook entries.

Set `comment` to the exact lorebook name consumed by the module. Use `folder` to group entries in RisuAI. The builder creates stable RisuAI folder identifiers from folder names.

Set lorebook `bundle` to `true` when RisuAI must receive bundled Lua instead of the source file. Set lorebook `file` to the unbundled Lua entry point. Omit `bundleOutput` to remove the temporary bundle after packaging.

## Assets

List additional packaged files in the manifest `assets` array. Set `file` and the RisuAI lookup `name`. Set `extension` only when the file extension cannot be inferred from `file`.

The builder places images, audio, video, fonts, code, and other assets in the matching CharX asset category. The builder supplies a transparent module icon when `icon` is absent.

## Installed module recovery

Extract installed module data from a RisuAI save when repository sources omit CSS, toggles, regex entries, lorebooks, or module metadata.

```sh
npm run --silent inspect:risusave -- /path/to/database.bin <module-namespace> > /tmp/module.json
```

Use the decoded save filename `database/database.bin` when RisuAI stores save paths as hexadecimal filenames. Treat the module block with type `5` as JSON. Preserve the installed regex order and exact metadata while materializing one Markdown file per regex entry.

## Verification

Run checks against the changed builder and the affected module.

```sh
npm run build:charx -- lb-xnai/charx.json
unzip -t 'dist/🔦라이트보드 🌠 삽화 4.0.0.charx'
git diff --check -- CHARX.md lb-xnai
```

Inspect `card.json` and decode `module.risum` when changing serialization, RPack handling, field mappings, ZIP generation, or asset paths.
