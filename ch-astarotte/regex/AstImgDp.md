---
comment: AstImgDp
type: editdisplay
---

IN:
\[astimg\|(?<emotion>\w+)\]
OUT:
{{#when::{{getvar::astarot-asset}}::is::1}}
{{#when::{{? {{getvar::astarot-infdist}} == 1}}::or::{{? {{chat_index}} > {{? {{lastmessageid}}-10}}}}}}
<div class="astarot-img-root">
  <div class="astarot-img-clip">
    <img alt="" class="astarot-img" src="{{raw::astarot-$<emotion>}}" />
  </div>
</div>
{{/when}}
<style>
  .astarot-img-root {
    --py: 11px;
    aspect-ratio: 1/1;
    width: 320px;
    box-sizing: border-box;
    clear: both;
    {{#when::{{getvar::astarot-align}}::is::1}}
    margin: 1.25em auto;
    {{:else}}
    margin: 1.25em 0;
    {{/when}}
    overflow: hidden;
    padding: var(--py) 0;
    position: relative;
    transition: 350ms cubic-bezier(0.5, 0.1, 0.2, 1);
  }

  .astarot-img-root::before {
    border: 10px solid;
    border-image: url({{raw::astarot-border}}) stretch;
    border-image-outset: var(--py) 0;
    border-image-slice: 119 90;
    border-image-width: 59.5px 45px;
    content: '';
    height: calc(100% - var(--py) * 2);
    inset: 0;
    pointer-events: none;
    position: absolute;
    top: var(--py);
    transition: 350ms cubic-bezier(0.5, 0.1, 0.2, 1);
    width: 100%;
  }

{{#when::{{getvar::astarot-hover}}::is::1}}
  .astarot-img-root:hover {
    aspect-ratio: 1/1.4;
  }
{{/when}}
  .astarot-img-root:hover::before {
    opacity: 0;
  }

  .astarot-img-clip {
    border-radius: 18px;
    height: 100%;
    overflow: hidden;
    width: 100%;
  }

  .astarot-img {
    display: block;
    margin: 0;
    object-fit: cover;
    object-position: top center;
    width: 100%;
  }
</style>
{{/when}}
