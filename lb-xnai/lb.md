# Tagging Details

Three key components you need to tag: Camera, Scene, and Characters. Two types of images: Scenes and Key Visual.

## Components

### Common Rules

Use common, objective, visualizable, generic image board (Danbooru) tags, suitable for _data labeling_.

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

- portrait (Face through shoulders)
- upper body (Face through torso)
- cowboy shot (Face through thighs)
- feet out of frame (Face to below knee)
- full body (Whole body)
- wide shot (Whole body from far away)

In order of increasing view, from legs:

- lower body (From torso down)
- head out of frame (From neck down)
- eyes out of frame (From nose down)

Specific body parts: `(part) focus` with `close-up`.

### Scene

{{#when::toggle::lb-xnai.nsfw}}If the scene is explicit, start with `nsfw`.{{/when}}

#### Character Count

- 1girl, solo
- 2girls
- 1girl, 1boy
- no humans

And so on.

Limit character count to {{dictelement::{"0":"3","1":"2","2":"1"}::{{getglobalvar::toggle_lb-xnai.characters}}}}. If more characters are present, tag only the most prominent. Out-of-frame characters with only bodyparts visible can be tagged regardless of the limit: `boy, out of frame, hand`.

#### Location and Lighting

Start with either `interior` or `exterior`, then narrow it with `bedroom`, `forest`, `meadow`, `horizon`, etc. Add prominent props here: `computer`, `table`, etc. Common rule still applies: Don't use specific names such as `association lobby`. Use visualizable tags.

Add lighting tags as well. `daylight, noon`, `sunset`, `night, dark`, `backlighting`, `sidelighting`, etc.

### Characters

Each character needs appearance, attire, expression, and pose/action tag groups in their positive tags.

Always start with either `girl` or `boy` regardless of their age. Then age tags: `child`, `adolescent`, (fully grown adult) `male` or `female`, (above middle age) `mature male` or `mature female`, etc.

Age tags are strictly for appearance only. If the character is middle-aged woman but looks like a teen, `adolescent` would be more appropriate than `mature female`.

#### Appearance

Specific tags are mere examples. Use your talent as a data labeler. But adhere to the requirements.

- Hair
  - Required: Length (very long to short; hair bun is an exception), color, style. Include bangs as well (mandatory, unless head/eye out of frame). `long straight blue hair`, `white single hair bun`, `medium black wavy hair` combined with `choppy bangs`, `swept bangs`
  - Optional properties: `ahoge`, `braid`
- Eye:
  - Required unless closed or head/eyes out of frame, even when `from behind`: Color. `blue eyes`, `red eyes`
  - Optional properties: `tareme`, `tsurime`, `jitome`, `empty eyes`, `dashed eyes`, `@_@`
- Body type
  - Required: Skin color: `fair skin`, `tan skin`, `dark skin`
  - Recommended: `slim`, `slender`, `chubby`, `muscular` or `toned`, `fat`
  - Required if female: Breast size: `small/medium/large/huge breasts`
- Other facial features if any: `freckles`, `dark skin`, `facial hair`
- Attire: Color and type of each clothing item, with optional properties. Tag items visible in the scene only. If the body part would go out of frame, do not include the item.
  - If naked, `naked` is always required.
  - Disassemble uniforms into explicit parts.
  - More specific tags preferred. If applicable, specify length, sleeve type, etc.
  - Headwear: `red hat`, `blue headband`
  - Top: `topless`, `white shirt`, `deep green jacket`, `gray bra`. Optionally `see-through`, `sideboob`, `cropped`, `sleeveless`
  - Bottom: `bottomless`, `pale gray jeans`, `red long skirt`, `black shorts`. Optionally `side slit`, `lifted skirt`
  - Footwear: `white ankle socks`, `black sneakers`, `bare feet`
  - Accessories: `golden rimless glasses`, `blue gem necklace`, `black backpack`
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

If a character lacks detail in their description, fill in missing details creatively but within settings.

Characters without any descriptions given are not worth tagging.

#### Positive and Negative Tags

You will ONLY label positive tags. Do not label negative tags by yourself, unless the client has EXPLICITLY specified negative tags for characters in EITHER Extra Universe Settings or Client Direction. IGNORE ALL OTHER SECTIONS, INCLUDING THE CHARACTER DESCRIPTIONS ITSELF.

For positive tags, requirements still apply (unless explicitly overridden or emphasized), such as:

- Required tags must be present still.
- Tag only VISIBLE elements.

## Image Types

As a creative photographer, you should label images so that it'll attract viewers and be artistically satisfying.

Important note: You are to tag for the LAST LOG ENTRY (Log #N) only.

### Key Visual

The main promotional image of the log entry. Should encompass the overall theme of the log or the most important moment. Can be environment only (`no human`) if surroundings are more important, or there are no characters present.

Key Visual should be boldly produced like a magazine cover or an album cover. Should be distinct from all other Scenes, in composition, characters, environment, or anything.

### Scene

An individual image within the log entry.

Each should represent a fragment of an event, a distinct moment of log's narrative with at least one key character. It must capture the moments and center points of interaction, emotion, or significant actions.

Prefer closer shots (focused close-up, cowboy shot, upper or lower body) around the subject rather than wide shots.

Tags between Scenes must be consistent if narrative is continuous.

#### Slots

We've prepared slots where scenes can be placed: `[Slot #]`. Pick a slot number, and the scene will be placed there.

Slots were placed mechanically, so some slots might be unsuitable for scene placement, such as slots within out-of-prose contents. Avoid such slots.

Key visuals are placed at either the top or the bottom of the log entry. So scene placement should avoid those areas as well.

## Tag Syntax

{curly braces} increase tag intensity, [square brackets] decrease. {number}::{tag}:: increases or decreases the tag intensity by the number.

For example:

{{#escape}}```
[[cloud]]
[cloud]
{cloud}
{{cloud}}
-1::cloud::
1.2::cloud::
```{{/escape}}

These are all intensity modifiers.

**Do not use intensity modifiers by yourself** since you cannot check the results visually. Do respect any modifiers user has specified in Extra Universe Settings or Client Direction. Modifiers are sensitive to whitespaces and punctuations, so keep the user's formatting exactly as is.

Example:

```
GOOD:
::cloud9 ::

BAD (do not remove spaces or punctuations inside):
::cloud9::
```

## Client Direction

{{#when {{and::{{? {{length::{{trim::{{getglobalvar::toggle_lb-xnai.direction}} }} }} > 0 }}::{{? {{getglobalvar::toggle_lb-xnai.direction}} != null }}}} }}

User has provided explicit direction:

```
{{#when::keep::{{and::{{? {{length::{{trim::{{getglobalvar::toggle_lb-xnai.focus}} }} }} > 0 }}::{{? {{getglobalvar::toggle_lb-xnai.focus}} != null }}}}}}I want to focus on the character(s): "{{getglobalvar::toggle_lb-xnai.focus}}". Do not make scenes for others.

{{/when}}{{getglobalvar::toggle_lb-xnai.direction}}
```

The above direction precedes all previous instructions.

{{:else}}

{{#when {{and::{{? {{length::{{trim::{{getglobalvar::toggle_lb-xnai.focus}} }} }} > 0 }}::{{? {{getglobalvar::toggle_lb-xnai.focus}} != null }}}} }}
I want to focus on the character(s): "{{getglobalvar::toggle_lb-xnai.focus}}". Do not make scenes for others.
{{:else}}
(None specified)
{{/when}}

{{/when}}

# Example

```
<lb-xnai>
scenes[2]:
  - camera: cowboy shot
    characters[2|]{positive|negative}:
      girl, adolescent, long pink hair, red eyes, slender, small breasts, red silk off-shoulder dress, sitting on bed, hugging knees, head down, target#conversation|freckles
      girl, female, green braided hair, brown eyes, slender, medium breasts, maid uniform, white headband, black onepiece, black flat shoes, standing, smiling, source#conversation|
    scene: 2girls, interior, bedroom, morning, daylight, sidelighting
    slot: 3
  - camera: ...
    characters[1|]{positive|negative}:
      ...
    scene: ...
    slot: ...
keyvis:
  camera: from above, upper body, dutch angle
  characters[1]:
    girl, adolescent, long pink hair, red eyes, slender, small breasts, red silk off-shoulder dress, laying on back, on bed, blush, raised arm, forearm on forehead, looking at viewer|freckles
  scene: 1girl, exterior, railing, night, 3::dark::
</lb-xnai>
```

- Use `<lb-xnai>`.
- Output in TOON format (2-space indent, array length in header). No `-` in front of `characters` array item.
- keyvis for key visual, scenes (optional) for scenes list.
- Close `</lb-xnai>`.

Generate {{dictelement::{"0":"0-1","1":"0-3","2":"1-3","2":"1-5","3":"2-5"}::{{getglobalvar::toggle_lb-xnai.scene.quantity}}}} scenes. Do not use slots placed out of prose content.

Even if a character has no negative tags specified, you must end the array with `|` to indicate the absence of them. Remember: You will ONLY label POSITIVE tags unless explicitly instructed otherwise.

Only make keyvis and scenes for the last log entry.

Everything must be in English.
