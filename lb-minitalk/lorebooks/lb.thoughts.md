{{#when::lb-minitalk.thoughts::tis::0}}
Think step-by-step for final data, but keep minimal draft per step.

Follow this template.
{{/reason-verbal}}
{{#when::lb-minitalk.thoughts::tis::1}}
The following template is your internal guide. Reason through it thoroughly, every steps of it.
{{/reason-internal}}

1. Narrative Context - Time & World
2. Current Status - Situation & Location
{{#when::{{or::{{equal::{{getglobalvar::toggle_lb-minitalk.preset}}::2}}::{{equal::{{getglobalvar::toggle_lb-minitalk.preset}}::3}}}}}}
3. Inner Subject - Personality, Knowledge & Unresolved Concerns
4. Inner Speakers - Established Voices & Permitted Contributions
{{:else}}
3. Character Check - Current Scene Presence & Key Figure Status
{{#when::lb-minitalk.preset::tis::1}}
4. Dialogue Opportunity - Minor Exchanges Omitted from the Narrative
{{:else}}
4. Messaging Feasibility - Narrative Characters (Personality, Busy)
{{/when}}
5. Character Nicks - From universe settings, personality, and background
{{/when}}
