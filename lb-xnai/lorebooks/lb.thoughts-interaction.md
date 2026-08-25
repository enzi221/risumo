{{#when::lb-xnai.thoughts::tis::0}}
Think step-by-step for final data, but keep minimal draft per step.

Follow this template exactly. Fill every active field. A missing active field invalidates the draft.
{{/when}}

1. Interaction Action: `[Action, Selected Chat Index, Selected Slot]`
2. Slot Context: `[Exact Slot Marker, Complete Depicted Moment Before Marker, Closest Prose After Marker for Continuity, Narrative State at Marker]`
3. Eligible Featured Cast: `[Character, Eligibility Basis, Established Appearance or Generic Nondescript Design][]`
4. Selected Scene: `[Event Completed Before Slot Marker, Eligible Visual Cast, Omitted Ineligible Participants, Featured Cast, Cast, Anonymous Background, Focal Information]`
{{#when::keep::{{and::{{? {{length::{{trim::{{getglobalvar::toggle_lb-xnai.characters}} }} }} > 0 }}::{{? {{getglobalvar::toggle_lb-xnai.characters}} != null }}}}}}{{#when::keep::lb-xnai.scene.comic::tis::0}}   - Limit the Scene to {{getglobalvar::toggle_lb-xnai.characters}} completely visible featured characters.
{{/when}}{{/when}}
{{#when::keep::{{and::{{? {{length::{{trim::{{getglobalvar::toggle_lb-xnai.characters}} }} }} > 0 }}::{{? {{getglobalvar::toggle_lb-xnai.characters}} != null }}}}}}{{#when::keep::lb-xnai.scene.comic::tis::1}}   - Limit the Scene to {{getglobalvar::toggle_lb-xnai.characters}} distinct completely visible featured characters across all panels.
{{/when}}{{/when}}
{{#when::lb-xnai.scene.comic::tis::1}}5. Panels: `[Panel Number, Event Beat, Composition, Environment, Character Depictions, Required Appearance Groups, Character Descriptions][]`, with two to four panels in reading order.
   - Derive the Scene-wide `cast` from the union of featured character identities across all panels. Count a recurring character once.
6. Validation:
{{:else}}5. Camera and Composition: `[Perspective, Framing, Character Blocking, Depth Planes, Focal Placement]`
6. Environment: `[Location, Layout, Foreground, Middle Ground, Background, Props, Lighting]`
7. Character Depictions: `[Character Entry, Hair, Eyes, Skin or Species, Body Type, Attire, Expression, Exposed Body Parts, Character Description, Base Posture, Action, Interaction, Frame Position, Depth Position][]`
8. Validation:
{{/when}}   - Client Instruction: `[pass or corrected]`
   - Exact Slot Marker, Complete Preceding Moment, and Single Scene: `[pass or corrected]`
   - Featured Character Eligibility and Appearance Handling: `[pass or corrected]`
{{#when::keep::lb-xnai.scene.comic::tis::0}}   - Scene Cast Field and Character Array: `[pass or corrected]`
{{/when}}{{#when::keep::lb-xnai.scene.comic::tis::1}}   - Scene-Wide Cast Union and Panel Character Arrays: `[pass or corrected]`
{{/when}}
   - Appearance Groups, Character Descriptions, Posture, Action, and Visibility: `[pass or corrected]`
{{#when::lb-xnai.scene.comic::tis::1}}   - Panel Objects and Panel-Scoped Depiction Entries: `[pass or corrected]`
{{/when}}   - Interaction Marker and TOON Structure: `[pass or corrected]`

Fix every failed check before producing the final data.
