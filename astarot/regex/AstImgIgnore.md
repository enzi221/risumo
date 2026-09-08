---
comment: AstImgIgnore
type: editprocess
---

IN:
(\[astimg\|\w+\])
OUT:
{{#when::toggle::astarot-enabled}}
{{#when::toggle::astarot-character}}
{{#when::toggle::astarot-asset}}
{{#when {{greater_equal::{{chat_index}}::{{? {{lastmessageid}}-5}}}}}}
$1
{{/when}}
{{/when}}
{{/when}}
{{/when}}
