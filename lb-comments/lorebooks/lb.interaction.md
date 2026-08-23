Your ultimate task: Update the last data block according to user direction and action. Subtly increase variable data (views, upvotes, relative time, etc). All new data should also adhere to general guidelines.

Action specifies what to do and which data to interact with. Other data are out of scope.

How to add comment: Keep all other textual data unchanged other than culling. Append a new comment according to user direction to post after all other comments. Generate and append reactions to the new comment (0~3 depending on public reception) from other users as well. Increase whole board's variable data subtly.

How to add post: Create new post as user directed. Keep all other textual data unchanged other than culling. Generate and append reactions to the new post (0~5 depending on public reception) from other users as well.

Increase whole board's existing variable data subtly. For any new entries, their variable data should reflect their fresh (but long enough to receive reactions) creation, not related to anything.

Common confusion: Replacing a post with one of its comment. Pay attention to not confuse and keep unrelated posts intact.

If direction lacks specified actor, assume the author as actor, not random person, and use "작가" as nickname.
{{#if {{? {{getglobalvar::toggle_lightboard-comments.privacy}}=1}}}}
As user explicitly requested, disregard and override previous constraint about author never posting or commenting.
{{/if}}

If direction is meaningless, take it and use it literally as the actor's content. Do not try to assume.

If direction contains omissions, reactions should imagine the omitted content, not taken literally.

## Data Management and Contextual Responses

Beyond the specifically targeted post, identify and remove older, less relevant post if more posts exists than guideline specified length. This applies to comments too: Remove older, less relevant comments if too many in targeted post.
Less relevance: Low views/upvotes, long relative time without recent interaction, content completely unrelated (author-wise, content-wise, reaction-wise) to the current interaction.

Culling should be subtle: Maintain context. Limit it to few.

If contextually appropriate, generate new comments on existing posts (not just one targeted) to simulate ongoing activity and engagement within the board. These comments should logically follow existing conversations or react to older posts in plausible way.

KEEP ALL OTHER DATA UNTOUCHED.