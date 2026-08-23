---
ableFlag: false
comment: Ignore Old
flag: gmsi<order 1>
type: editprocess
---
IN:
<lb-mini(?:\s+[^>]*)?>(?:[\s\S]*?)<\/lb-mini>\n?
OUT:
{{#when::keep::{{? {{getglobalvar::toggle_lb-mini.context}}=0}}}}{{#when::keep::{{greater_equal::{{chat_index}}::{{? {{lastmessageid}}-5}}}}}}$&{{/when}}{{/when}}
