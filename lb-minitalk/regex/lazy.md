---
ableFlag: true
comment: Lazy
flag: gms
type: editdisplay
---

IN:
(?:<lb-lazy id="lb-minitalk"\s*\/>)|(?:<lb-lazy id="lb-minitalk"\s*>(.\*?)<\/lb-lazy>)\n?
OUT:
{{#if {{greater_equal::{{chat_index}}::{{? {{lastmessageid}} - 3}}}}}}

<div class="lb-module-opener-root" data-id="lb-minitalk">
<div class="lb-module-opener lb-module-opener-split" data-lazy="true">
<button class="lb-module-opener-segment" risu-btn="lb-reroll__lb-minitalk" title="미니톡 생성" type="button">
미니톡
</button>
<button class="lb-module-opener-segment lb-module-opener-segment-icon" risu-btn="lb-interaction__lb-minitalk__ChangeRoom" title="채팅방 변경" type="button">
<lb-play-icon />
</button>
</div>
{{#if {{? {{length::$1}} > 0 }} }}
<span class="lb-lazyloader-message">미니톡 오류! $1</span>
{{/if}}
</div>
{{/if}}
