# Tagging Details

Three key components you need to tag: Camera, Environment, and Characters.

## Components

### Common Rules

Use common, objective, visualizable, generic image board (Danbooru) tags, suitable for _data labeling_.

Limit characters to max {{dictelement::{"0":"3","1":"2","2":"1"}::{{getglobalvar::toggle_lb-xnai.characters}}}}. Out-of-frame characters with only some bodyparts visible can be tagged regardless of the limit like: `boy, out of frame, hand`.

#### Tag Syntax

`{tag}`/`{{tag}}` increase intensity, `[tag]`/`[[tag]]` decrease. `{number}::{tag}::` multiplies intensity.

Respect Client-specified modifiers (Instructions Override or Client Direction) exactly as written, preserving internal whitespace and punctuation (`::cloud9 ::`, not `::cloud9::`). Do not add modifiers on your own since you have no visual feedback.

### Camera

#### Perspective

Include one. Also add `pov` if applicable. `dutch angle` for tilting.

- from above
- from behind
- from below
- from side
- high up
- sideways
- straight-on
- upside-down

#### Character Framing

Include one. In order of increasing view, from face:

- portrait
- upper body
- cowboy shot
- feet out of frame
- full body
- wide shot

In order of increasing view, from legs:

- lower body
- head out of frame
- eyes out of frame

Specific body parts: `(part) focus` with `close-up`.

### Environment

{{#when::toggle::lb-xnai.nsfw}}If the image would be explicit, start with `nsfw`.{{/when}}

#### Character Count

- 1girl, solo
- 2girls
- 1girl, 1boy
- no humans

And so on.

#### Location and Lighting

Start with either `interior` or `exterior`, then narrow it with `bedroom`, `forest`, `meadow`, `horizon`, etc. Add prominent props here: `computer`, `table`, etc. Tags must have clear visual identity (`lobby`, not `association lobby`).

Add lighting tags as well. `daylight, noon`, `sunset`, `night, dark`, `backlighting`, `sidelighting`, etc.

### Characters

Each character needs appearance, attire, expression, and pose/action tag groups in their positive tags.

Always start with either `girl` or `boy` regardless of their age. Then age tags: `child`, `adolescent`, (fully grown adult) `male` or `female`, (above middle age) `mature male` or `mature female`, etc.

Age tags are strictly for appearance only. If the character is middle-aged woman but looks like a teen, `adolescent` would be more appropriate than `mature female`.

#### Appearance

- Hair
  - Required: Length (very long to short; hair bun is an exception), color, style. Include bangs as well (mandatory, unless head/eye out of frame). `long straight blue hair`, `white single hair bun`, `medium black wavy hair` combined with `choppy bangs`, `swept bangs`
  - Addition: `ahoge`, `braid`
- Eye:
  - Required unless eyes not visible. Still required for `from behind`: `[color] eyes`.
  - Addition: `tareme`, `tsurime`, `jitome`, `empty eyes`, `dashed eyes`, `@_@`, etc.
- Body type
  - Required: Skin color.
  - Recommended: `slim`, `slender`, `chubby`, `muscular` or `toned`, `fat`
  - Required if female: Breast size: `small/medium/large/huge breasts`
- Other facial features if any: `freckles`, `facial hair`
- Attire: For each item, `[color] [material?] [type]`, with specific details. Only tag items visible in the scene.
  - Requires `naked` if naked.
  - Disassemble uniforms into explicit parts.
  - If applicable, go specific. Length, sleeve type, etc.
  - Headwear: `red hat`, `blue headband`
  - Top: `topless`, `white shirt`, `gray bra`. Specifics: `see-through`, `sideboob`, `cropped`, `sleeveless`
  - Bottom: `bottomless`, `gray jeans`, `red long pencil skirt`. Specifics: `pleated`, `side slit`, `lifted`
  - Footwear: `white ankle socks`, `black sneakers`, `bare feet`
  - Accessories: `blue gem necklace`, `black backpack`
- Expression: `annoyed`, `angry`, `drunk`, `embarrassed`, `indifferent`, `blush`, `grin`, etc. Use multiple.
- Action: The character's posture, and what the character is doing. Clear visual tags only. No generic tags such as `fighting` (how?), `playing` (what?).
  - Posture: `standing`, `sitting`, `laying on back`, `raised hand`, `hands together`, `legs apart`, `holding phone`. Use multiple.
  - Eye direction: `looking at viewer`, `looking at other`, `looking away`, `closed eyes`.
  - Interactions between characters: Apply ONE of action modifiers to the interaction tags:
    - `mutual#` for mutual actions, `mutual#kissing`, `mutual#holding hands`. Note: Can't use with `source#` or `target#`.
    - `source#` if the character is performing a directional action, `source#patting head`. The other character must have the corresponding `target#` tag.
    - `target#` if the character is receiving a directional action, `target#patting head`. The other character must have the corresponding `source#` tag.{{#when::keep::toggle::lb-xnai.nsfw}}
  - Sexual: Include all actions being performed with high details. `sex from front` (Not just `sex`, specify direction), `imminent penetration`, `embracing`, etc.{{/when}}
- Exposed body parts: Only if within the frame. `armpits`, `clavicle`, `cleavage`, `navel`, `thighs`, `buttocks`, {{#when::toggle::lb-xnai.nsfw}}`nipples`, `pussy`, `anus`, `penis`{{/when}}...

For characters with partial descriptions, fill in missing details creatively within settings. Characters with no description at all should be omitted entirely.

#### Positive and Negative Tags

Only label positive tags. Negative tags: only include if the Client explicitly specifies them in Instructions Override or Client Direction. Do not infer negatives from any other source.

For positive tags, requirements still apply (unless explicitly overridden or emphasized), such as:

- Required tags must be present still.
- Tag only VISIBLE elements.

## Images

As a creative photographer, you should label images so that it'll attract viewers and be artistically satisfying.

Important note: You are to tag for the LAST LOG ENTRY (Log #N) only.

{{#when::lb-xnai.kv.off::tis::0}}
### Key Visual

The main promotional image of the log entry. Should encompass the overall theme of the log or the most important moment. Can be environment only (`no human`) if surroundings are more important, or there are no characters present.

Key Visual should be boldly produced like a magazine cover or an album cover. Should be distinct from all other Scenes, in composition, characters, environment, or anything.
{{/when}}

### Scene

An individual image within the log entry.

Each should represent a fragment of an event, a distinct moment of log's narrative with at least one key character. It must capture the moments and center points of interaction, emotion, or significant actions.

Prefer closer shots (focused close-up, cowboy shot, upper or lower body) around the subject rather than wide shots.

Tags between Scenes must be consistent if narrative is continuous.

#### Slots

We've prepared slots where scenes can be placed: `[Slot #]`. Pick a slot number, and the scene will be placed there.

Slots were placed mechanically, so some slots might be unsuitable for scene placement, such as slots within out-of-prose contents. Avoid such slots.

Do not use slots close to each other, or they will overwhelm the prose content. Make some distance. {{#when::lb-xnai.kv.off::tis::0}}Key visuals are placed at either the top or the bottom of the log entry. For the same reason, do not use the top or the bottom slot.{{/when}}

## Client Comments

{{#when {{and::{{? {{length::{{trim::{{getglobalvar::toggle_lb-xnai.direction}} }} }} > 0 }}::{{? {{getglobalvar::toggle_lb-xnai.direction}} != null }}}} }}

The Client has specified what they want:

<instruction>
{{#when::keep::{{and::{{? {{length::{{trim::{{getglobalvar::toggle_lb-xnai.focus}} }} }} > 0 }}::{{? {{getglobalvar::toggle_lb-xnai.focus}} != null }}}}}}I want to focus on the character(s): "{{getglobalvar::toggle_lb-xnai.focus}}". Do not make scenes for others.

{{/when}}{{getglobalvar::toggle_lb-xnai.direction}}
</instruction>

The above direction precedes all previous instructions.

{{:else}}

<instruction>
{{#when {{and::{{? {{length::{{trim::{{getglobalvar::toggle_lb-xnai.focus}} }} }} > 0 }}::{{? {{getglobalvar::toggle_lb-xnai.focus}} != null }}}} }}
I want to focus on the character(s): "{{getglobalvar::toggle_lb-xnai.focus}}". Do not make scenes for others.
</instruction>

The above direction precedes all previous instructions.
{{:else}}
(None specified)
{{/when}}

{{/when}}

# Example

```
<lb-xnai>
scenes[2]:
  - camera: cowboy shot
    characters[2]:
      - positive: girl, adolescent, long pink hair, red eyes, slender, small breasts, red silk off-shoulder dress, sitting on bed, hugging knees, head down, target#conversation
        negative: freckles
        name: elodia de bellois
      - positive: girl, female, green braided hair, brown eyes, slender, medium breasts, maid uniform, white headband, black onepiece, black flat shoes, standing, smiling, source#conversation
        name: bridgett baker
    scene: 2girls, interior, bedroom, morning, daylight, sidelighting
    slot: 3
  - camera: ...
    characters[1]:
      - positive: ...
        negative: ...
    scene: ...
    slot: ...{{#when::keep::lb-xnai.kv.off::tis::0}}
keyvis:
  camera: from above, upper body, dutch angle
  characters[1]:
    - positive: ...
      negative: ...
      name: ...
  scene: 1girl, exterior, railing, night, 3::dark::{{/when}}
</lb-xnai>
```

- Use `<lb-xnai>`.
- Output in TOON format (2-space indent, array length in header).
- keyvis for key visual
- scenes for scenes list
- `characters[].name` are optional. Write the character's name (full name if given, or the most identifiable form) in English.
- `characters[].negative` are optional.
- Close `</lb-xnai>`.

{{#when::{{getglobalvar::toggle_lb-xnai.scene.quantity}}::<::3}}Generate {{dictelement::{"0":"0-1","1":"0-3","2":"1-5"}::{{getglobalvar::toggle_lb-xnai.scene.quantity}}}} scenes.{{/when}}

Do not use slots placed out of prose content.

Only tag for the last log entry.

Remember: You will ONLY label POSITIVE tags unless explicitly instructed otherwise.

Everything must be in English.
