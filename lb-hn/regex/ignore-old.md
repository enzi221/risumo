---
ableFlag: false
comment: Ignore Old
flag: gmsi<order 1>
type: editprocess
---
IN:
<lb-hn\s*([^>]+)?>(?:[\s\S]*?)<\/lb-hn>
OUT:
{{#when::keep::{{? {{getglobalvar::toggle_lb-hn.context}}=0}}}}{{#when::keep::{{greater_equal::{{chat_index}}::{{? {{lastmessageid}}-9}}}}}}$&{{/when}}{{/when}}
