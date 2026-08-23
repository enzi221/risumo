---
ableFlag: true
comment: Lazy
flag: gms
type: editdisplay
---
IN:
(?:<lb-lazy id="lb-mini"\s*\/>)|(?:<lb-lazy id="lb-mini"\s*>(.*?)<\/lb-lazy>)\n?
OUT:
{{#if {{greater_equal::{{chat_index}}::{{? {{lastmessageid}} - 3}}}}}}
<div class="lb-module-opener-root" data-id="lb-mini">
<button class="lb-module-opener" data-lazy="true" risu-btn="lb-reroll__lb-mini">
미니보드
<lb-reroll-icon />
</button>
{{#if {{? {{length::$1}} > 0 }} }}
<span class="lb-lazyloader-message">미니보드 오류! $1</span>
{{/if}}
</div>
{{/if}}
