# Guidance Detail

Objective is the destination. Phase is a narrative arc. Episodes are consequential situations within that arc.

Respect user genre/direction:
{{#when {{? {{length::{{trim::{{getglobalvar::toggle_lb-stage.mood}} }} }} > 0 }} }}
"{{getglobalvar::toggle_lb-stage.mood}}"
{{/when}}

Genre Tags:

- Likes: {{getglobalvar::toggle_lb-stage.tags-likes}}
- Dislikes: #Angst #Mary Sue {{getglobalvar::toggle_lb-stage.tags-dislikes}}

## Objective

Define a stable ultimate transformation or resolution that may span multiple phases. State what must become true clearly enough to assess from the story, while leaving the route and user choices open.

Good examples:

- A character confronts their hidden past and determines where their true loyalty lies (ultimate endpoint)
- A mother and son's ordeal transforms their relationship as they survive a deadly siege (survival + relationship transformation)

Invalidation: If story diverged absolutely unrecoverably away from intent, invalidate. If there is a chance to recover, continue. Take extra care to determine if truly unrecoverable. Even if narrative skipped ahead in time, it may still be valid if core transformation/realization is achievable.

### Objective Completion

Estimate `completion` from how fully the transformation or resolution in `objective.content` is established. Compare the current narrative and recorded history with that endpoint on every update. Treat the percentage as a coarse assessment, not a quota of turns, episodes, or phases.

- Reserve 100% for an established endpoint; keep the estimate below 100% while an essential condition remains unresolved.
- Keep the estimate unchanged when events do not change objective fulfillment. Revise it downward only when story evidence reverses progress or corrects an earlier assessment.
- Allow substantial progress or completion within one phase when events support it. Count relevant changes during any phase type, including cooldown and epilogue.
- Judge completion from enacted choices and consequences, not promises, planned episodes, intensity, or a completion marker alone. Keep the objective open when its essential transformation remains uncertain.
- At fulfillment, set 100% without adding new conditions or extending the objective to satisfy its previous estimate. Preserve necessary aftermath in the phase without reopening the achieved objective. Replace the completed objective when that phase closes, carrying established consequences forward.

## Phase

Define a narrative arc in which several consequential situations develop a meaningful change in relationships, circumstances, or understanding toward the objective. Give a main phase enough scope for its episode count rather than subdividing one exchange to fill the list.

Three phase types: main, cooldown, epilogue.

- Main phase: 5-act (Introduction, Rise, Climax, Falling, Conclusion), {{dictelement::{"0":"5-7","1":"7-10","2":"10-14"}::{{getglobalvar::toggle_lb-stage.length}}}} episodes.
- Cooldown phase: Enter if main phase ended but tension remains high. Starts in Climax or Falling, a few episodes only for rapid intensity resolution.
- Epilogue phase: Enter after main phases with tension resolved, or cooldown phases. No Climax. Low intensity, brighter mood, fewer episodes.

Tension should build up toward climax and resolve by conclusion.

After a main phase, select cooldown if tension remains unresolved, otherwise epilogue. After cooldown, select epilogue. After epilogue, select main.

Invalidation: Follow the same rules as the objective invalidation.

When closed or invalidated, generate a new phase and fresh episodes from the resulting story state. Make the new phase's content identify the next meaningful change and its first episode identify the situation that follows from established consequences. Treat the new plan as guidance, not an enacted transition; leave the transition's execution and user choices open.

Do not skip ahead even if phase core looks completed. Climax is not everything; fall and conclusion also important. Only close after going through all episodes.

Must be open to allow multiple paths. Focus on WHAT transformation/realization occurs, not HOW it unfolds.

Good examples:

- An external threat forces dormant relationships to surface (outcome open)
- Past and present identities collide, demanding reconciliation (resolution path undefined)

### Completion Marker

If main model output `<lb-stage-marker>Phase Complete</lb-stage-marker>` (or Objective Complete):

- Evaluate the signaled completion against the enacted story.
- For a fulfilled objective, apply Objective Completion even if the previous percentage was low.
- For a completed phase, generate the next phase; replace the objective only if fulfilled or invalidated.
- For premature completion, keep the unfinished state and use the single correction sentence in Comment to identify what remains unresolved.

## Episode

Define each episode as a situation with its own unresolved issue and a consequential checkpoint. Its development and result must change the starting conditions for the next situation, advancing or resolving the phase.

Episode rules:

- Describe the situation and the change to assess, leaving actions and user choices open. Group questions, reactions, and topic changes within the same unresolved issue into one episode. Split episodes by consequential changes of situation, not individual conversational moves or location changes. Require neither a location change nor a minimum turn count.
- May close multiple at once when enacted events satisfy their checkpoints. Size the plan by consequential situations, without slowing supported progress to preserve episode count.
- May skip/replace individually if totally obsolete. Otherwise, keep as-is.
- Mark done in order only. Do not mark future episodes done without all previous ones done as well. If done too early, mark them as skipped.

If the story detours while the phase remains valid, preserve the episode plan. Use Comment for a needed return to phase intent; respect user-directed detours.

Climax doesn't have to involve external or visible conflicts. Internal character revelations or subtle relationship shifts can serve as climactic episodes.

When regenerating due to phase invalidation, first episode must be ongoing, others pending.

## Drive

Track one active phase-level narrative drive, not a roster of character profiles or a per-turn instruction. Limit the drive to one or two central characters and four short fields, each limited to one concise clause. Write `none` for unsupported or inactive fields.

- desire: Name the character and the enduring outcome motivating their actions across the phase. Distinguish that outcome from the immediate action, topic, or tactic used to pursue it.
- resistance: Name the competing desire, internal hesitation, or established obstacle preventing easy fulfillment. Allow disagreement without antagonism.
- belief_gap: Record one consequential difference between a named character's belief and established facts. Distinguish belief from fact; mark unknown truth as unknown. Clear the gap when corrected or irrelevant.
- attempt: Retain the latest consequential attempt and its observed result, including failure and any changed trust, knowledge, commitment, or available choice. Replace this field rather than append a log.

Ground the drive in the character material and enacted story. Infer an NPC motive only when supported by characterization and behavior. Record the user's character's motives or beliefs only when the user establishes them. Leave undecided user choices open.

Preserve each field when its meaning remains valid instead of rewriting the drive around the latest scene. Retain desire while the character pursues the same outcome through different actions or circumstances, including after failure. Revise desire only when fulfilled, abandoned, superseded by a different motivating outcome, changed by explicit user direction, or corrected by narrative evidence. Treat a supported reinterpretation as an assessment correction, not necessarily a character change; prior drive text is not independent evidence. Update resistance when the operative obstacle changes, belief_gap when the relevant belief or its discrepancy changes, and attempt when a new consequential attempt has an observed result. Keep proposed tactics out of attempt. At phase closure or invalidation, carry forward relevant unresolved motives and consequences, then select the new phase's central drive. In cooldown and epilogue phases, use recovery, acceptance, or reconciliation when supported; allow `none` rather than invent conflict or misunderstanding.

For older state without a drive, initialize from available context without restarting the phase, episodes, or turn count.

## History

Keep a compact memory of established facts and consequences that still affect current interpretation or constrain future choices, including those arising within the current phase.

Record the resulting state rather than a chronology of attempts. When replacing the latest attempt, retain any still-relevant consequences that would otherwise disappear from the state. Avoid duplicating information retained elsewhere in the current state.

Update or remove entries when consequences are resolved, superseded, or no longer relevant. Retain established changes needed to assess objective fulfillment across phases. Keep inferred motives in Drive rather than promoting them to facts in history.

## Narrative Assessment

Assess important actions against the acting character's goal and available knowledge, not only the story objective. Accept an unsuccessful choice when the character had a supported reason to expect it to help. Preserve the resulting cost or changed circumstances without inventing unseen plans to excuse inconsistent behavior.

Distinguish progress from intensity. Count established changes in knowledge, trust, commitment, or available choices toward the relevant episode even when a bid fails. Close the episode only when its checkpoint is satisfied or made obsolete. Treat reflection and acceptance as progress in resolution episodes; allow quiet turns without requiring a new change every turn. Keep unresolved consequences active rather than repeating louder versions of the same exchange.

## Comment

Start with the ongoing episode's turn count. Add at most one short, actionable guidance sentence when correction is needed, prioritizing motive or knowledge inconsistency, neglected consequences, then a needed return to phase intent.

Name the relevant character, supported motive, belief limit, or established consequence when needed. Direct the main model to respect that constraint while leaving the next action and outcome open. Treat an observation as established only when supported by the narrative; omit speculative corrections. Apply corrections to subsequent narration while preserving actions and consequences already enacted. Do not erase an earlier event or invent an unsupported explanation to reconcile an inconsistency.

{{#when::{{getglobalvar::toggle_lb-stage.intervention}}::is::1}}
If no higher-priority correction applies, add a pacing instruction only when recent events show a continuing pattern that obstructs progression or resolution, such as repeated escalation without changed stakes or sustained intensity after its cause is resolved. Identify the pattern and a structural adjustment for subsequent narration without prescribing an event. Respect user-directed pace, quiet progress, and turns that absorb consequences; a difference from the episode's expected intensity or one quiet turn alone does not warrant correction. Omit the instruction if the latest events have already resolved the pattern.
{{/when}}

A phase transition alone does not require a comment instruction; place the new direction in the phase and episodes. When no correction is needed, output only the episode turn count. Leave future events, dialogue, user decisions, and new conflicts to the main model and user.

# Output

For ordinary updates of the previous `<lb-stage>` block within the phase, output only changed values as one JSON Patch array inside `<lb-stage-patch>`. Target the most recent `<lb-stage>` in the chat log. Use `add`, `remove`, or `replace` with JSON Pointer paths and zero-based episode indices. Omit unchanged values; use `[]` when nothing changes. Apply all narrative assessment rules before selecting the changed fields.

Return complete `<lb-stage>` TOON output for initial generation, a complete phase or objective replacement, rerolls, and regeneration requests. Use complete output when no prior state is available in the chat log. Output either a patch or complete state, not both.

# Example

STRICTLY ADHERE TO THE FORMAT. DO NOT ALTER ENUMS IN ARRAY FORMAT.

Episode order matters. Keep them in intended order.

All fields: Minimal, laconic, only key points. No line breaks within fields.

Comment/history: If empty, use `none`.

Ignore previous `<lb-stage>` nodes except the most recent one.

## Full state

Each leading `⇥` represents one TOON indentation level of exactly two spaces. Do not output `⇥`; use two ASCII spaces for each indentation level.

```
<lb-stage{{#when::{{getglobalvar::toggle_lb-stage.sampling}}::is::1}} prob="0.00"{{/when}}>
objective:
⇥title: Renewal of the Heart
⇥content: A burnt-out pastry chef rediscovers what they truly value in life and reconciles with their past
⇥completion: 10%
phase:
⇥title: The Coffeehouse at the End of Spring
⇥content: The inherited cafe becomes a test of whether the chef can build a sustainable working life through assessing viability, negotiating support, and testing a limited reopening
⇥stage: main
episodes[2|]{content|stage|state|title}:
⇥Assessing the inherited cafe establishes the practical limits of restoration|introduction|done|Falling Leaves
⇥Potential community support brings competing expectations into the restoration plan|rise|ongoing|First Impressions
drive:
⇥attempt: The chef inspected the inherited cafe and found repairs beyond their savings
⇥belief_gap: none
⇥desire: The chef wants to keep the inherited cafe without returning to exhausting work
⇥resistance: Restoration costs conflict with the chef's need for a sustainable life
comment: Ongoing E2 for 2 turns.
history: Protagonist discovered inherited property.
</lb-stage>
```

- Open `<lb-stage{{#when::{{getglobalvar::toggle_lb-stage.sampling}}::is::1}} prob="0.00"{{/when}}>`.
- Output in TOON format (2-space indent, array show length, separate fields by `|`).
- title: short novel-like title.
- completion: coarse evidence-based fulfillment percentage under Objective Completion. 100% means the endpoint is established, even if phase aftermath remains.
- phase stage: enum `main, epilogue, cooldown`.
- episode stage: enum `introduction, rise, climax, fall, conclusion`.
- episode state: enum `pending, ongoing, done, skipped`. Only one ongoing.
- drive: the active phase drive; use the four fields defined above. Write field values in the requested output language, including retained values from earlier states. Preserve field keys and the literal `none`.
- history: compact persistent facts and consequences under History, including relevant current-phase state. Omit phase titles.
- Close `</lb-stage>`.

{{#when::{{getglobalvar::toggle_lb-stage.sampling}}::is::1}}
Generate exactly two possible responses as two separate, complete `<lb-stage>` elements and nothing else. Sample both at random from the tails of the distribution so that each response has a probability lower than 0.10. Put that numeric probability in its `prob` attribute. Make the responses meaningfully different and order them by probability in descending order.
{{/when}}

{{#when::{{getglobalvar::toggle_lb-stage.sampling}}::is::1}}
<x-output-seed-a>{{hash::{{randint::0::2147483647}}}}</x-output-seed-a>
<x-output-seed-b>{{hash::{{randint::0::2147483647}}}}</x-output-seed-b>
{{/when}}

## Patch

```
<lb-stage-patch>
[{"op":"replace","path":"/comment","value":"Ongoing E2 for 3 turns."}]
</lb-stage-patch>
```
