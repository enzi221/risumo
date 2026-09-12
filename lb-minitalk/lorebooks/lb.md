# Simulation details

## About the messenger

MiniTalk: A one-to-one or group messaging device within the RP world, not restricted to electronic ones.

Narrative, universe, the messenger and its users should all be depicted as real figures. Users don't treat narrative, universe, themselves and others as novel charaters or game.

Generate one chat room visible to the viewpoint character, using the current narrative and established messenger history.

## Viewpoint

{{#when::keep::{{and::{{notequal::{{getglobalvar::toggle_lb-minitalk.pov}}::null}}::{{greater::{{length::{{trim::{{getglobalvar::toggle_lb-minitalk.pov}}}}}}::0}}}}}}
Use {{getglobalvar::toggle_lb-minitalk.pov}} as the viewpoint character.
{{:else}}
Use {{user}} as the viewpoint character.
{{/when}}

Include the viewpoint character in the participant list even when that character sends no messages. Set `pov` to that participant's ID. Keep participant IDs stable when continuing an established room. Set each participant's `name` to a messenger nickname that each character would choose, reflecting personality and habits. Reuse established nicknames across rooms. Treat the viewpoint as ownership of the messenger, not permission to invent the owner's actions.

{{#when::{{getglobalvar::toggle_lb-minitalk.speak}}::is::1}}
Allow new outgoing messages from the viewpoint character. Match the character's personality, knowledge, relationships, and availability. Leave decisions that would advance or resolve the current narrative scene pending.
{{:else}}
Generate no new outgoing messages from the viewpoint character. Reproduce an outgoing message only when the narrative explicitly establishes that the character sent it, or the user explicitly directs that exact message to be sent. Preserve the supplied content without adding wording. Spoken dialogue, thoughts, intentions, and unsent drafts are not sent messages. Do not imply an unshown outgoing message through another participant's reply, quotation, or acknowledgment. Let incoming messages remain unanswered.
{{/when}}

## Chat room

{{#when::{{getglobalvar::toggle_lb-minitalk.room}}::is::1}}
Generate a one-to-one room with exactly two participants, including the viewpoint character.
{{:else}}
{{#when::{{getglobalvar::toggle_lb-minitalk.room}}::is::2}}
Generate a group room up to ten participants, including the viewpoint character.
{{:else}}
Choose a one-to-one or group room appropriate to the context, with two to ten participants including the viewpoint character.
{{/when}}
{{/when}}

Key figures are characters provided in the universe settings.

{{#when::lb-minitalk.characters::tis::0}}
Besides the required viewpoint character, select participants appropriate to the context only from key figures.
{{/when}}
{{#when::lb-minitalk.characters::tis::1}}
Besides the required viewpoint character, select participants only from characters present in the current narrative scene.
{{/when}}
{{#when::lb-minitalk.characters::tis::2}}
Besides the required viewpoint character, select participants only from key figures present in the current narrative scene.
{{/when}}
{{#when::lb-minitalk.characters::tis::3}}
Select participants appropriate to the context.
{{/when}}

Use a practical room name the viewpoint character would recognize. Select contacts with a plausible relationship and reason to communicate. Keep membership consistent with established history. Include silent members without forcing every participant to speak.

## Conversation

- Write a plausible slice of recent message history, not a miniature scene or a narrative summary divided into bubbles. The visible messages may begin mid-topic, end without a reply, or leave the immediate subject unfinished. Let messages respond to earlier messages or cross briefly in active groups.
- Mix context-relevant conversation with ordinary concerns appropriate to the contacts: errands, food, work, plans, gossip, or shared interests. Keep the current scene from becoming every participant's only topic.
- Express personality and relationships through wording, message length, punctuation, and response habits. Prefer each participant's raw messaging cadence over edited dialogue. Use short bursts, fragments, corrections, slang, or restrained formality where the individual would use them. Omit subjects, connective wording, terminal punctuation, or complete endings where that participant naturally would. Do not add context that the recipients already know.
- Match each participant's texting style to age, familiarity, hierarchy, mood, and the world's social conventions. Avoid giving everyone the same slang or polished prose. Let emotional changes affect an established style without erasing it.
- Express reactions to sensitive disclosures through each recipient's values, relationship, and circumstances. Preserve plausible discomfort, disagreement, hesitation, or support rather than forcing uniform acceptance or condemnation.
- Put only sent content in messages. Convey pauses through pause rows. Keep each text message to one immediate communicative beat. Split a follow-up, correction, reaction, or change of thought into a separate message where that participant would naturally send it separately.
- Continue established relationships, nicknames, and unresolved topics. Generate new messages rather than repeating previous messenger output. Reproduce an established sent message only when needed to make a new exchange intelligible.
- Use as many messages as the visible moment naturally contains. Treat six to twelve text messages as a typical range, not a target or a complete conversational arc. Use fewer, including zero, when availability, elapsed time, or the outgoing-message restriction leaves little to show. Do not manufacture a reply to meet a length target.

## Knowledge and timing

Limit each participant to information the participant could have witnessed, learned, or received before sending the message. Keep private events private unless a plausible disclosure has occurred.

Show elapsed time between parts of an exchange with a pause row.

Keep all board content within the narrative's current endpoint. Treat plans, requests, orders, and intentions as statements made, not actions performed. Leave pending choices, responses, and outcomes unresolved until the narrative establishes them. Express predictions as speculation, without inventing sightings, reports, or aftermath that imply the predicted event has occurred.

Respect access to a messaging medium and the sender's availability. Characters occupied by urgent events need not reply. Participants speaking face to face ordinarily switch to spoken conversation rather than texting each other; allow texting only when the context supplies a reason. Keep technology, vocabulary, and communication speed compatible with the setting.

## Message types

Write every message as `sender|type|time|content`. Set `type` to `text` for ordinary sent text. Keep `content` a string for every message type.

### Pause

Set `type` to `pause` to show elapsed time between messages. Write `-` in both `sender` and `time`. Write a concise elapsed-time expression such as `10분 후`, `잠시 후`, or `다음 날` in `content`. Use a pause only when the gap is significant and helps the reader understand the exchange.

### Skip

Set `type` to `skip` when an unknown amount of conversation over an unknown duration is omitted between retained messages. Write `-` in `sender`, `time`, and `content`. Use a skip only when the omission itself helps the reader understand that the retained messages are not consecutive. Use a pause instead when the elapsed duration is known.

### Membership events

Set `type` to `invited` for an invitation or `exit` for a departure. Set `sender` to `-` and `content` to the affected participant's ID, not a name or sentence. Use the same immutable `time` labels as other non-pause rows. Record only membership events established by the context.

Include the referenced participant in `participants` before adding the event. Retain participant records referenced by earlier messages or events after a departure. Treat an `exit` event as ending that participant's activity in the room until a later `invited` event.

An `invited` event for the viewpoint character may appear as the first message row. Do not place an `invited` event for the viewpoint character after the first message row.

<!-- lb-minitalk-cons-guideline -->

<!-- lb-minitalk-openblock-guideline -->

## Output

Output exactly one `<lb-minitalk>` element containing a TOON object with `keyFigures`, `messages`, `name`, `participants`, and `pov`.

- Use two ASCII spaces per indentation level, explicit array lengths, and `|` as the table delimiter.
- Encode every line break inside a field value as `\u000A`. Use neither `\n` nor literal line breaks inside field values.
- Quote strings containing `|`, quotes, or escape sequences with double quotes. Escape embedded double quotes and backslashes. Quote strings that would otherwise parse as numbers, booleans, or null.
- Write participant table rows directly as `id|name`, without a leading `- `. Use unique participant IDs and reference those IDs in `sender` and `pov`.
- Write key-figure table rows directly as `keyFigure|nickname|note`, without a leading `- `.
- Write message table rows directly as `sender|type|time|content`, without a leading `- `. The `time` field is immutable. Use only `오래전`, `얼마 전`, or `방금` for ordinary messages. Reserve `신규` for later interactions and do not use it in this output. Write `-` in the fields required by pause and skip rows.
- For an empty exchange, write `messages[0|]:` and retain the room name, participant list, and viewpoint.

NO REPEAT PREVIOUS MINITALK DATA. Introduce a new room, or add later messages to the previous one without including content from past data.

## Example

Each leading `⇥` represents one TOON indentation level of exactly two spaces. Do not output `⇥`; use two ASCII spaces for each indentation level.

```toon
<lb-minitalk>
messages[6|]{sender|type|time|content}:
⇥p2|text|얼마 전|아직 회사야
⇥p2|text|얼마 전|나 먼저 감
⇥p2|text|얼마 전|충전기 안내 데스크에 맡겨둠
⇥p2|text|얼마 전|아
⇥p2|text|얼마 전|1층 말고 2층
⇥p2|text|방금|찾으면 말해줘
name: 민지
participants[2|]{id|name}:
⇥p1|퇴근시켜줘
⇥p2|귤두개
pov: p1
keyFigures[1|]{keyFigure|nickname|note}:
⇥민지|귤두개|모두에게 짧게 연속 전송하며 정정은 새 메시지로 보냄
</lb-minitalk>
```

## Key figures

Write key-figure state updates in the room's `keyFigures` array. Give each entry `keyFigure`, `nickname`, and `note` strings.

- Set `nickname` to the exact participant nickname and `keyFigure` to the corresponding character name or identity from the universe settings.
- Include only major characters provided in the universe settings. Exclude unnamed extras.
- Add an entry only when the major character is absent from the preserved state or the character's nickname or note changed.
- When a preserved character's nickname or note changes, add the replacement entry with the exact preserved `keyFigure` string.
- Every major character who sends a message in the room must already have a current preserved entry or appear in `keyFigures`. A participant record or membership event alone does not qualify.
- Write a concise `note` describing observable messaging habits such as message length, consecutive sends, omissions, punctuation, corrections, and response timing. Record only habits supported by the character or established messages.
- When a `note` describes speech or messaging style, state whether the style applies to everyone or only to named people or groups.
- Output `[0|]:` when there are no updates.
- Treat mappings as continuity reference, not as identity disclosures to participants. Limit each participant's knowledge to information available in the world.

{{#when::keep::{{? {{length::{{trim::{{getvar::lb-minitalk.keyfigures}}}}}} > 0}}}}
Preserved state from previous rooms:

<previous-key-figures>
{{getvar::lb-minitalk.keyfigures}}
</previous-key-figures>

Use the preserved state as a continuity reference. Keep unchanged mappings out of `keyFigures`.
{{/when}}
