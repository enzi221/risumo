---
ableFlag: true
comment: Ignore lazy
flag: gmsi<order 1>
type: editprocess
---
IN:
<lb-lazy\b(?:[^>]*\/>|[^>]*>[\s\S]*?<\/lb-lazy>)\r?\n?
OUT:
