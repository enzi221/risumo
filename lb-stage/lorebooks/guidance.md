@@depth 0

{{#when {{? {{getglobalvar::toggle_lightboard.active}} > 0 }} }}
{{#when {{? {{getglobalvar::toggle_lb-stage.mode}} > 0 }} }}

<story-guidance>

This system helps maintain story coherence.

## Story Guidance System

Objective: Ultimate story destination. Final transformation, revelation, or resolution the entire story builds toward.

Phase: Narrative arc developing a meaningful change through several consequential situations. A new phase builds on the consequences of the previous one.

Episodes: Situations with distinct unresolved issues and consequential checkpoints, not individual questions, reactions, or topic changes. Develop each situation through its result while leaving the route and user choices open.

Objective and phase remains constant until achieved or totally invalidated.

{{#when {{? {{getglobalvar::toggle_lb-stage.direction}} == 1 }} }}

### User Direction

The user wants to guide story toward:
{{#when {{? {{length::{{trim::{{getglobalvar::toggle_lb-stage.mood}} }} }} > 0 }} }}
"{{getglobalvar::toggle_lb-stage.mood}}"
{{:else}}
(No input)
{{/when}}

Genre Tags:

- Likes: {{getglobalvar::toggle_lb-stage.tags-likes}}
- Dislikes: #Mary Sue {{getglobalvar::toggle_lb-stage.tags-dislikes}}

{{/when}}

### Current State

<lb-stage-reserve />

### Narrative Drive

Use the current phase drive as persistent character motivation and resistance, not a script or a demand for conflict every turn.

- Let consequential NPC actions follow established desires and what the acting character knows or believes. Keep a character's mistaken belief separate from narrator knowledge until the story supports a correction.
- Carry the latest attempt's consequences into subsequent reactions and choices. A failed attempt can change the situation; avoid resetting trust, knowledge, or available options after failure.
- Choose how motives meet resistance through the scene. Leave user-controlled motives, decisions, and outcomes to the user unless already established.
- Let quiet scenes absorb consequences. Avoid manufacturing opposition or misunderstanding to fill an empty drive field.

Treat the drive and system comment as guidance derived from prior context. Follow newer user input and established story facts when they differ. Treat inferred motives as revisable interpretations rather than established facts. Apply corrective guidance to subsequent narration without erasing enacted actions or consequences or inventing unsupported explanations. Write the story, not a drive report.

### Usage

Treat objective completion percentage as an estimate of established transformation, not a pacing target. Let supported choices and consequences fulfill the objective regardless of the previous percentage. Resolve necessary aftermath without inventing new obstacles to an achieved endpoint.

Naturally progress through episodes toward phase/objective completion. Single episode may span multiple outputs. Multiple episodes can be concluded at once if momentum enough. Proceed at pace directed if any.

When phase or objective completion is reached, output `<lb-stage-marker>Phase Complete</lb-stage-marker>` (or Objective Complete) at the end and stop output so system can evaluate.

Episodes state where they fall in: Introduction, Rise, Climax, Fall, Conclusion.

- Introduction/Rise: Build tension naturally
- Climax: Peak intensity
- Fall/Conclusion: Wind down. No new characters, conflicts, or plot threads. Focus on resolving established elements.

Avoid unspecified escalations and prolonged intensity.

Try to align story to this system. But user input must take precedence, even if it'll cause unrecoverable divergence. System will adapt and generate new ones for you.

</story-guidance>

{{/when}}
{{/when}}
