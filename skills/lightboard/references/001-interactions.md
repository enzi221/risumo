# Lightboard Interactions

The user presses an interaction button, enters a direction, and sends the chat. The backend intercepts the chat and reroutes it as an interaction request.

First, define interaction types and behavior in `{identifier}.lb.interaction`. Then provide buttons that trigger those interactions.

The backend replaces `<lb-comment-icon />` with a comment icon, a speech-bubble `<svg>`.

## {identifier}.lb.interaction lorebook

```md
Your ultimate task: Update the data according to user direction. Action specifies what to do.

## SendMail

How to: The user direction defines the content {{char}} will send. Simulate the emails {{user}} receives afterward.

Preserve previous data as-is, and prepend the new mails to the `mails` array. Update unread count if applicable.

Not all emails need to relate to the sent email. There may also be no reply.
```

"SendMail" is an interaction type.

#### {identifier}.lb.thoughts-interaction (Optional)

Define this lorebook only when `{identifier}.lb.thoughts` is also defined.

```md
{{#when::my-module.thoughts::tis::0}}
Think step-by-step for final data, but keep minimal draft per step.
{{/when}}

Follow this template to produce the output of InteractionA:

1. ...
2. ...

---

For InteractionB:

1. ...
2. ...
```

## The button

Render a `<button>` as follows:

```
<button risu-btn="lb-interaction__my-module__SendMail">...</button>
```

Note the format: `lb-interaction__{identifier}__{interaction}`.

If the interaction targets a specific part, use `lb-interaction__{identifier}__{interaction}/{specifier}`. The specifier can be any value the LLM can use to identify the target in the data, such as a title or content.

The button can also have modifiers as a semicolon-separated list:

```
lb-interaction__{identifier}__{modifier1;modifier2;...}#{interaction}/{specifier}
```

- preserve: Does not remove the previous data block after the interaction.
- immediate: Does not wait for user input. Sends the request immediately without a user direction.

```
<button risu-btn="lb-interaction__my-module__immediate#ReceiveNewMails">...</button>
```
