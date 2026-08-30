---
ableFlag: false
comment: CardDp
flag: g<cbs>
type: editdisplay
---

IN:
\[astcard\|(?:(?<major>\d+)|(?:(?<suit>\w+)\/(?<num>\d+)))(?<reversed>i)?\]
OUT:
{{#when::{{getvar::astarot-asset}}::is::1}}
{{#when {{? {{length::$<major>}} > 0}}}}
<img alt class="astarot-desc-card astarot-card"{{#when {{? {{length::$<reversed>}} > 0}}}} data-reversed{{/when}} src="{{raw::astarot-$<major>}}">
{{/when}}
{{#when {{? {{length::$<suit>}} > 0}}}}
<img alt class="astarot-desc-card astarot-card"{{#when {{? {{length::$<reversed>}} > 0}}}} data-reversed{{/when}} src="{{raw::astarot-suit-$<suit>}}" data-num="$<num>">
{{/when}}
{{/when}}
