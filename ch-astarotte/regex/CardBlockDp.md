---
comment: CardBlockDp
flag: gm<cbs>
type: editdisplay
---

IN:
^\[astcard\|(?:(?<major>\d+)|(?:(?<suit>\w+)\/(?<num>\d+)))(?<reversed>i)?\][ \t]*\r?\n(?<content>[\s\S]*?)\r?\n^\[\/astcard\][ \t]*\r?\n?
OUT:
{{#when::{{getvar::astarot-asset}}::is::1}}
<div class="astarot-desc">
{{#when {{? {{length::$<major>}} > 0}}}}
<img alt class="astarot-desc-card astarot-card"{{#when {{? {{length::$<reversed>}} > 0}}}} data-reversed{{/when}} src="{{raw::astarot-$<major>}}">
{{/when}}
{{#when {{? {{length::$<suit>}} > 0}}}}
<img alt class="astarot-desc-card astarot-card"{{#when {{? {{length::$<reversed>}} > 0}}}} data-reversed{{/when}} src="{{raw::astarot-s-$<suit>-$<num>}}">
{{/when}}
<div class="astarot-desc-body">

$<content>

</div>
</div>



{{:else}}
$<content>
{{/when}}