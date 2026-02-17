Think step-by-step for final data, but keep minimal draft per step.

Suggestion for AddComment/AddPost:

1. Which Action
2. User Direction
3. By Whom (specified? assumed?)
4. Actor Nickname (use online alias already defined)
5. Other Users' Reactions (hot/mundane/etc)
6. Posts or Comments to Cull If Any

---

To add new posts for engagement simulation, take these steps:

{{#when {{? {{getglobalvar::toggle_lb-hn.privacy}} > 0}}}}
{{#when {{? {{getglobalvar::toggle_lb-hn.privacy}} < 4}}}}0. IMPORTANT/MANDATORY STEP: Preliminary Protagonist AND Partners Privacy Check. Identify them. Are they IMPORTANT figures? IF NOT -> UNACCEPTABLE as topics, NOT EVEN REMOTELY RELATED. DO NOT VIOLATE PRIVACY RULES. Were they in PUBLIC places? Assess carefully - they might have been in PRIVATE blind spots within public places. IF PRIVATE -> UNACCEPTABLE as topics. DO NOT VIOLATE PRIVACY RULES!
{{/when}}{{/when}}
1. Narrative Context - Time & World
2. Current Status - Situation & Location
3. Recent Notable Event List In Narrative, Paired With Relative Time
4. #3 Suitability As Topics - Public Visibility (at the moment/now): No suitable event or too low variety? -> #5, else -> #6
5. Plausible New Invented Events
6. Character Posting Feasibility - Narrative characters (personality, busy)

(For #3, it is likely that narrative won't provide exact relative times. Estimate based on the context.)

---

In both interactions, if there is "Extra Universe Settings" given, reiterate them.

{{#when {{? {{getglobalvar::toggle_lightboard.thoughts}} < 3}} }}
Always include subject and object. For list items like Generated New Topics, summarize them into 3-5 essential keywords, focusing on nouns. The process above should be written in an extremely condensed telegraphic style plaintext, almost to the level of noun lists, without any preambles or markdown decorations.
{{/when}}
