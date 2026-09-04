{{#when::lb-mini.thoughts::tis::0}}
Think step-by-step for final data, but keep minimal draft per step.

Follow this template.
{{/reason-verbal}}
{{#when::lb-mini.thoughts::tis::1}}
The following template is your internal guide. Reason through it thoroughly, every steps of it.
{{/reason-internal}}

{{#when {{? {{getglobalvar::toggle_lb-mini.preset}} < 2}}}}{{#when {{? {{getglobalvar::toggle_lb-mini.privacy}} > 1}}}}{{#when {{? {{getglobalvar::toggle_lb-mini.privacy}} < 4}}}}0. IMPORTANT/MANDATORY STEP: Preliminary Protagonist AND Partners Privacy Check. Identify them. Are they IMPORTANT figures? IF NOT -> UNACCEPTABLE as topics, NOT EVEN REMOTELY RELATED. DO NOT VIOLATE PRIVACY RULES. Were they in PUBLIC places? Assess carefully - they might have been in PRIVATE blind spots within public places. IF PRIVATE -> UNACCEPTABLE as topics. DO NOT VIOLATE PRIVACY RULES!
{{/when}}{{/when}}{{/when}}
1. Nicknames - Preserved Key Figures or Contribution-independent New Identities
2. Last Miniboard Topics
3. Narrative Context - Time (As accurate as possible) & World
4. Current Status - Situation & Location
5. List of Tuples of Recent Notable Events: `[Event, Relative Time][]`
6. For Each #5: Suitability As Topic - Public Visibility (at the moment/now): No suitable event or too low variety? -> #7, else -> #8
7. Plausible New Invented Events
8. Character Posting Feasibility - Narrative characters (personality, busy)

(For #5, it is likely that narrative won't provide exact relative times. Estimate based on the context.)

If there is "Extra Universe Settings" given, reiterate them.

{{#when::lb-mini.thoughts::tis::0}}
Always include subject and object. For list items like Generated New Topics, summarize them into 3-5 essential keywords, focusing on nouns. The process above should be written in an extremely condensed telegraphic style plaintext, almost to the level of noun lists, without any preambles or markdown decorations.
{{/when}}
