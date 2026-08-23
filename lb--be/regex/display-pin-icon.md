---
ableFlag: false
comment: Display pin icon
type: editdisplay
---
IN:
<lb-pin-icon(\s+pinned="true")?\s*/>
OUT:
<svg xmlns="http://www.w3.org/2000/svg" width="15" height="15" fill="none" viewBox="0 0 15 15"><path fill="currentColor" fill-rule="evenodd" d="M10.33 1.14a.5.5 0 0 0-.7.7l.64.66-4.84 3.63-1.11-1.1a.5.5 0 0 0-.7.7l1.4 1.42L6.1 8.2l-3.27 3.27a.5.5 0 1 0 .7.7L6.8 8.91l1.06 1.06 1.42 1.42a.5.5 0 1 0 .7-.7l-1.1-1.12 3.63-4.84.66.65a.5.5 0 1 0 .7-.7L12.8 3.6l-1.4-1.4zm-4.19 5.7 4.85-3.63.8.8-3.64 4.85z" clip-rule="evenodd"/>{{#when::{{length::$1}}::>::1}}<path fill="currentColor" fill-rule="evenodd" d="M9.62 1.14c.2-.2.51-.2.7 0L11.4 2.2l1.4 1.4 1.06 1.06a.5.5 0 1 1-.7.7l-.66-.64-3.63 4.84 1.1 1.11a.5.5 0 0 1-.7.7l-1.42-1.4L6.8 8.9l-3.27 3.27a.5.5 0 1 1-.7-.7L6.09 8.2 5.03 7.15 3.6 5.73a.5.5 0 1 1 .7-.7l1.12 1.1 4.84-3.63-.65-.66a.5.5 0 0 1 0-.7" clip-rule="evenodd"/>{{/when}}</svg>
