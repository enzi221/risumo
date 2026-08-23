---
ableFlag: false
comment: Lazy
flag:
type: editdisplay
---
IN:
(?:<lb-lazy id="lb-stats"\s*\/>)|(?:<lb-lazy id="lb-stats"\s*>([\s\S]*?)<\/lb-lazy>)\n?
OUT:
{{#if {{greater_equal::{{chat_index}}::{{? {{lastmessageid}} - 1}}}}}}
<div class="lb-module-opener-root" data-id="lb-stats">
<button class="lb-module-opener" data-lazy="true" risu-btn="lb-reroll__lb-stats">
상태창
<lb-reroll-icon />
</button>
</div>
{{#if {{? {{length::$1}} > 0 }} }}
<span class="lb-lazyloader-message">상태창 렌더링 오류! $1</span>
{{/if}}
{{/if}}
