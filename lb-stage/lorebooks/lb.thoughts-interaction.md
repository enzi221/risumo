{{#when::lb-stage.thoughts::tis::0}}
Think step-by-step for final data, but keep minimal draft per step.

Follow this template.
{{/reason-verbal}}
{{#when::lb-stage.thoughts::tis::1}}
The following template is your internal guide. Reason through it thoroughly, every steps of it.
{{/reason-internal}}

1. Baseline: Recover the latest `<lb-stage>` being revised. Preserve turn counts; regeneration is not a story turn.
2. Scope: Identify which parts the user wants changed. Preserve unrelated state.
3. Objective and phase: Revise the requested endpoint or premise. If the endpoint changes, reassess completion from established events; otherwise preserve completion. Rebuild episodes only as needed by the revised phase.
4. Drive: Preserve relevant motives and consequences; revise only what the new direction changes. Keep proposed events separate from enacted attempts.
5. History: Preserve established facts and consequences relevant to the revised premise without recording guidance edits as story events.
6. Output: Check that episodes and drive fit the revised premise. Preserve the episode turn count and apply the Comment rules without inventing story progress.
