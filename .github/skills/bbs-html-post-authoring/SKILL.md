---
name: bbs-html-post-authoring
description: Requirements and guidelines for authoring board post HTMLs.
---

# Post Authoring Instructions

This skill helps you write HTML content for board posts according to specific requirements and limitations.

## Requirements

When writing a board post, you must strictly follow these guidelines:

- No `<style>` tags allowed, only inline styles.
- No JavaScripts.
- Interactivity is limited to `<a>` links, or `<details>` and `<summary>`.
- Prefer vertical layouts for mobile compatibility.
- Images should be replaced with placeholder strings; user will replace them later.
- Do not consider accessiblity here. No need for semantic HTML or ARIA attributes.
- Font option is limited; use `'Noto Serif KR', serif` for serif, `'Pretendard', sans-serif` for sans-serif, `monospace` for monospace.
- `<a>` without `href` can be used to disable auto-linking. Preserve any such usage. Add such `<a>` around text that should not be auto-linked.
- `<a>` can't receive `style` attributes. Place inner `<span>` and style it instead. Take extra care so that there is no whitespace between `<a>` and inner `<span>`.
  - Specify `display: inline-block` to remove the link's underline.
- `<pre>` can't receive `style` attributes. Place inner `<div>` and style it instead. Take extra care so that there is no whitespace between `<pre>` and inner `<div>`.
- `<img>` has limited styling support. Prefer background images on `<div>` for more control.

## Available Features

- It's 2026 - Consider all CSS baseline features supported, including `min()`, `max()`, `clamp()`, etc.

## Unavailable Features

- Empty `div`s will have their `style` stripped. Add at least `&nbsp;` inside to preserve them.
- `<img>` is limited to `width` and `height`.
- `aspect-ratio`
- `flex`, `gap`
  - Use `display: grid` instead. Implement gaps with empty columns or rows.

## Quirks

Whitespaces in the source will be mostly ignored, unless in `<pre>`. To apply `white-space: pre`, `pre-wrap`, or `pre-line`, wrap the target text in `<pre>` first.
