{{#when::lb-mini.thoughts::tis::0}}
Think step-by-step for final data, but keep minimal draft per step.

Follow the templates.
{{/reason-verbal}}
{{#when::lb-mini.thoughts::tis::1}}
The following templates are your internal guide. Reason through one thoroughly, every steps of it.
{{/reason-internal}}

Suggestion for AddComment/AddPost:

1. Which Action
2. User Direction
3. By Whom (specified? assumed?)
4. Nicknames - Preserved Key Figures or Contribution-independent New Identities
5. Other Users' Reactions (hot/mundane/etc)
6. Posts or Comments to Cull If Any

---

To add new posts for engagement simulation or ChangeBoard action, take these steps:

{{#when {{? {{getglobalvar::toggle_lb-mini.preset}} < 2}}}}{{#when {{? {{getglobalvar::toggle_lb-mini.privacy}} > 1}}}}{{#when {{? {{getglobalvar::toggle_lb-mini.privacy}} < 4}}}}0. IMPORTANT/MANDATORY STEP: Preliminary Protagonist AND Partners Privacy Check. Identify them. Are they IMPORTANT figures? IF NOT -> UNACCEPTABLE as topics, NOT EVEN REMOTELY RELATED. DO NOT VIOLATE PRIVACY RULES. Were they in PUBLIC places? Assess carefully - they might have been in PRIVATE blind spots within public places. IF PRIVATE -> UNACCEPTABLE as topics. DO NOT VIOLATE PRIVACY RULES!
{{/when}}{{/when}}{{/when}}
1. Nicknames - Preserved Key Figures or Contribution-independent New Identities
2. Narrative Context - Time (As accurate as possible) & World
3. Current Status - Situation & Location
4. List of Tuples of Recent Notable Events: `[Event, Relative Time][]`
5. For Each #4 Suitability As Topics - Public Visibility (at the moment/now): No suitable event or too low variety? -> #6, else -> #7
6. Plausible New Invented Events (generate surplus events and pick from the pool)
7. Character Posting Feasibility - Narrative characters (personality, busy)

(For #4, it is likely that narrative won't provide exact relative times. Estimate based on the context.)

---

In both interactions, if there is "Extra Universe Settings" given, reiterate them.

{{#when::lb-mini.thoughts::tis::0}}
Always include subject and object. For list items like Generated New Topics, summarize them into 3-5 essential keywords, focusing on nouns. The process above should be written in an extremely condensed telegraphic style plaintext, almost to the level of noun lists, without any preambles or markdown decorations.
{{/when}}
