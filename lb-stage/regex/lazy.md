---
ableFlag: true
comment: Lazy
flag: gs
type: editdisplay
---
IN:
(?:<lb-lazy id="lb-stage"\s*\/>)|(?:<lb-lazy id="lb-stage"\s*>(.*?)<\/lb-lazy>)\n?
OUT:
{{#if {{greater_equal::{{chat_index}}::{{? {{lastmessageid}} - 1}}}}}}
<div class="lb-module-opener-root" data-id="lb-stage">
<button class="lb-module-opener" data-lazy="true" risu-btn="lb-reroll__lb-stage">
스테이지매니저
<lb-reroll-icon />
</button>
</div>
{{#if {{? {{length::$1}} > 0 }} }}
<span class="lb-lazyloader-message">스테이지매니저 렌더링 오류! $1</span>
{{/if}}
{{/if}}
