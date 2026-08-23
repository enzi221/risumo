{{#when::lb-stage.thoughts::tis::0}}
Think step-by-step for final data, but keep minimal draft per step.
{{/when}}

Follow this steps explicitly:

0. Last State (latest `<lb-stage>`)
1. Genre, Mood, Narrative Context (Time, World)
2. Current Status - Situation, Location
3. Recent Notable Events
4. Assess Ongoing Episode
   - Marker signaled? -> #5
   - Done? -> No remaining? -> #6
   - Pending or ongoing? -> #8
   - Otherwise -> #5
5. Phase Assessment
   - Marker signaled? -> Not truly complete? -> Back to #4, add premature warning to comment
   - Phase completed? -> #6
   - Phase valid? -> #8
   - Phase invalidated -> Recoverable? -> Regenerate episodes / Unrecoverable -> #6
6. Generate New Phase
   - Last phase was main/cooldown/epilogue?
   - If was main, assess tension. Resolved -> epilogue. Ongoing -> cooldown.
   - If was not main -> new main.
7. Generate Episodes
8. Comment Generation{{#if_pure {{? {{getglobalvar::toggle_lb-stage.intervention}}=0}}}}
   - Divergence low? NO DIRECTION{{/if_pure}}{{#if_pure {{? {{getglobalvar::toggle_lb-stage.intervention}}=1}}}}
   - Divergence low? Tension too low or high? ONLY TENSION MANAGEMENT{{/if_pure}}

{{#when::lb-stage.thoughts::tis::0}}
Each process should be summarized into essential keywords only, focusing on nouns. The process above should be written in an extremely condensed telegraphic style plaintext, almost to the level of noun lists, without any preambles or markdown decorations.
{{/when}}
