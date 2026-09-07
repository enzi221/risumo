{{#when::lb-stage.thoughts::tis::0}}
Think step-by-step for final data, but keep minimal draft per step.

Follow this template.
{{/reason-verbal}}
{{#when::lb-stage.thoughts::tis::1}}
The following template is your internal guide. Reason through it thoroughly, every steps of it.
{{/reason-internal}}

1. State: Recover the latest `<lb-stage>` and identify the ongoing episode. Advance its turn count only for a new story turn.
2. Events: Identify what actually changed. Check acting characters' motives and knowledge; count consequential failures and quiet resolution.
3. Objective: Compare established events with the endpoint. Keep completion unchanged without evidence; set 100% when fulfilled.
4. Episode and phase: Check completion markers against events. Keep unfinished checkpoints open. If the phase is complete or unrecoverable, replace it under the Phase rules; replace the objective only if fulfilled or invalidated. Otherwise retain the plan.
5. Drive: Preserve the phase-level desire across changes of scene or tactic. Apply the field-specific update rules; use `none` for unsupported fields.
6. History: Retain still-relevant consequences displaced from the latest attempt and facts needed to assess the objective. Update resolved or superseded state without duplicating other fields.
7. Comment: Output the episode turn count and at most one needed correction. Leave the next action and user choices open.
