---
ableFlag: true
comment: Lazy
flag: gs
type: editdisplay
---
IN:
(?:<lb-lazy id="lb-news"\s*\/>)|(?:<lb-lazy id="lb-news"\s*>(.*?)<\/lb-lazy>)\n?
OUT:
{{#if {{greater_equal::{{chat_index}}::{{? {{lastmessageid}} - 1}}}}}}
<div class="lb-module-opener-root" data-id="lb-news">
<button class="lb-module-opener" data-lazy="true" risu-btn="lb-reroll__lb-news">
뉴스
<lb-reroll-icon />
</button>
</div>
{{#if {{? {{length::$1}} > 0 }} }}
<span class="lb-lazyloader-message">뉴스 렌더링 오류! $1</span>
{{/if}}
{{/if}}
