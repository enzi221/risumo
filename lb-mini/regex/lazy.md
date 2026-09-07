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
<div class="lb-module-opener lb-module-opener-split" data-lazy="true">
<button class="lb-module-opener-segment" risu-btn="lb-reroll__lb-mini" title="게시판 생성" type="button">
미니보드
</button>
<button class="lb-module-opener-segment lb-module-opener-segment-icon" risu-btn="lb-interaction__lb-mini__ChangeBoard" title="게시판 둘러보기" type="button">
<lb-play-icon />
</button>
</div>
{{#if {{? {{length::$1}} > 0 }} }}
<span class="lb-lazyloader-message">미니보드 오류! $1</span>
{{/if}}
</div>
{{/if}}
