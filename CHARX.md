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

The CharX implementation and its vendored RPack map belong to the separately distributed `risupack` package. Use the root package scripts as the stable interface.

## Unpack command

Extract a CharX archive, decode `module.risum` as readable `module.json`, and materialize module sources with a generated `charx.json`.

```sh
npm run unpack:charx -- input.charx
```

By default, create a directory beside the archive using the filename without `.charx`. Pass a directory to override it. The output directory must be absent or empty.

```sh
npm run unpack:charx -- module.charx /tmp/module-source
```

Write lorebook entries under `lorebooks/`, regex entries under `regex/`, and Lua trigger effects under `triggers/`. Preserve execution order in the generated `charx.json` arrays instead of altering source filenames. The encoded `module.risum` is not retained. If the archive already contains `module.json`, write the decoded data to `module.decoded.json` instead.

Extract a standalone legacy Risu module and its embedded assets with the same source layout.

```sh
npm run unpack:risum -- input.risum
```

## Manifest format

The canonical `charx.json` schema, source layout, Lua trigger rules, regex format, lorebook fields, and asset rules belong to the `risupack` README. Keep manifests in this repository aligned with the installed `risupack` version.

## Installed module recovery

Extract installed module data from a RisuAI save when repository sources omit CSS, toggles, regex entries, lorebooks, or module metadata.

```sh
npm run --silent inspect:risusave -- /path/to/database.bin <module-namespace> > /tmp/module.json
```

Use the decoded save filename `database/database.bin` when RisuAI stores save paths as hexadecimal filenames. Treat the module block with type `5` as JSON. Preserve the installed regex order and exact metadata while materializing one Markdown file per regex entry.
