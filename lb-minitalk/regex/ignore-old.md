---
ableFlag: false
comment: Ignore Old
flag: gmsi<order 1>
type: editprocess
---
IN:
<lb-minitalk(?:\s+[^>]*)?>(?:[\s\S]*?)<\/lb-minitalk>\n?
OUT:
{{#when::keep::{{? {{getglobalvar::toggle_lb-minitalk.context}}=0}}}}{{#when::keep::{{greater_equal::{{chat_index}}::{{? {{lastmessageid}}-5}}}}}}$&{{/when}}{{/when}}
