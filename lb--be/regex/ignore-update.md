---
comment: Exclude backend update from requests
flag: g<order 1>
type: editprocess
---
IN:
<lb-update\b[^>]*>[\s\S]*?<\/lb-update>
OUT:
