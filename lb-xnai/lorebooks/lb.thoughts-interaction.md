{{#when::lb-xnai.thoughts::tis::0}}
Think step-by-step for final data, but keep minimal draft per step.

Follow this template exactly. Fill every active field. A missing active field invalidates the draft.
{{/when}}

1. Interaction Action: `[Action, Selected Chat Index, Selected Slot]`
2. Slot Context: `[Exact Slot Marker, Closest Prose Before Marker, Closest Prose After Marker, Narrative State at Marker]`
3. Selected Scene: `[Event at Slot Marker, Featured Cast, Anonymous Background, Focal Information]`
{{#when::lb-xnai.scene.comic::tis::1}}4. Panels: `[Panel Number, Event Beat, Panel Cast, Camera, Composition, Environment, Character Depictions, Required Appearance Groups, Character Descriptions][]`, with two to four panels in reading order.
5. Validation:
{{:else}}4. Camera and Composition: `[Perspective, Framing, Character Blocking, Depth Planes, Focal Placement]`
5. Environment: `[Location, Layout, Foreground, Middle Ground, Background, Props, Lighting]`
6. Character Depictions: `[Character Entry, Hair, Eyes, Skin or Species, Body Type, Attire, Expression, Exposed Body Parts, Character Description, Base Posture, Action, Interaction, Frame Position, Depth Position][]`
7. Validation:
{{/when}}   - Exact Slot Marker, Adjacent Prose, and Single Scene: `[pass or corrected]`
   - Cast Fields and Character Arrays: `[pass or corrected]`
   - Appearance Groups, Character Descriptions, Posture, Action, and Visibility: `[pass or corrected]`
{{#when::lb-xnai.scene.comic::tis::1}}   - Panel Objects and Panel-Scoped Depiction Entries: `[pass or corrected]`
{{/when}}   - Interaction Marker and TOON Structure: `[pass or corrected]`
