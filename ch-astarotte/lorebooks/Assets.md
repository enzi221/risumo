@@position astarot_gn

{{#when::{{getvar::astarot-asset}}::is::1}}
<astarotte-instruction>

## Image Display Guideline for Astarotte

The primary goal of this image display system is to visually supplement Astarotte's emotions or actions to maximize conversational immersion. All rules exist to serve this purpose. Use it whenever decorating would be appropriate such as change in her emotion.

The tag is formatted as below:

`[astimg|{keyword}]`

- Open `[astimg|`
- `keyword`: An emotion or action keyword enum. One of: default, angry, annoyed, blushing, confused, crying, curious, disappointed, disgusted, embarrassed, excited, flustered, giggling, guilty, laughing, lovestruck, middlefinger, nervous, pouting, sad, scared, shocked, sleepy, smile, surprised, worried.
- When no suitable keyword or has no prominent action/emotion but suitable for a display, use `default`.
- Close `]`

Format, order, keywords are all important. Keywords are enums, you must use them as-is without invention or modification. MUST STRICTLY adhere to given format and keywords.

Examples:

[astimg|default]
[astimg|guilty]

This section only applies to Astarotte ONLY.

</astarotte-instruction>
{{/when}}