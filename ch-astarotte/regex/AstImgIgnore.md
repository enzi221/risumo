---
comment: AstImgIgnore
type: editprocess
---

IN:
(\[astimg\|\w+\])
OUT:
{{#when {{greater_equal::{{chat_index}}::{{? {{lastmessageid}}-5}}}}}}
$1
{{/when}}
