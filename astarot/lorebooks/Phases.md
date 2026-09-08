@@depth 0

{{#when::toggle::astarot-enabled}}
<tarot-instruction>

{{#when::toggle::astarot-reader-only}}
Apply this reading procedure only when Astarotte is the reader.
Do not introduce Astarotte solely to perform this procedure.
{{:else}}
Apply this reading procedure to any character acting as the reader.

## Reader Knowledge

Treat the character currently interpreting a card as the reader, regardless of who brought, shuffled, or drew the cards. Assess each speaker separately when another character joins or takes over the interpretation; do not transfer the previous reader's knowledge to the new reader.

Before writing each reader's interpretation, apply these checks in order:

1. Determine whether the current reader knows anything about tarot from the character's established knowledge and experience. Do not infer knowledge from handling the cards or taking the reader's role. Allow for no tarot knowledge at all, including characters who brought the cards simply because they like them.
2. If the reader knows nothing about tarot, choose how the character would make sense of the card, such as reacting to its picture, following a vague feeling, or making personal associations. Ground the interpretation in that approach rather than supplying conventional tarot meanings as the character's knowledge. Allow the character to guess, bluff, or admit ignorance according to the character's personality.
3. If the reader knows tarot, determine the extent and limits of that knowledge. Keep partial knowledge fragmentary, allowing uncertainty, misremembered meanings, and outright mistakes. Connect symbolism, spread positions, and the question's context only to the extent supported by the reader's knowledge and experience.

Write the resulting narrative and dialogue only after these checks. Keep the checks out of the output, and distinguish the character's confidence from the accuracy of the interpretation.
{{/when}}

## Card Images

For every card shown or interpreted during a reading, wrap all associated narrative and dialogue in this block:

```text
[astcard|{card}]

{narrative and dialogue for the card}

[/astcard]
```

- card: 0-21 for major arcana, suit/1-14 for minor arcana where suit is wands, coins, cups, or swords
- `i` suffix: reversed

The block renders the card image beside its text. Use one block per card. Do not repeat the card name outside character dialogue. Write the block body as plain markdown, including multiple paragraphs separated with `\n\n`, as you would normally output. {{#when::toggle::astarot-character}}{{#when::toggle::astarot-asset}}BUT NOT `[astimg]`: NEVER display Astarotte images within `[astcard]`! Layout will break!{{/when}}{{/when}}

## Interactive Tarot Playing Guideline

### On Reader Turn

When the reader prepares tarot cards for someone, have the reader invite them to pick the cards.

After the invitation, if it makes sense that the user to participate and pick the cards themselves, you MUST use the following command and STOP progressing narrative immediately. Hand the turn over to the user so they may pick the cards. If not, such as when the user has explicitly stated that someone (already) picked their cards, or the character being read is not the user's current focus, NEVER STOP right before the card picking, else the user would be left with confusion.

```
<tarot-spread deck="...">
[
  {
    "position_meaning": "...",
    "rot": 0.0,
    "x": 0.0,
    "y": 0.0
  }
]
</tarot-spread>
```

You have to define a tarot spread with the command.

- Output a JSON array inside `<tarot-spread>`.
- deck attribute: One of enum: major, full.
  - major: Only use major arcana.
  - full: Use full 78 cards (major + minor).
- x, y: Where to place the card on the floor. 0.0-1.0, inclusive.
  - Try to center the cards, horizontally and vertically.
- rot: Rotation of the card. 0.0-360.0, inclusive. Emulate natural card placement with subtle rotations. Avoid 180deg as it might be mistaken as reversed card.
- position_meaning: Write a concise noun phrase describing what the card represents. Use the user's language because the interface displays this value.
- Close `</tarot-spread>`.

Example:

<tarot-spread deck="major">
[
  {
    "position_meaning": "The Past",
    "rot": 358.0,
    "x": 0.2,
    "y": 0.5
  },
  {
    "position_meaning": "The Present",
    "rot": 2.0,
    "x": 0.5,
    "y": 0.5
  },
  {
    "position_meaning": "The Future",
    "rot": 357.0,
    "x": 0.8,
    "y": 0.5
  }
]
</tarot-spread>

Note that you should not wrap the command in a code fence.

Depending on the request, topic, and the reader's characteristics, define a suitable spread consisting 1-10 cards, either well-known, obscure, or even custom. Prefer major deck when the spread has 3 or less cards, to avoid overwhelming user.

It will also present tarot card picker interface to the user. Depict the deck as split into two fanned-out piles, as the interface will present itself that way. In the user's turn, they will include their chosen cards. Wait for the user turn.

### On User Turn

If user included `<tarot-selection>`, it indicates that they've chosen their cards. The cards are represented in their index form.

Example:

<tarot-selection deck="major">
1,2,3
11,swords/5i,8
</tarot-selection>

- First line: Where card located in the shuffled deck (1-based index), order = user selection.
  - Example: 1,2,3 means the user picked the very first three cards in the shuffled deck sequentially. Utilize this in the narrative, e.g. it means either {{user}} picked cards haphazardly or was guided by certain fate.
- Second line: Card identifiers, index form.
  - 0 (The Fool) to 21 (The World) for major arcana
  - suit/1-14 for minor arcana
    - 11: P, 12: N, 13: Q, 14: K
    - Example: wands/1, coins/14
  - `i` suffix = reversed

</tarot-instruction>
{{/when}}
