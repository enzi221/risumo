---
comment: AstImgDp
type: editdisplay
---

IN:
\[astimg\|(?<emotion>\w+)\]
OUT:
{{#when::toggle::astarot-enabled}}
{{#when::toggle::astarot-character}}
{{#when::toggle::astarot-asset}}
{{#when::{{chat_index}}::>::{{? {{lastmessageid}}-10}}}}
<div class="astarot-img-root">
  <div class="astarot-img-clip">
    <img alt="" class="astarot-img" src="{{raw::astarot-$<emotion>}}" />
  </div>
</div>
{{/when}}
<style>
  .astarot-img-root {
    aspect-ratio: 1/0.8;
    background: #1a1625;
    box-shadow: 0 0 20px rgba(0, 0, 0, 0.7),
                0 0 0 1px #3a324b inset;
    width: 360px;
    border-radius: 12px;
    box-sizing: border-box;
    clear: both;
    margin: 1.25em 0;
    max-width: 100%;
    overflow: hidden;
    padding: 4px 4px 5px;
    position: relative;
    transition: 350ms cubic-bezier(0.5, 0.1, 0.2, 1);
  }

  .astarot-img-root::before {
    content: '';
    height: calc(100% - var(--py) * 2);
    inset: 0;
    pointer-events: none;
    position: absolute;
    transition: 350ms cubic-bezier(0.5, 0.1, 0.2, 1);
    width: 100%;
  }

  .astarot-img-root::after {
    content: '';
    position: absolute;
    bottom: 0;
    left: 0;
    width: 100%;
    height: 3px;
    background: linear-gradient(90deg, transparent, #cbb69b, transparent);
    opacity: 0.7;
  }

  .astarot-img-root:hover {
    aspect-ratio: 896/1152;
  }

  .astarot-img-clip {
    border-radius: 12px;
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
{{/when}}
{{/when}}
