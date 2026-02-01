IN: (?:<lb-lazy id="lb-xnai"\s*\/>)|(?:<lb-lazy id="lb-xnai"\s*>(.\*?)<\/lb-lazy>)\n?
OUT:
{{#when::{{chat_index}}::>=::{{lastmessageid}}}}
<div class="lb-xnai-placeholder-wrapper">
<button class="lb-xnai-placeholder" risu-btn="lb-reroll__lb-xnai">
✦ 삽화 그리기
</button>
</div>
{{/when}}

---
