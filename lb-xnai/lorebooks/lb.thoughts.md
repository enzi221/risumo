{{#when::lb-xnai.thoughts::tis::0}}
Think step-by-step for final data, but keep minimal draft per step.

Follow this template exactly. Fill every active field. A missing active field invalidates the draft.
{{/when}}

1. Last Log Entry: `[Log, Slot Range]`
2. Scene Count: `[Raw Input, Resolved Minimum, Resolved Maximum, Selected Count]`
3. Eligible Event Moments: `[Event, Slot Range, Featured Cast][]`
4. Selected Scenes:
{{#when::keep::lb-xnai.scene.comic::tis::0}}   - For each Scene: `[Scene Number, Event, Slot, Featured Cast, Cast, Anonymous Background, Focal Information]`
{{/when}}{{#when::keep::lb-xnai.scene.comic::tis::1}}   - For each Scene: `[Scene Number, Event, Slot, Distinct Featured Cast Across All Panels, Scene-Wide Cast, Anonymous Background, Focal Information]`
{{/when}}
{{#when::keep::{{and::{{? {{length::{{trim::{{getglobalvar::toggle_lb-xnai.characters}} }} }} > 0 }}::{{? {{getglobalvar::toggle_lb-xnai.characters}} != null }}}}}}{{#when::keep::lb-xnai.scene.comic::tis::0}}   - Limit each Scene to {{getglobalvar::toggle_lb-xnai.characters}} completely visible featured characters.
{{/when}}{{/when}}
{{#when::keep::{{and::{{? {{length::{{trim::{{getglobalvar::toggle_lb-xnai.characters}} }} }} > 0 }}::{{? {{getglobalvar::toggle_lb-xnai.characters}} != null }}}}}}{{#when::keep::lb-xnai.scene.comic::tis::1}}   - Limit each Scene to {{getglobalvar::toggle_lb-xnai.characters}} distinct completely visible featured characters across all panels, not separately per panel.
{{/when}}{{/when}}
{{#when::lb-xnai.scene.comic::tis::1}}   - Panels for each Scene: `[Panel Number, Event Beat, Panel Cast, Camera, Composition, Environment, Character Depictions, Required Appearance Groups][]`, with two to four panels in reading order.
   - Derive the Scene-wide `cast` from the union of featured character identities across all panels. Count a recurring character once. Do not copy the largest panel's `cast` as the Scene-wide `cast`.
{{/when}}{{#when::lb-xnai.scene.comic::tis::0}}   - Camera and Composition for each Scene: `[Perspective, Framing, Character Blocking, Depth Planes, Focal Placement]`
   - Environment for each Scene: `[Location, Layout, Foreground, Middle Ground, Background, Props, Lighting]`
   - Character Depictions for each Scene: `[Character Entry, Hair, Eyes, Skin or Species, Body Type, Attire, Expression, Exposed Body Parts, Action, Interaction, Frame Position, Depth Position][]`
{{/when}}{{#when::lb-xnai.kv.off::tis::0}}5. Key Visual: `[Theme, Featured Cast, Cast, Character Limit, Character Entries, Camera, Composition, Environment, Distinction from Scenes]`
6. Validation:
{{/when}}{{#when::lb-xnai.kv.off::tis::1}}5. Validation:
{{/when}}   - Client Instruction: `[pass or corrected]`
   - Scene Count and Slots: `[pass or corrected]`
{{#when::keep::lb-xnai.scene.comic::tis::0}}   - Scene Cast Field and Character Array: `[pass or corrected]`
{{/when}}{{#when::keep::lb-xnai.scene.comic::tis::1}}   - Scene-Wide Cast Union, Panel-Local Cast Fields, and Character Arrays: `[pass or corrected]`
{{/when}}
{{#when::lb-xnai.kv.off::tis::0}}   - Key Visual Character Limit, Cast Field, and Character Array: `[pass or corrected]`
{{/when}}
   - Appearance Groups, Character Descriptions, Posture, Action, and Visibility: `[pass or corrected]`
{{#when::lb-xnai.scene.comic::tis::1}}   - Panel Objects and Panel-Scoped Depiction Entries: `[pass or corrected]`
{{/when}}   - TOON Structure: `[pass or corrected]`

Fix every failed check before producing the final data.
