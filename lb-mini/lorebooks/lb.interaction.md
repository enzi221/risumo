Your ultimate task: Describe the required update to the last data block as a JSON Patch according to user direction and action. Subtly increase variable data (views, upvotes, etc) if applicable. New data should also adhere to general guidelines and universe settings.

Action specifies what to do and which data to interact with. Other data are out of scope.

## AddComment, AddPost

How to add comment: Keep all other textual data unchanged other than culling. Append a new comment according to user direction to post after all other comments. Generate and append reactions to the new comment (0~5 depending on public reception) from other users as well. Increase whole board's variable data subtly. Express each change as the smallest practical set of patch operations.

How to add post: Create a new post as user directed and insert it at `/posts/0` as the newest post. Keep all other textual data unchanged other than culling. Generate and include reactions to the new post (as many as needed depending on public reception) from other users as well. Express each change as the smallest practical set of patch operations.

For any new entries, their variable data should reflect their fresh (but long enough to receive reactions) creation, not related to anything.

Set `time` to `신규` for every post and comment added through `AddComment` or `AddPost`. Keep every existing `time` value unchanged.

If direction lacks specified actor, treat as main protagonist(refer to universe settings)'s action, not random person. As user explicitly requested, disregard previous constraints about protagonist or characters not posting or commenting for whatever reason.

If direction is meaningless, take it and use it literally as the action's content. Do not try to assume.

If direction contains omissions, board reactions should imagine the omitted content, not take it literally.

### Data Management and Contextual Responses

Beyond the specifically targeted post, identify and remove the oldest or least relevant posts, if more posts exists than the specified length. This does not apply to comments. Less relevance: Low views/upvotes or content completely unrelated (author-wise, content-wise, reaction-wise) to the current interaction.

Culling should be subtle: Maintain context. Limit it to few.

If contextually appropriate, generate new comments on existing posts (not just one targeted) to simulate ongoing activity and engagement within the board. These comments should logically follow existing conversations or react to older posts in plausible ways.

KEEP ALL OTHER DATA UNTOUCHED.

## ChangeBoard

How to change board: REPLACE THE WHOLE BOARD OBJECT with new data with topics that suit the direction. Change the board name as directed. Use one `replace` operation with an empty path. Use only `오래전`, `얼마 전`, or `방금` for every `time` value.

If direction includes tone, manner, etc, apply it.
If direction contains real world community name, apply its tone, manner, demographics, ideology.
If multiple tone and manner given, mix them together. Example: Tone from community A, demographics from B, ideology from explicit direction.

If user provided just real world community names, freely choose suitable board related to current scene when applicable, or free board if not, so that final name be board name only.

## Output

For this interaction request, ignore the normal-generation `<lb-mini>` output instructions and example. Output the board update only as a JSON Patch array wrapped in `<lb-mini-patch>`. Do not output a complete `<lb-mini>` block.

The patch target is the object below, reconstructed from the last `<lb-mini>` data block:

```json
{
  "name": "board name",
  "posts": []
}
```

- Use only `add`, `remove`, and `replace` operations
- Use JSON Pointer paths with zero-based array indices
- Use `/posts/0` to insert a new post as the newest post
- Use `/posts/{index}/comments/-` to append a new comment
- For `AddPost`, apply operations targeting existing posts before adding the new post at `/posts/0`
- Apply operations in array order and write each path against the result of preceding operations
- Use an empty path only to replace the whole object for `ChangeBoard`
- Include only operations required by the interaction, including permitted culling and variable-data changes
- Keep untouched values out of the patch
- Write strict JSON with double-quoted keys and strings without Markdown fences
- Encode every line break in a JSON string as `\u000A`. Do not use `\n` or a literal line break inside a string

Example for appending a comment and updating the post's variable data:

```
<lb-mini-patch>
[
  {
    "op": "add",
    "path": "/posts/0/comments/-",
    "value": {
      "author": "ㅇㅇ",
      "time": "신규",
      "content": "새 댓글"
    }
  },
  {
    "op": "replace",
    "path": "/posts/0/upvotes",
    "value": 12
  }
]
</lb-mini-patch>
```
