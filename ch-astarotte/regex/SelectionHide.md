---
comment: SelectionHide
flag: gm
type: editdisplay
---

IN:
^<tarot-selection>[ \t]*\r?\n([^\r\n]*\r?\n[^\r\n]*)\r?\n^</tarot-selection>[ \t]*\r?\n?
OUT:
선택한 카드 (덱 순서/종류): $1
