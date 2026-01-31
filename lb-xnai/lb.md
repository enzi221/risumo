# Tagging Details

There are three key components you need to tag: Camera, Scene, and Characters. And two types of images: Scenes and Key Visual.

## Components

### Common Rules

All tags MUST depict a single, static visual instant—a snapshot in time.

Use common, objective, generic image board (Danbooru) tags, not abstract or specific terms unsuitable for _data labeling_.

{{#when {{and::{{? {{length::{{trim::{{getglobalvar::toggle_lb-xnai.focus}} }} }} > 0 }}::{{? {{getglobalvar::toggle_lb-xnai.focus}} != null }}}} }}
User wants to focus on the character(s): "{{getglobalvar::toggle_lb-xnai.focus}}". Do not generate scenes for others.
{{/when}}

### Camera

#### Perspective

Include one. Also add `pov` or `dutch angle` if applicable.

- from above
- from behind
- from below
- from side
- high up
- sideways
- straight-on
- upside-down

#### Character Framing

Include one. Note that the final image will be in landscape orientation.

In order of increasing view, from face

- portrait (Face through shoulders)
- upper body (Face through torso)
- cowboy shot (Face through thighs)
- feet out of frame (Face to below knee)
- full body (Whole body)
- wide shot (Whole body from far away)
- very wide shot (Whole body from very far away)

In order of increasing view, from legs

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

Limit character count to {{dictelement::{"0":"3","1":"2","2":"1"}::{{getglobalvar::toggle_lb-xnai.characters}}}}. If more characters are present, tag only the most prominent. Note that out-of-frame characters do not count, such as only hands and `out of frame`, or when `pov`.

#### Location and Lighting

Start with either `interior` or `exterior`, then add specific tags such as `bedroom`, `classroom`, `forest`, `meadow`, `horizon`, etc. Add prominent props here: `computer`, `chair`, `table`, etc.

Add lighting related tags as well. `daylight, noon`, `sunset`, `night, 3::dark::`, `backlighting`, `sidelighting`, etc. Note the `dark` intensity tag. `dark` requires increased intensity.

### Characters

Each character needs appearance, attire, pose, expression, and action tag groups.

Always start with either `girl` or `boy` regardless of their age. Then age tags: `child`, `adolescent`, (fully grown adult) `male` or `female`, (above middle age) `mature male` or `mature female`, etc. The age tags are visible elements.

Age tag is strictly for appearance only. If the character is middle-aged woman but looks like a teen, `adolescent` would be more appropriate than `mature female`.

#### Appearance

Properties are yours to follow (see Required), but tags are mere examples. Use your talent as a data labeler.

- Hair
  - Required unless head out of frame: Length (very long to short; hair bun is an exception), color, style, bangs. `long straight blue hair`, `white single hair bun`, `medium black curly hair` combined with `choppy bangs`, `swept bangs`
  - Optional properties: `ahoge`, `braid`
- Eye:
  - Required unless closed or head/eyes out of frame, even when `from behind`: Color. `blue eyes`, `red eyes`
  - Optional properties: `tareme`, `tsurime`, `jitome`, `empty eyes`, `dashed eyes`, `constricted pupils`
- Body type: If worth tagging. `slim`, `slender`, `chubby`, `muscular` or `toned`, `fat`
  - If female, breast size: `small/medium/large/huge breasts`
- Other facial features if any: `freckles`, `dark skin`, `facial hair`
- Attire: Color and type of each clothing item, with optional properties. Tag items visible in the scene only. If the body part would go out of frame, do not include the item.
  - If naked, `naked` is always required.
  - Disassemble uniforms into explicit parts.
  - Headwear: `red hat`, `blue headband`
  - Top: `topless`, `white shirt`, `deep green jacket`, `gray bra`. Optionally `see-through`, `sideboob`, `cropped`, `sleeveless`
  - Bottom: `bottomless`, `pale gray jeans`, `red long skirt`, `black shorts`. Optionally `side slit`, `lifted skirt`
  - Footwear: `white ankle socks`, `black sneakers`, `bare feet`
  - Accessories: `golden rimless glasses`, `blue gem necklace`, `black backpack`
- Expression: `annoyed`, `angry`, `drunk`, `embarrassed`, `indifferent`, `blush`, `grin`, etc. Can be combined.
- Action: What the character is doing by themselves, to others, or to objects. `standing`, `sitting`, `laying on back`, `raised hand`, `trembling` (whole body), `hands together`, `holding sword`. Clear visual tags only. No generic tags such as `fighting` (how?), `playing` (what?).
  - Eye focus: `looking at viewer`, `looking at other`, `looking away`, `closed eyes`
  - Interactions between characters: MUST apply ONE OF action modifiers:
    - `mutual#` for mutual actions, `mutual#kissing`, `mutual#holding hands`.
    - `source#` if the character is performing a directional action, `source#patting head`. The other character must have the corresponding `target#` tag.
    - `target#` if the character is receiving a directional action, `target#patting head`. The other character must have the corresponding `source#` tag.{{#when::keep::toggle::lb-xnai.nsfw}}
  - Explicit log: Include all actions being performed with high details. `sex from front` (Not just `sex`, specify direction), `imminent penetration`, `embracing`, etc.{{/when}}
- Exposed body parts: Only if within the frame. `armpits`, `clavicle`, `cleavage`, `navel`, `thighs`, `buttocks`, {{#when::toggle::lb-xnai.nsfw}}`nipples`, `pussy`, `anus`, `penis`{{/when}}...

If a chracter lacks details in their description, fill in missing details creatively but within settings.

## Image Types

As a creative photographer, you will label images which can attract viewers while artistically satisfying.

Important note: You are to describe the LAST LOG ENTRY OF THE ASSISTANT (Log #N) only.

### Key Visual

The main promotional image of the log entry. Should encompass the overall theme of the log or the most important moment. Can be environment only (`no human`) if surroundings are more important, or there are no characters present.

Key Visual should be boldly produced like a magazine cover. It should be distinct from all other Scenes, in composition, characters, environment, or anything.

### Scene

An individual image within the log entry. Each scene should represent a distinct moment or setting relevant to the log's narrative with at least one key character. Prefer closer shots (cowboy shot, upper or lower body) rather than wide shots.

Scenes should capture the moments of interaction, emotion, or significant actions of the characters.

Key Visual will occupy the top, so the first scene should have some distance from Key Visual. Do not add scenes in the early part of the target log entry.

#### Slot

We've prepared slots where scenes can be placed: `[Slot #]`. Pick a slot number, and the scene will be placed there.

Since slots were placed mechanically, some slots might be unsuitable for scene placement, such as slots within out-of-prose contents. Avoid such slots.

Key visuals are placed at either the top or the bottom of the log entry. So scene placement should avoid those areas as well.

{{#when {{and::{{? {{length::{{trim::{{getglobalvar::toggle_lb-xnai.direction}} }} }} > 0 }}::{{? {{getglobalvar::toggle_lb-xnai.direction}} != null }}}} }}

## User Direction

User has provided explicit direction:

```
{{getglobalvar::toggle_lb-xnai.direction}}
```

The above direction precedes all previous instructions.

{{/when}}

# Example

```
<lb-xnai>
scenes[2]:
  - camera: cowboy shot
    characters[2]:
      girl, adolescent, long pink hair, red eyes, slender, small breasts, red silk off-shoulder dress, sitting on bed, hugging knees, head down, target#conversation
      girl, female, green braided hair, brown eyes, slender, medium breasts, maid uniform, white headband, black onepiece, black flat shoes, standing, smiling, source#conversation
    scene: 2girls, interior, bedroom, morning, daylight, sidelighting
    slot: 3
  - camera: ...
    characters[1]:
      ...
    scene: ...
    slot: ...
keyvis:
  camera: from above, upper body, tilted angle
  characters[1]:
    girl, adolescent, long pink hair, red eyes, slender, small breasts, red silk off-shoulder dress, laying on back, on bed, blush, raised arm, forearm on forehead, looking at viewer
  scene: 1girl, exterior, railing, night, 3::dark::
</lb-xnai>
```

- Use `<lb-xnai>`.
- Output in TOON format (2-space indent, array length in header). No `-` in front of simple arrays (`characters`).
- keyvis for key visual, scenes (optional) for scenes list.
- Close `</lb-xnai>`.

Generate {{dictelement::{"0":"0-1","1":"0-3","2":"1-3","2":"1-5","3":"2-5"}::{{getglobalvar::toggle_lb-xnai.scene.quantity}}}} scenes.

Do not use slots placed out of prose content.

You must only make keyvis and scenes for the last log entry, nothing previous.

Everything must be in English.
