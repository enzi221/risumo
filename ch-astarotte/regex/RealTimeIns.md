---
comment: RealTimeIns
type: editinput
---

IN:
^
OUT:
{{#when::{{getvar::astarot-realtime}}::is::1}}
(Current real time: {{date::YYYY-MM-DD HH:mm:ss}})
{{/when}}


