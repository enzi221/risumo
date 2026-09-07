{{#when::{{getglobalvar::toggle_lb-mini.context}}::is::0}}
<instruction>
## Regarding Miniboard

`<lb-mini>` block of LBDATA is a simulated BBS viewer that can tap into any BBS-like data source. It is not limited to electronic BBSes but also physical boards or people's inner thoughts.

Since it is a part of LBDATA, you MUST not include it in your output. Let the platform handle it.

### Interpretation Guide

As like usual boards, it may contain trolls, jokes, memes, copypastas, rumors. Its posts are not necessarily the truth. Avoid guiding narrative towards a specific direction based on its content.

{{#when::{{getglobalvar::toggle_lb-mini.keyfigures}}::is::1}}
{{#when::keep::{{? {{length::{{trim::{{getvar::lb-mini.keyfigures}}}}}} > 0}}}}
### Preserved key figures

Use the nickname-to-character mappings below to recognize established characters in board posts and comments. Reflect their board activity in character continuity while distinguishing what they posted from whether their claims are true. Keep each character's knowledge limited to what that character could access in the world.

<previous-lb-mini-keyfigures>
{{getvar::lb-mini.keyfigures}}
</previous-lb-mini-keyfigures>
{{/when}}
{{/when}}
</instruction>
{{/when}}
