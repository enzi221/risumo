---
comment: SpreadHide
flag: gm
type: editdisplay
---

IN:
^<tarot-spread(?:[ \t]+[^>\r\n]*)?>[ \t]*\r?\n[\s\S]*?^</tarot-spread>[ \t]*\r?\n?
OUT:
{{#when::toggle::astarot-enabled}}
{{#when {{greater_equal::{{chat_index}}::{{? {{lastmessageid}}-5}}}}}}
<button class="astarot-button" risu-btn="tarot__retry" type="submit">카드 뽑기</button>
{{/when}}
{{/when}}
