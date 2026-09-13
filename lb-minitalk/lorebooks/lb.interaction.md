Your ultimate task: Update the last data block according to user direction and action. Keep new data consistent with the general guidelines and universe settings.

Action specifies what to do and which data to interact with. Other data are out of scope.

## Patch Operations

Set `time` to `신규` for every non-pause message added through `SendMessage` or `PassTime`. Keep every existing `time` value unchanged. For pause rows, keep `-` in `sender` and `time`, and express elapsed time only in `content`.

### SendMessage

How to continue the current room: Apply the direction as the next visible chat activity. Append plausible sequence that realizes the direction after all existing messages. Append plausible subsequent replies when participants' knowledge, availability, and elapsed time permit. Allow the activity to end without a reply. Express each change as the smallest practical set of patch operations.

Use the actor specified or implied by the direction. When the direction asks to send or communicate content but supplies no actor, use the room's viewpoint participant identified by `pov`. Treat contributions and events established by the direction as authorized. Apply the general speaker restrictions to additional invented contributions.

If the direction supplies exact message content, preserve that content. If the direction describes what a participant communicates rather than supplying exact wording, compose the message in that participant's voice. If the direction describes an exchange or event, realize the described activity instead of using the description as literal message content. Treat otherwise uninterpretable text as literal message content from `pov`. Interpret omissions as omitted content, not as literal text to send.

Use an existing participant ID as `sender` for sent messages. For `invited` and `exit` events, use `-` as `sender` and the affected participant ID as `content`. Add any new participant record before appending its event, and retain records referenced by room history. Add a pause row only when elapsed time helps explain the exchange without advancing the narrative beyond its current endpoint.

### PassTime

How to pass time: Continue the current room as time passes, without a user direction. Append only messages that participants would plausibly send on their own or in response to existing messages.

Choose a plausible brief interval required for meaningful additions. Show elapsed time in the `content` of a new pause row when useful. Keep existing messages unchanged and leave unrelated narrative actions and pending user choices unresolved. Keep the general restriction on invented outgoing messages. Allow silence instead of manufacturing activity; output an empty patch if neither a message nor a useful pause row is needed.

### Output

For `SendMessage` and `PassTime`, ignore the normal-generation output format. Output only a JSON Patch array wrapped in `<lb-minitalk-patch>`, without a complete `<lb-minitalk>` block. Apply the patch rules below.

The patch target is the object below, decoded from the last `<lb-minitalk>` data block:

```json
{
  "messages": [],
  "name": "room name",
  "participants": [
    { "id": "p1", "name": "self-chosen nickname" },
    { "id": "p2", "name": "contact nickname" }
  ],
  "pov": "p1"
}
```

- Use only `add`, `remove`, and `replace` operations.
- Use JSON Pointer paths with zero-based array indices.
- Use `/messages/-` to append each new message for `SendMessage` and `PassTime`.
- Apply operations in array order and write each path against the result of preceding operations.
- Keep the current room root.
- Use an empty array when passing time produces no new data.
- Include only operations required by the interaction. Keep untouched values out of the patch.
- Write strict JSON with double-quoted keys and strings without Markdown fences.
- Encode every line break in a JSON string as `\u000A`. Do not use `\n` or a literal line break inside a string.
- Write `messages` as an array of objects containing `content`, `sender`, `time`, and `type` strings. Write `participants` as an array of objects containing `id` and `name` strings. Keep `name` and `pov` strings.
- Use JSON string escaping for every message payload, including OpenBlocks, instead of TOON field escaping.

Example patch for appending a message:

```
<lb-minitalk-patch>
[
  {
    "op": "add",
    "path": "/messages/-",
    "value": {
      "content": "충전기 고마워. 이따 찾아갈게.",
      "sender": "p1",
      "time": "신규",
      "type": "text"
    }
  }
]
</lb-minitalk-patch>
```

## Replace

### ChangeRoom

How to change room: Replace the current room with a room matching the direction. Set the room name, participants, viewpoint, and messages together. Do not carry messages from the previous room into a different room unless user requested.

{{#when::lb-minitalk.preset::tis::1}}
Select speakers and a minor spoken exchange matching the direction within the established narrative circumstances.
{{:else}}
{{#when::lb-minitalk.preset::tis::2}}
Keep exactly one participant, the viewpoint character, and replace the subject of the soliloquy according to the direction.
{{:else}}
{{#when::lb-minitalk.preset::tis::3}}
Keep the viewpoint character and one to nine personified facets. Apply the direction to the inner subject and facets, retaining established facets where relevant.
{{:else}}
Follow the requested membership over the default room-size preference, within two to ten participants.
{{/when}}
{{/when}}
{{/when}}

Retain the general guidelines' form of conversation. Retain the configured viewpoint character unless the direction explicitly changes it.

If direction includes tone or manner, apply it within the participants' personalities and relationships. Reuse established contact identities and room history when available. Keep the room accessible to its viewpoint character and preserve the general knowledge, timing, and outgoing-message restrictions.

### Output

For `ChangeRoom`, follow the normal-generation `<lb-minitalk>` format and example. Output exactly one complete room block without a patch or surrounding text. Include the required `keyFigures` updates in the room. Use only `오래전`, `얼마 전`, or `방금` for every ordinary message's `time`. Write `-` in the fields required by pause and skip rows.
