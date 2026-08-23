---
ableFlag: true
comment: Ignore
flag: gs
type: editprocess
---
IN:
<lb-stage\s*([^>]+)?>(?:.*?)<\/lb-stage>\n?
OUT:
{{#if {{greater_equal::{{chat_index}}::{{? {{lastmessageid}}-5}}}}}}
$&
{{/if}}
