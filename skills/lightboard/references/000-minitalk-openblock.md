# MiniTalk OpenBlock

MiniTalk is a front-end module that simulates an instant messaging app. OpenBlock defines a structured rich format block other than plaintext.

Add an OpenBlock definition and an OpenBlock implementation to extend `lb-minitalk` with one message type.

## Definition

Create a lorebook named exactly `lb-minitalk.openblock`. Start its content with an identifier line, then describe the payload format in English.

```text
identifier=weather
Write `content` as a city name.
```

Use an identifier matching `[A-Za-z0-9_-]+`. Give each identifier one definition. Enable the `lb-minitalk.openblock` toggle before generation so the MiniTalk supplies the definition to the model.

The model will write the message as a TOON row with `type` set to `openblock:weather`. The full `content` value is the payload string.

Note that the content CANNOT include line breaks. Use other means, such as `§` as separators.

```text
seojun|openblock:weather|방금|서울
```

## Implementation

Create a lorebook named exactly `lb-minitalk.openblock.weather`, replacing `weather` with the definition identifier. Return a table containing `validate` and `render` functions.

```lua
local function validate(triggerId, content)
  if content:match('^.+$') then
    return true
  end
  return false, 'content must contain a city name'
end

local function render(triggerId, content, options)
  return tostring(h.div {
    class = 'lb-minitalk-ob-weather',
    hraw(options.escapeText(content)),
  })
end

return {
  render = render,
  validate = validate,
}
```

`validate()` receives the trigger ID and unmodified payload string. Return `true` for valid content. Return `false, reason` for invalid content. MiniTalk runs validation on generated output and on stored content when the implementation is available.

`render()` receives the trigger ID, unmodified payload string, and the renderer options table. Return non-empty HTML. Use `h` for element construction and `options.escapeText()` for payload text. Prefix every owned CSS class with a module-specific namespace.

## Styling

Use the inherited MiniTalk color properties for every OpenBlock color:

- `--lb-minitalk-accent`
- `--lb-minitalk-bg`
- `--lb-minitalk-bg-2`
- `--lb-minitalk-border`
- `--lb-minitalk-fg`

Consume the properties directly. Let the renderer provide sender-specific values on the containing message wrapper.

## Availability

MiniTalk loads an OpenBlock only when all conditions hold:

- The `lb-minitalk.openblock` toggle is enabled.
- A definition lorebook provides the identifier.
- The matching implementation lorebook returns both functions.

MiniTalk rejects generated `openblock:identifier` messages that are unavailable. Existing unavailable OpenBlock messages remain valid stored data and render through the default fallback.
