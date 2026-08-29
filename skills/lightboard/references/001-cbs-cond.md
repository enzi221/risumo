# Conditionals

All conditionals treat `1` and `'true'` as truthy, and anything else is considered false.

## `#if`, `#if_pure` (legacy)

`{{#if {expression}}}`, `{{#if_pure {expression}}}`

`if` trims whitespace from every line, while `if_pure` preserves all whitespace. These blocks are included only for reference; do not use them.

## `#when`

`{{#when::{expression}}} ... {{:else}} ... {{/}}`

Trims whitespace at the start and end of the body. Use `#when::keep` to preserve it.

Built-in operators (A/B are expressions or other operators):

Basics:
{{#when::A::is::B}}...{{/when}} - Equality
{{#when::A::isnot::B}}...{{/when}} - !Equality
{{#when::A::>::B}}...{{/when}}
{{#when::A::<::B}}...{{/when}}
{{#when::A::>=::B}}...{{/when}}
{{#when::A::<=::B}}...{{/when}}
{{#when::not::A}}...{{/when}} - Negates A

Advanced:
{{#when::keep::A}}...{{/when}} - Keeps whitespace as is
{{#when::legacy::A}}...{{/when}} - Handles whitespace like #if, including its quirks
{{#when::var::A}}...{{/when}} - If the variable A is truthy.
{{#when::A::vis::B}}...{{/when}} - If the variable A equals the literal B.
{{#when::A::visnot::B}}...{{/when}} - If the variable A does not equal the literal B.
{{#when::toggle::A}}...{{/when}} - If the toggle A is enabled. Unlike {{getglobalvar}}, this operator does not use a `toggle_` prefix.
{{#when::A::tis::B}}...{{/when}} - If the toggle A equals the literal B. Do not use a `toggle_` prefix.
{{#when::A::tisnot::B}}...{{/when}} - If the toggle A does not equal the literal B. Do not use a `toggle_` prefix.

### Operator examples

{{#when::keep::not::condition}}...{{/when}}
{{#when::keep::condition1::and::condition2}}...{{/when}}

You can use whitespace instead of "::" if there is no operator.

{{#when {{? 1 == 1}}}}...{{/when}}
