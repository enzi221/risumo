---
ableFlag: true
comment: Lazy
flag: gms
type: editdisplay
---
IN:
(?:<lb-lazy id="lb-xnai"\s*\/>)|(?:<lb-lazy id="lb-xnai"\s*>(.\*?)<\/lb-lazy>)\n?
OUT:
{{#when::{{chat_index}}::>=::{{lastmessageid}}}}
<div class="lb-module-opener-root" data-id="lb-xnai">
<button class="lb-module-opener" data-lazy="true" risu-btn="lb-reroll__lb-xnai">
삽화 그리기
<lb-reroll-icon />
</button>
</div>
{{/when}}
