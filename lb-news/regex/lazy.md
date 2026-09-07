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
<div class="lb-module-opener lb-module-opener-split" data-lazy="true">
<button class="lb-module-opener-segment" risu-btn="lb-reroll__lb-news" title="뉴스 생성" type="button">
뉴스
</button>
<button class="lb-module-opener-segment lb-module-opener-segment-icon" risu-btn="lb-interaction__lb-news__ChangeBoard" title="뉴스 둘러보기" type="button">
<lb-play-icon />
</button>
</div>
</div>
{{#if {{? {{length::$1}} > 0 }} }}
<span class="lb-lazyloader-message">뉴스 렌더링 오류! $1</span>
{{/if}}
{{/if}}
