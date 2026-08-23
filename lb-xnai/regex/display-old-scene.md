---
ableFlag: true
comment: Display Old Scene
flag: g
type: editdisplay
---
IN:
<lb-xnai\s+scene="\d+">([^<]+?)<\/lb-xnai>
OUT:
<div class="lb-xnai-inlay-wrapper"><div class="lb-xnai-inlay">$1</div></div>
