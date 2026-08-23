---
ableFlag: false
comment: Lazy
type: editdisplay
---
IN:
(?:<lb-lazy id="lb-hn"\s*\/>)|(?:<lb-lazy id="lb-hn"\s*>([\s\S]*?)<\/lb-lazy>)\n?
OUT:
{{#if {{greater_equal::{{chat_index}}::{{? {{lastmessageid}} - 1}}}}}}
<div class="lb-module-opener-root" data-id="lb-hn">
<button class="lb-module-opener" data-lazy="true" risu-btn="lb-reroll__lb-hn">
헌터넷
<lb-reroll-icon />
</button>
</div>
{{#if {{? {{length::$1}} > 0 }} }}
<span class="lb-lazyloader-message">헌터넷 렌더링 오류! $1</span>
{{/if}}
{{/if}}
