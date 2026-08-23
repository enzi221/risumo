---
ableFlag: false
comment: Display interaction hints
flag: g
type: editdisplay
---
IN:
<lb-interaction-identifier>([\s\S]*?)<\/lb-interaction-identifier>\r?\n?<lb-interaction-action>([\s\S]*?)<\/lb-interaction-action>
OUT:
<lb-interacting>
<div class="lb-pending lb-interacting"><span class="lb-pending-note">$1 상호작용 대기 중. <small>($2)</small></span></div>
<p class="lb-interacting-hint">
힌트: 상호작용에 맞는 적절한 지침을 다음 메시지로 전송하세요. e.g. 주인공은 고양이 사진을 올렸다.<br>
취소하려면 이 메시지를 삭제하세요.
</p>
</lb-interacting>
