---
ableFlag: true
comment: Display Old KV
flag: g
type: editdisplay
---
IN:
<lb-xnai\s+kv>([^<]+?)<\/lb-xnai>
OUT:
<div class="lb-xnai-kv-wrapper"><div class="lb-xnai-kv">$1</div></div>
