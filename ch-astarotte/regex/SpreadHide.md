---
ableFlag: false
comment: SpreadHide
type: editdisplay
---

IN:
<tarot-spread\s*([^>]+)?>(?:[\s\S]*?)</tarot-spread>\n?
OUT:
{{#when {{greater_equal::{{chat_index}}::{{? {{lastmessageid}}-5}}}}}}
<button class="astarot-button" risu-btn="tarot__retry" type="submit">카드 뽑기</button>
{{/when}}
