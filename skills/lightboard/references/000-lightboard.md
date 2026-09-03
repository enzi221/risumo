# Lightboard Development Guide

All Lightboard modules depend on the "Lightboard backend" module. This dependency is mandatory.

## Concepts

Lightboard is a framework for sending auxiliary LLM requests. It keeps the context window of the "main model," which responds to user messages during roleplay, cleaner and lighter by delegating instruction-heavy prompts to the auxiliary model.

By default, Lightboard data goes into a block named `LBDATA` between `---\n[LBDATA START]` and `[LBDATA END]\n---`. The backend prepends, appends, or separates this block into its own message according to the user's toggle. A Lightboard module cannot modify the chat text body unless it is side-effectful.

## Basic Requirements

1. Defining an identifier
2. Creating a manifest lorebook
3. Setting up toggles
4. Writing prompt fragments in lorebooks
5. Writing regexes for lazy button rendering and request exclusions
6. Writing Lua for primary rendering and complex interactions
7. Writing the CSS

Keep every Lightboard lorebook disabled and omit activation keys. The backend discovers Lightboard lorebooks by name instead of activation.

### Identifier

Use a unique identifier among Lightboard frontends. Use lowercase letters and hyphens, such as `mail-list` or `my-module`.

### Manifest

Create a lorebook named exactly `manifest.lb`. Do not activate it or specify activation keys.

```
identifier={identifier}
{key}={value}
```

Use the following recommended fields for in-universe simulated data:

```
identifier=mail-list
friendlyName=Mail Inbox
authorsNote=true
charDesc=true
loreBooks=true
personaDesc=true
```

All possible KVs:

- authorsNote: boolean. Include author's note in requests? Default false.
- charDesc: boolean. Default false.
- friendlyName: string. Optional user-facing module name. The backend falls back to `identifier` when omitted.
- personaDesc: boolean. Default false.
- loreBooks: boolean. Default false.
- maxCtx: integer. Maximum request context length. The backend provides a default through its toggle. Omit this field unless the frontend requires only recent chat context.
- maxLogs: integer. Maximum number of chat entries in a request. The backend provides a default through its toggle. Omit this field unless the frontend requires only recent chats.
- multilingual: boolean. If true, the backend adds a directive for the language selected by the user, such as "Output in Korean." Default true.
- reiteration: integer. If greater than 0, the auxiliary model self-reviews its output N times, where N is the toggle value. Default 0.
- sideEffect: boolean. If true, the module's `.lb.onOutput` script can edit the original chat text body. Use for advanced cases only. Default false.
- lazy: boolean. Whether the module sends an LLM request immediately after the chat response or waits for the user to click the trigger. Default false.
- thoughts: integer. Use 0 to force CoT output, 1 to integrate CoT prompts without forcing output, or 2 to disable CoT prompts. Default 0.

You may omit the keys to use default values.

### Toggles

The required toggle is `.mode` with three values. The recommended toggles are `.lazy` and `.thoughts`.

Convention: `.mode` is "모드" with "끄기,메인,보조". `.lazy` is "발동" with "즉시,누르면", `.thoughts` is "생각보조" with "하고 제거,생각만,안하기".

```
=메일함=group
my-module.mode=모드=select=끄기,메인,보조
my-module.lazy=발동=select=즉시,누르면
my-module.thoughts=생각보조=select=하고 제거,생각만,안하기
==groupEnd
```

All manifest fields can be overridden through toggles as follows:

```
my-module.authorsNote=작노
my-module.maxLogs=채팅포함수=text
```

If a toggle controls a manifest field, omit that field from the manifest to avoid redundancy.

### Prompt fragments

First, decide how to represent the requested data. The following example uses a JSON object.

Store each fragment in its respective lorebook.

In this section, code fences separate lorebook contents from the surrounding descriptions. Do not wrap the actual lorebook contents in code fences.

Write prompts in English to save tokens. Example output may use the user's desired language.

Do not activate these lorebooks or specify activation keys. The backend collects the fragments and assembles them into a full prompt. Keep each fragment independent of the other fragments.

#### {identifier}.lb.format (Required)

Provide a minimal data format example.

```json
{
  "address": "address@abc.def",
  "unread": 99,
  "mails": [["title", "sender@opq.xyz", false]]
}
```

#### {identifier}.lb (Required)

Provide the core prompt.

````md
# Simulation details

## Address

Invent a plausible email address of {{char}}.

## Unread emails

An integer number of unread emails in the inbox of {{char}}. Depending on the personality of and current circumstances of {{char}}, this number can go as low as 0 or as high as 9999.

## Recent emails

Invent a list of recent emails, read or unread. Each email should have a title, a sender address, and a read/unread status.

# Example

```
<my-module>
{
  "address": "2doritos1@promail.com",
  "unread": 1923,
  "mails": [
    ["[광고] 5월 특별혜택! 최대 27만원 할인+사은품 증정!", "no-reply <no-reply@bigmarket.com>", false],
    ["진심이야?", "예빈 <yebin331@gmail.com>", true],
    ["[긴급] 계정 보안 알림", "no-reply <security@promail.com>", false]
  ]
}
</my-module>
```

- Use `<my-module>`.
- Output in JSON.
- mails: A list of tuples of [title, sender address, read/unread (true/false)].
- Close `</my-module>`.
````

The example wraps the data defined by `.lb.format` in `<my-module>`. Wrap frontend output in an XML node whose name matches the identifier.

#### {identifier}.lb.job (Optional)

Provide the LLM job description.

```md
Your job is to simulate a mail inbox of {{char}}. You will be given creative materials including universe settings and narrative chat log. Utilize materials, output in structured format.
```

The default prompt is sufficient in many cases.

```md
Your job is to produce data blocks as instructed. You will be given creative materials including universe settings and narrative chat log. Utilize materials, output in structured format.
```

#### {identifier}.lb.thoughts (Optional)

Provide a CoT instruction when the `.thoughts` toggle is present.

```md
{{#when::my-module.thoughts::tis::0}}
Think step-by-step for final data, but keep minimal draft per step.
{{/when}}

Follow this template to produce the output:

1. ...
2. ...
```

#### Other prompts

- .lb.prefill: Prompt prefill in the assistant role.
- .lb.prefill-user: Prompt prefill in the user role after the assistant-role prefill.
- .lb.universe: Additional text to insert right before character lorebooks.
- .lb.extra: Store these lorebooks in other modules or characters instead of the frontend module itself. They inject additional prompts into the corresponding frontend module and provide a user customization point.

### Lazy button rendering

When either the manifest's `lazy` field is true or a user enables the `.lazy` toggle, the backend appends `<lb-lazy id="{identifier}" />` instead of sending an LLM request.

Render the placeholder with a regex script for faster performance than Lua rendering.

```text
---
ableFlag: true
comment: Lazy
flag: gms
type: editdisplay
---

IN:
(?:<lb-lazy id="my-module"\s*\/>)|(?:<lb-lazy id="my-module"\s*>(.*?)<\/lb-lazy>)\n?
OUT:
{{#if {{greater_equal::{{chat_index}}::{{? {{lastmessageid}} - 3}}}}}}

<div class="lb-module-opener-root" data-id="my-module">
<button class="lb-module-opener" data-lazy="true" risu-btn="lb-reroll__my-module">
My Module
<lb-reroll-icon />
</button>
</div>
{{/if}}
```

This button uses the reroll action described below. The `<lb-lazy ...>` tag and `lb-reroll__identifier` action allow separate styling for the lazy state.

## Advanced Features

### Reroll button

Lightboard provides a per-frontend reroll button for replacing unsatisfactory output. Rerolling one frontend is more efficient than rerolling the entire chat output.

Provide a reroll button in every frontend.

Render the `<button>` as follows:

```

<button risu-btn="lb-reroll__my-module">...</button>
```

Note the format: `lb-reroll__{identifier}`.

The backend replaces `<lb-reroll-icon />` with a turning arrow icon (`<svg>`).

### Interactions

Interactions are post-generation user requests such as:

- A partial update with or without a user instruction
- Total regeneration with a specific user instruction

Use the `{identifier}.lb.interaction` and `{identifier}.lb.thoughts-interaction` lorebooks with a `risu-btn="lb-interaction__{identifier}__{interaction}"` button. Read `001-interactions.md` for more details.

### Callbacks

The backend provides callback support:

- Input preprocessing: `{identifier}.lb.onInput`
- Validation: `{identifier}.lb.onValidate`
- Output post-processing: `{identifier}.lb.onOutput`
- Reroll and interaction mutation: `{identifier}.lb.onMutation`

All callbacks are optional.

Store each callback as Lua code in its respective lorebook and use the following structure:

```lua
local function main(triggerId, input)
  return input
end

return main
```

Note the `return main`. It must return the callback function.

> [note]
> These callbacks differ from the Risuai-defined onInput and onOutput callbacks. Store Risuai-defined callbacks in the trigger script and Lightboard callbacks in their respective lorebooks.

#### Before input

Receives `(triggerId, chat text)`. The backend calls it for every chat block being sent. Return the modified chat text.

Use this callback to strip data unnecessary for the module and to retrieve or add required chat data.

#### Validation and autofix

Receives `(triggerId, Lightboard response text)`. Return nothing or throw an error. Begin recoverable validation errors with `InvalidOutput: `.

If the callback throws an error beginning with `InvalidOutput: `, the backend tries to fix the output with another LLM request.

#### Before output

##### Pure modules (default)

This section applies to `sideEffect: false` modules.

Receives `(triggerId, Lightboard response text)`. Return the modified response text.

Return a non-empty string. Returning `nil` or an empty string fails output processing. During automatic generation, the backend reports the error and emits an `<lb-lazy>` placeholder. During rerolls and interactions, the backend restores the original chat and reports the error.

Use this callback to remove unnecessary text, parse and save response data, or edit the response.

##### Side effect modules

This section applies to `sideEffect: true` modules.

Receives `(triggerId, Lightboard response text, full target chat text, target chat index)`. Return `(edited full target chat text, a string to append to the LBDATA block)`:

Return a non-empty edited chat text as the first value. Returning `nil` or an empty string as the first value fails output processing. The second LBDATA value is optional and may be `nil` or an empty string.

```lua
local function main(tid, output, fullChatContent, index)
  local data = parse(output)
  return editContents(data, fullChatContent), '<lb-lazy id="my-module" />'
end

return main
```

#### Reroll and interaction mutation

The `{identifier}.lb.onMutation` callback receives `(triggerId, action, full chat text)` immediately before a reroll or interaction writes the final chat text. The `action` value is either `reroll` or `interaction`.

Return the complete chat text to write. Use this callback only for edits that must run after the generated data has been inserted into the target chat.

## Prelude: Lightboard stdlib

The backend provides core utilities from string manipulation, XML node queries, HTML building (`h`), to more Risuai-specific APIs such as lorebook loading.

Begin Lua code with the following setup to use the standard library:

```lua
local triggerId = ''

local function setTriggerId(tid)
  triggerId = tid
  if type(prelude) ~= "nil" then return end
  local source = getLoreBooks(triggerId, 'lightboard-prelude')
  if not source or #source == 0 then
    error('Failed to load lightboard-prelude.')
  end
  load(source[1].content, '@prelude', 't')()
end
```

Call `setTriggerId()` before any other logic in every Risuai callback, including callbacks registered through `listenEdit()`.

> [!NOTE]
> The Lightboard Backend provides `prelude` to Lightboard callback functions, so those functions do not need the setup above.

Read [Lightboard Prelude](000-prelude.md) for more.

## Lightboard Frontend Best Practices

- Set `friendlyName` to a concise user-facing module name. Keep `identifier` as the stable machine-readable ID.
- Use a clearly identifiable identifier
- Use a structured data format, preferably JSON, TOON, or CSV
- Define the data format clearly in `.lb.format`
- Provide a realistic data example in `.lb`, including a wrapper tag whose name matches the identifier
- Define the role clearly in `.lb.job`
- Limit the rendering distance to improve initial performance
- Provide an option to exclude the data from the main model context
- Remove everything except the wrapper tag in `.lb.onOutput`
- Provide `.lb.onValidate` for automatic fixes

### Built-in icons

All icons are 15x15 `<svg>`.

- `<lb-comment-icon>`: A speech bubble.
- `<lb-reroll-icon>`: A turning arrow.
- `<lb-trash-icon>`: A diagonal cross.
- `<lb-pin-icon>`: A pin icon. Set `pinned="true"` fills it.

### Limiting context inclusion

Assume the `identifier.context` toggle exists and is defined as `identifier.context=Include context`:

```
---
ableFlag: false
comment: Ignore Old
flag: gmsi<order 1>
type: editprocess
---
IN:
<my-module(?:\s+[^>]*)?>(?:[\s\S]*?)<\/my-module>\n?
OUT:
{{#when::keep::{{? {{getglobalvar::toggle_my-module.context}} == 1}}}}{{#when::keep::{{greater_equal::{{chat_index}}::{{? {{lastmessageid}} - 5}}}}}}$&{{/when}}{{/when}}
```

The user can then choose to include or exclude the module's data, and old data will be evicted from the context.

### Removing unrendered content

Lua runs before the regexes. Use a regex to remove a node from the display if Lua skips or fails to render it.

```
---
ableFlag: false
comment: Hide Unparsed
flag: g
type: editdisplay
---
IN:
<my-module(?:\s+[^>]*)?>(?:[\s\S]*?)<\/my-module>\n?
OUT:
```

### Limiting rendering distance

```lua
listenEdit(
  "editDisplay",
  function(triggerId, data, meta)
    if meta and meta.index ~= nil then
      local position = meta.index - getChatLength(triggerId)
      -- Distance: 10 chats
      if position < -10 then
        return data
      end
    end

    return render(data)
  end
)
```

### Removing everything except the data block

This prevents unnecessary text, such as preambles generated by the auxiliary model, from entering the data.

```lua
-- my-module.lb.onOutput
local function main(triggerId, output)
  if not string.find(output, '<identifier', 1, true) then
    return nil
  end

  if not string.find(output, "</identifier>", 1, true) then
    output = output .. '\n</identifier>'
  end

  return prelude.removeAllNodes(output, { 'identifier' })
end

return main
```

### Validation for autofix

This code gets the tag content, tries to parse it as JSON, and throws an `InvalidOutput` error if parsing fails.

Use validation also to check field existence, types, and value formats.

```lua
-- my-module.lb.onValidate
local function main(triggerId, output)
  local node = prelude.queryNodes('identifier', output)
  if #node == 0 then
    error('InvalidOutput: Missing <identifier> node.')
  end

  local success, content = pcall(json.decode, node[1].content)
  if not success then
    error('InvalidOutput: Invalid JSON format. ' .. tostring(content))
  end
end

return main
```
