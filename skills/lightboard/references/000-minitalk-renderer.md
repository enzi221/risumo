# MiniTalk Renderer

MiniTalk is a front-end module that simulates an instant messaging app.

Create a standalone CharX module that supplies one visual renderer for MiniTalk. Target the self-contained renderer contract in this reference.

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

Package `renderer.lua` as a lorebook named exactly `lb-minitalk.renderer`. Keep the lorebook activation off. MiniTalk loads the highest-priority matching lorebook when the user enables the `lb-minitalk.renderer` checkbox toggle.

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

- `triggerId`: Current Risuai trigger ID.
- `data.messages`: Decoded list of MiniTalk messages.
- `data.name`: Room name.
- `data.participants`: Decoded list of room participants.
- `data.pov`: Participant ID representing the speaker viewpoint.
- `options.chatIndex`: Zero-based chat index.
- `options.escapeText(value)`: Escape text for HTML and prevent CBS evaluation of message text.
- `options.id`: Unique popover ID for the rendered room.
- `options.renderContent(message)`: Return escaped text, membership-event text, MiniCon image HTML, validated OpenBlock HTML, or the default unavailable-OpenBlock fallback HTML.

Each participant contains `id` and `name` strings. Retain records for departed participants referenced by message history.

Each message contains `content`, `sender`, `time`, and `type` strings. Use exactly one content kind per message:

- `text`: Render `content` as text.
- `con`: Render `content` as the MiniCon identifier through `options.renderContent(message)`.
- `openblock:identifier`: Render `content` through `options.renderContent(message)`.
- `invited` and `exit`: Render a system row through `options.renderContent(message)`. The `content` references a participant ID; `sender` is `-`. The helper resolves the participant name and returns `{name}님을 초대했습니다.` or `{name}님이 퇴장했습니다.`, respectively.
- `pause`: Render `content` as elapsed-time text. A pause message has `-` in `sender` and `time`.
- `skip`: Render a visual separator for an unknown amount of omitted conversation over an unknown duration. A skip message has `-` in `sender`, `time`, and `content`.

MiniTalk retains unavailable OpenBlock messages. Call `options.renderContent(message)` to render the default fallback when an OpenBlock is disabled, missing, or fails to render.

Return a non-empty HTML string. Throw an error when rendering cannot continue.

## Rendering

Create the HTML structure required by the user's renderer specification. Do not assume any preexisting DOM structure or CSS. Use `h` for dynamic HTML so text content is escaped. Use a module-specific root class and prefix every owned class with the module namespace.

Call `options.renderContent(message)` for every message except `pause` and `skip`. Insert its result with `hraw()`. Call `options.escapeText(message.content)` for pause text and insert its result with `hraw()`. Render a skip directly as a visual separator without displaying its placeholder content.

Respecting other visual preferences is not a requirement. It should depend on the user requested design.

### OpenBlock colors

Set these inherited custom properties on each message wrapper that contains `options.renderContent(message)`:

- `--lb-minitalk-accent`: Accent color for prominent details.
- `--lb-minitalk-bg`: Primary content surface.
- `--lb-minitalk-bg-2`: Secondary content surface.
- `--lb-minitalk-border`: Content border color.
- `--lb-minitalk-fg`: Content foreground color.

Set the properties per message. Apply outgoing-message surface variants to the properties so text bubbles and OpenBlocks receive the same sender-specific palette. Keep palette calculations in the message wrapper and consume the properties directly in content CSS.

### Icons

All icons are 15x15 `<svg>`.

- `<lb-comment-icon>`: A speech bubble.
- `<lb-play-icon>`: A right-pointing triangle.
- `<lb-reroll-icon>`: A turning arrow.
- `<lb-trash-icon>`: A diagonal cross.
- `<lb-pin-icon>`: A pin icon. Set `pinned="true"` fills it.

### Interactions

Interactions are post-generation user actions. Write them in `risu-btn` attributes: `<button risu-btn="lb-reroll__lb-minitalk"><lb-reroll-icon /></button>`

This control should always present:

- Reroll: `lb-reroll__lb-minitalk`. Remove the chat room, generate anew.

Expose these actions when the requested renderer includes interaction controls:

- Send message: `lb-interaction__lb-minitalk__SendMessage`.
- Pass time without a user-directed message: `lb-interaction__lb-minitalk__PassTime`.
- Change room: `lb-interaction__lb-minitalk__ChangeRoom`.

MiniTalk applies `SendMessage` and `PassTime` output from `<lb-minitalk-patch>` to the stored room before rendering. `ChangeRoom` outputs a complete `<lb-minitalk>` block directly. Renderers continue to receive the complete room object.

Use `options.chatIndex` without conversion. Omit controls that the requested renderer does not expose.

Do not include JavaScript or external links. Use supported HTML controls, popovers, and `risu-btn` actions for interaction.
