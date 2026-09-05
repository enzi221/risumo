---
ableFlag: true
comment: Hide Unparsed
flag: gs
type: editdisplay
---
IN:
<lb-xnai(?:\s+[^>]*)?>(.*?)<\/lb-xnai>\n?
OUT:
{{#when::keep::toggle::lb-xnai.showOld}}<div class="lb-xnai-inlay-wrapper"><div class="lb-xnai-inlay">$1</div></div>{{/when}}
