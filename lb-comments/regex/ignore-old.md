---
ableFlag: true
comment: Ignore Old
flag: gs<order 1>
type: editprocess
---
IN:
<lb-comments\s*([^>]+)?>(?:.*?)<\/lb-comments>\n?
OUT:
{{#when::keep::{{? {{getglobalvar::toggle_lb-comments.context}}=0}}}}{{#when::keep::{{greater_equal::{{chat_index}}::{{? {{lastmessageid}}-5}}}}}}$&{{/when}}{{/when}}
