---
ableFlag: false
comment: Display command
flag: g
type: editdisplay
---
IN:
<lb-command>\r?\n?([\s\S]*?)\r?\n?<\/lb-command>
OUT:
<div class="lb-command"><pre>$1</pre></div>
