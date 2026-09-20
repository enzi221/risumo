{{#when::lb-xnai.thoughts::tis::0}}
Think step-by-step for final data, but keep minimal draft per step.

Follow this template exactly. Fill every list. Fill every `[Fields, ...]` exhaustively. Do not shorten, summarize, omit, compromise. A missing active field invalidates the draft.
{{/reason-verbal}}
{{#when::lb-xnai.thoughts::tis::1}}
The following template is your internal guide. Reason through it thoroughly, every steps of it. Step through every `[Fields, ...]` exhaustively.
{{/reason-internal}}

1. Interaction Action: `[Action, Selected Chat Index, Selected Slot]`
2. Slot Context: `[Insertion Slot, Preceding Depicted Moment, Following Continuity Prose]`
3. Selected Scene:{{#when::keep::lb-xnai.scene.comic::tis::0}}
   `[Distinct Event Moment, Framing, Visible Body Span, Cropped-Out Attire, Featured Cast]`{{#when::keep::{{and::{{? {{length::{{trim::{{getglobalvar::toggle_lb-xnai.characters}} }} }} > 0 }}::{{? {{getglobalvar::toggle_lb-xnai.characters}} != null }}}}}}
   - Limit the Scene to {{getglobalvar::toggle_lb-xnai.characters}} substantially visible featured characters.{{/when}}{{/when}}{{#when::keep::lb-xnai.scene.comic::tisnot::0}}
   `[Distinct Event Moment, Distinct Featured Cast Across All Panels]`{{#when::keep::{{and::{{? {{length::{{trim::{{getglobalvar::toggle_lb-xnai.characters}} }} }} > 0 }}::{{? {{getglobalvar::toggle_lb-xnai.characters}} != null }}}}}}
   - Limit the Scene to {{getglobalvar::toggle_lb-xnai.characters}} distinct substantially visible featured characters across all panels.{{/when}}
   - Panels: `[Panel Number, Event Beat, Framing, Visible Body Span, Cropped-Out Attire, Featured Cast][]`, with two to four panels in reading order.
   - Derive the Scene-wide `cast` from the union of featured character identities across all panels. Count a recurring character once.{{/when}}
4. Eligible Featured Cast: `[Character, Eligibility Basis, Applicable Appearance Sources, Resolved Appearance Handling][]`
   - Recall applicable appearance, identifying features, fashion guidance, and tag lists from Client Instructions when present; Narrative Universe Settings; and the current situation and prior-record tags. Name the applicable sources without reproducing their contents.
   - Check whether Client appearance instructions are present. If present, classify each specification as reference, locked, or closed, applying the defaults for unspecified handling and completion. Record the instruction presence, resolved classification, and whether uncovered attributes may be composed; otherwise record no Client appearance instructions.
5. Validation:
   - Client Instruction: `[pass or corrected]`
   - Exact Insertion Slot, Complete Preceding Moment, and Single Scene: `[pass or corrected]`
   - Featured Character Eligibility and Appearance Handling: `[pass or corrected]`{{#when::keep::lb-xnai.scene.comic::tis::0}}
   - Scene Cast Field and Character Array: `[pass or corrected]`{{/when}}{{#when::keep::lb-xnai.scene.comic::tisnot::0}}
   - Scene-Wide Cast Union and Panel Character Arrays: `[pass or corrected]`{{/when}}
   - Visible Appearance Groups, Character Descriptions, Actions, and Visibility: `[pass or corrected]`{{#when::keep::lb-xnai.scene.comic::tisnot::0}}
   - Panel Objects and Panel-Scoped Depiction Entries: `[pass or corrected]`{{/when}}
   - Interaction Slot: `[pass or corrected]`

Fix every failed check before producing the final data.
