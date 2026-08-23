---
ableFlag: true
comment: Lazy
flag: gs
type: editdisplay
---
IN:
(?:<lb-lazy id="lb-comments"\s*\/>)|(?:<lb-lazy id="lb-comments"\s*>(.*?)<\/lb-lazy>)\n?
OUT:
{{#if {{greater_equal::{{chat_index}}::{{? {{lastmessageid}} - 1}}}}}}
<div class="lb-module-opener-root" data-id="lb-comments">
<button class="lb-module-opener" data-lazy="true" risu-btn="lb-reroll__lb-comments">
댓글
<lb-reroll-icon />
</button>
</div>
{{/if}}
