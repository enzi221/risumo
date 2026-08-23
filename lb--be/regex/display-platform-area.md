---
ableFlag: true
comment: Display platform area
flag: gs
type: editdisplay
---
IN:
-{3}\r?\n+\[LBDATA START\]([\w\W]+?)\[LBDATA END\]\r?\n+-{3}
OUT:
<div class="lb-platform-area">
$1
</div>
