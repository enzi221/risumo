# Miniboard Renderer

Create a standalone CharX module that supplies one visual renderer for Miniboard. Target the self-contained renderer contract in this reference for Miniboard 4.1.1+.

## Deliverable

Remember that this is not a full Lightboard module. Do not add `manifest.lb` or anything Lightboard expects.

### With risupack

If `risupack` is available and the user wants distributable packaging all at once, create these sources in a module directory as per `risupack` expects:

```text
<module>/
|-- charx.json
|-- lorebooks/
|   `-- renderer.lua
`-- style.html
```

Package `renderer.lua` as a disabled lorebook named exactly `lb-mini.renderer`. Miniboard automatically loads the highest-priority lorebook with that name when the user enables the `lb-mini.renderer` checkbox toggle.

### Without risupack

If `risupack` is unavailable or the user simply wants renderer code to embed somewhere else, write the renderer Lua and CSS only. For CSS, write it as a HTML with single `<style>` element.

## Runtime Contract

The backend provides core utilities from string manipulation, XML node queries, HTML building (`h`), to more Risuai-specific APIs such as lorebook loading. Read [Lightboard Prelude](000-prelude.md) for more.

Return a renderer function from the lorebook chunk:

```lua
local function render(triggerId, data, options)
  -- Return rendered HTML.
end

return render
```

The renderer receives:

- `triggerId`: Current Risuai trigger ID
- `data.attributes`: Attributes from the `<lb-mini>` node
- `data.posts`: Decoded list of Miniboard posts
- `options.chatIndex`: Chat index used by deletion actions
- `options.color`: Resolved accent color as a CSS color string
- `options.darkness`: Either `light` or `dark`

Each post contains `author`, `comments`, `content`, `downvotes`, `time`, `title`, and `upvotes`. Each comment contains `author`, `content`, and `time`. These are all strings.

Read the optional board name from `data.attributes.name`.

Return a non-empty HTML string. Throw an error when rendering cannot continue.

## Rendering

Create the HTML structure required by the user's renderer specification. Do not assume any preexisting DOM structure or CSS. Use `h` for dynamic HTML so text content is escaped. Use a module-specific root class and prefix every owned class with the module namespace.

Respecting `options.color` and `options.darkness` is not a requirement. It should depend on the user requested design.

### Icons

All icons are 15x15 `<svg>`.

- `<lb-comment-icon>`: A speech bubble.
- `<lb-reroll-icon>`: A turning arrow.
- `<lb-trash-icon>`: A diagonal cross.
- `<lb-pin-icon>`: A pin icon. Set `pinned="true"` fills it.

### Interactions

Interactions are post-generation user actions such as writing a post or a comment. You must write them in `risu-btn` attributes: `<button risu-btn="lb-reroll__lb-mini"><lb-reroll-icon /></button>`

This control should always present:

- Reroll: `lb-reroll__lb-mini`. Remove the board, generate anew.

Use these action values only for controls present in the requested renderer:

- Change board: `lb-interaction__lb-mini__ChangeBoard`. Remove the board, generate anew with a user defined direction.
- Add post: `lb-interaction__lb-mini__AddPost`
- Add comment: `lb-interaction__lb-mini__AddComment/Title:{title}`
- Delete post: `lb-mini-delete/{chatIndex}_{postIndex}`
- Delete comment: `lb-mini-delete/{chatIndex}_{postIndex}_{commentIndex}`

Use one-based post and comment indexes. Use `options.chatIndex` without conversion. Omit controls that the requested renderer does not expose.

Do not include JavaScript or external links. Use supported HTML controls, popovers, and `risu-btn` actions for interaction.
