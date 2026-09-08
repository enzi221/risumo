---
comment: SelectionHide
flag: gm
type: editdisplay
---

IN:
^<tarot-selection>[ \t]*\r?\n[^\r\n]*\r?\n([^\r\n]*)\r?\n^</tarot-selection>[ \t]*\r?\n?
OUT:
<div class="astarot-selection-fallback" style="display:flex;flex-wrap:wrap;gap:8px">
{{#each {{split::$1::,}} as card}}
<img alt="{{slot::card}}" src="{{raw::astarot-{{#when {{contains::{{slot::card}}::/}}}}s-{{arrayelement::{{split::{{slot::card}}::/}}::0}}-{{/when}}{{tonumber::{{slot::card}}}}}}" style="width:100px;height:auto;{{#when {{endswith::{{slot::card}}::i}}}}transform:rotate(180deg);{{/when}}">
{{/each}}
</div>
