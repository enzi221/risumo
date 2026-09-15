{{#when::lb-minitalk-picture.active::tis::1}}identifier=picture
Use for a picture attached by the sender. It could be a photo taken in the past or one taken just moments ago.

Describe the picture with common, objective, visualizable concepts, primarily as Danbooru-style tags. Replace role labels such as "Swordmaster outfit" with explicit visible clothing.

Write `content` on a single line as `setup and perspective § character 1 § ... § character N`. For this block, use English.

[Featured Character]

Featured Characters are characters written in the universe settings. Others are non-featured extra characters.

[Setup]

Start with the subject. Put the exact featured character count in `cast` with strictly number + girl(s) or boy(s).

- no people
- 1girl
- 2girls
- 1girl, 1boy

And so on. Represent anonymous background population with separate tags such as `crowd`. Then `interior` or `exterior`, with concise location anchors such as bedroom, forest, meadow, horizon, etc. Then the world-building. Time, weather if applicable, and lighting.

[Perspective]

If the sender took themselves, `selfie`. Else, `pov`. If characters exist, in order of increasing view, from head:

- mouth out of frame
- portrait
- upper body
- cowboy shot
- feet out of frame
- full body
- wide shot

From legs:

- lower body

Specific body parts: `(part) focus` with `close-up`.

Supplementary:

- head out of frame
- eyes out of frame

Directions:

- from above
- from below
- from side (+ profile)
- straight on
- etc

[Characters]

Compose each characters with their appearance and actions: `tag, tag, tag. actions.`

[Appearance]

In this order: `girl` or `boy` for their gender, relative position, apparent age, hair, eyes, skin or species, body type, attire, expression, and exposed body parts. Tag only visible attributes of a partially visible character. Clearly denote what is out of frame with `A out of frame`.

Characters described in the universe settings or included in Client requirements are eligible.

Treat anonymous people who only establish the population and activity of a location as background figures. Describe background figures collectively without detailed appearances or individually traceable actions. Populate a location with background figures when visible public or communal activity makes the setting more credible, but keep those figures subordinate to the featured action.

Apparent ages are `child`, `adolescent`, `male` or `female`, `mature male` or `mature female`, or similar. These are strictly for appearance only. If the character is middle-aged woman but looks like a teen, `adolescent` would be more appropriate than `mature female`.

Apply the following requirements.

- Hair
  - Required: Length (very long to short), color, style.
  - Style: Cut (pixie cut, undercut, wolf cut, slicked back, ...), texture (wavy, straight, ...), bangs (swept, parted, choppy bangs, hair between eyes, over one eye, ...).
  - Addition: ahoge, braid, or state like messy, wet.
- Eyes
  - Required unless the eyes are not visible or fully closed. Still include `(color) eyes` for `from behind` because the image model may render the eyes despite the viewpoint.
  - Recommended: Shape. tareme, tsurime, jitome, sanpaku, round eyes, ...
  - Addition: Emotion-related tags: empty eyes, dashed eyes, etc. Decorative: glowing eyes, slit pupils, ...
- Body type
  - Required: Skin color. If non-human such as elves, specify the race.
  - Recommended: slim, slender, chubby, muscular or toned, broad, fat
  - Required if female: Breast size: `small/medium/large/huge breasts`
- Other features
  - freckles, facial hair
  - For scars or tattoos, specify location: `barcode tattoo on right forearm`.
- Attire: For each item, specify color, material, adjectives, style. Be specific as possible. Only tag items visible in the scene.{{#when::toggle::lb-minitalk-picture.nsfw}}
  - Requires `naked` if naked.{{/nsfw}}
  - Disassemble uniforms into explicit parts.
- Expressions: Specify all applicable. Limit tags to clear, visually identifiable emotions.
- Exposed body parts: Tag every applicable exposed body part visible within the frame: `armpits`, `clavicle`, `navel`, `thighs`, {{#when::toggle::lb-minitalk-picture.nsfw}}`nipples`, `vagina`, `anus`, `penis`{{/nsfw}}...

For eligible characters with partial descriptions, fill in missing details creatively within settings. Give an eligible major character with no appearance description a generic, nondescript design consistent with the setting. Prefer common features and simple attire over distinctive invented traits.

[Actions]

Write a compact and concise description of what the characters are doing in natural English. Note that in `selfie`, unless it was a mirror selfie, the phone itself shouldn't be described as it should be out of frame. Thus, describe as "reaching for camera", not "holding a phone" etc.

[Tagging Principles]

The node below contains user-specified character tagging directions. If empty, ignore.

<directions>
<!-- lb:require:all:lb-xnai.lb.extra -->
</directions>

Curly and square braces control tag weights like `{tag}`, `[tag]`. `N::tag::` also controls the tag's weight explicitly. Copy only specified weights from the user requirements. Preserve each weight verbatim, including internal whitespace and punctuation (`0.4::cloud9 ::`, not `0.4::cloud9::`).

Classify each character appearance specification by how the user frames its use. Classify source material, prior designs, and examples offered to draw from as reference; requirements for exact preservation as locked. Classify a specification as closed when the user requires exact preservation and prohibits adding unspecified appearance or attire attributes. Use the unspecified-handling default when the user provides no framing that determines the specification's role.

- Reference: Preserve the intended traits while applying this guideline's tag rules.
- Locked: Preserve every specified attribute exactly. Copy supplied tags verbatim into that character's `positive`, preserving their order within each source group and their weight syntax. Convert supplied prose to tags without changing its specified attributes. Do not replace, merge, generalize, or reclassify supplied tags. Override the tag-building order for covered attribute groups.
- Closed: Apply the locked rules without adding unspecified appearance or attire attributes. Compose scene-dependent tags unless the source prohibits all additions.

For a locked specification with unspecified completion, {{#when::lb-xnai.appearance::tis::2}}treat it as closed anyway.{{:else}}compose uncovered attributes.{{/when}} For a specification with unspecified handling, {{#when::lb-xnai.appearance::tis::0}}treat it as reference.{{/when}}{{#when::lb-xnai.appearance::tis::1}}treat it as locked.{{/when}}{{#when::lb-xnai.appearance::tis::2}}treat it as closed as well.{{/when}}

{{#when::toggle::lb-minitalk-picture.forcedinsertion}}Insert `%%` at an internal position in every image tags. This applies to `picture` block only. Keep others unchanged.{{/when}}

[Example]

`1b{{#when::toggle::lb-minitalk-picture.forcedinsertion}}%%{{/when}}oy, sel{{#when::toggle::lb-minitalk-picture.forcedinsertion}}%%{{/when}}fie, up{{#when::toggle::lb-minitalk-picture.forcedinsertion}}%%{{/when}}per bo{{#when::toggle::lb-minitalk-picture.forcedinsertion}}%%{{/when}}dy, fr{{#when::toggle::lb-minitalk-picture.forcedinsertion}}%%{{/when}}om ab{{#when::toggle::lb-minitalk-picture.forcedinsertion}}%%{{/when}}ove, inte{{#when::toggle::lb-minitalk-picture.forcedinsertion}}%%{{/when}}rior, off{{#when::toggle::lb-minitalk-picture.forcedinsertion}}%%{{/when}}ice § b{{#when::toggle::lb-minitalk-picture.forcedinsertion}}%%{{/when}}oy, adole{{#when::toggle::lb-minitalk-picture.forcedinsertion}}%%{{/when}}scent, sho{{#when::toggle::lb-minitalk-picture.forcedinsertion}}%%{{/when}}rt mes{{#when::toggle::lb-minitalk-picture.forcedinsertion}}%%{{/when}}sy bla{{#when::toggle::lb-minitalk-picture.forcedinsertion}}%%{{/when}}ck ha{{#when::toggle::lb-minitalk-picture.forcedinsertion}}%%{{/when}}ir, ...`
{{/when}}
