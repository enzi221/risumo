---
comment: Display backend update
flag: g
type: editdisplay
---
IN:
<lb-update version="(\d+\.\d+\.\d+)">([^<]*)<\/lb-update>
OUT:
<div class="lb-update-notice"><button aria-label="업데이트 알림 닫기" class="lb-update-close" risu-btn="lb-update-dismiss" type="button">×</button><span class="lb-update-label">라이트보드 백엔드 $1 업데이트 가능</span><a class="lb-update-download" href="$2" rel="noopener noreferrer" target="_blank">다운로드</a></div>
