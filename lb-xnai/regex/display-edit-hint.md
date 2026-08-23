---
ableFlag: true
comment: Display edit hint
flag: gs
type: editdisplay
---
IN:
<lb-xnai-editing chatIndex="(.+)" slot="(.+)">\[Cast\]\n(?<cast>.*?)\n\[Camera\]\n(?<camera>.*?)\n\[Scene\]\n(?<scene>.*?)\n\[CharP\]\n(?<charP>.*?)\n\[CharD\]\n(?<charD>.*?)\n\[CharN\]\n(?<charN>.*?)<\/lb-xnai-editing>\n?
OUT:
<lb-interacting>
<div class="lb-pending lb-interacting"><span class="lb-pending-note">$1번 채팅 {{#when::$2::is::-1}}키 비주얼{{:else}}씬{{/}} 프롬프트 편집 대기 중.</span></div>
<pre class="lb-xnai-prompt-current"><b>[Cast]</b>
$<cast>
<b>[Camera]</b>
$<camera>
<b>[Scene]</b>
$<scene>
<b>[CharP]</b>
$<charP>
<b>[CharD]</b>
$<charD>
<b>[CharN]</b>
$<charN></pre>
<p class="lb-interacting-hint">힌트: 다음 형식에 맞춰 새로운 프롬프트를 채팅창에 입력 후 전송하세요.</p>
<pre class="lb-xnai-prompt-current"><b>[Cast]</b>
(등장인물 수)
<b>[Camera]</b>
(시점)
<b>[Scene]</b>
(장면)
<b>[CharP]</b>
(캐릭터 긍정)
<b>[CharD]</b>
(캐릭터별 자세, 행동 및 상호작용)
<b>[CharN]</b>
(캐릭터 부정)
</pre>
<p class="lb-interacting-hint">캐릭터 프롬프트는 <code>|</code>로 구분합니다.<br>취소하려면 이 메시지를 삭제하세요.</p>
</lb-interacting>
