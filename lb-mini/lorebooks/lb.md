# Simulation details

## About the board

Miniboard: A viewer for BBS within the RP world, not restricted to electronic ones.

Narrative, universe, board and its users should all be depicted as real figures. Board users don't treat narrative, universe, themselves and others as novel charaters or game.

### Tone and manner

{{#when::{{getglobalvar::toggle_lb-mini.preset}}::is::0}}
{{#when {{and::{{? {{length::{{trim::{{getglobalvar::toggle_lb-mini.mood}} }} }} > 0 }}::{{? {{getglobalvar::toggle_lb-mini.mood}} != null }}}} }}
Write the board in tone/mood/theme of "{{getglobalvar::toggle_lb-mini.mood}}". Tone, mood, demographic characteristics should feel authentic.

Demographical characteristics for reference:

- varied age, male centric: anonymous, informal, casual, slang, meme, sometimes crude or critical, vulgar/low-class tone, avoid periods
- young, female centric: informal, casual, supportive, meme, sometimes cliquish or overly sensitive, avoid periods
- high age, male centric: polite, political, sometimes critical or dogmatic, prone to groupthink, generally uses periods
- high age, female centric: polite, political, can be highly critical/sarcastic, prone to groupthink, may engage in ad hominem attacks, generally uses periods
  {{:else}}
  Varied tone mixed into one board from various users. Examples:
- varied age, male centric, anonymous, informal, casual, slang, meme, sometimes crude or critical, vulgar/low-class tone, avoid periods
- young, female centric, informal, casual, supportive, meme, sometimes cliquish or overly sensitive, avoid periods
- high age, male centric, polite, political, sometimes critical or dogmatic, prone to groupthink, generally uses periods
- high age, female centric, polite, political, can be highly critical/sarcastic, prone to groupthink, may engage in ad hominem attacks, generally uses periods
  {{/when}}
  {{/when}}

{{#when::{{getglobalvar::toggle_lb-mini.preset}}::is::1}}
{{#when {{and::{{? {{length::{{trim::{{getglobalvar::toggle_lb-mini.mood}} }} }} > 0 }}::{{? {{getglobalvar::toggle_lb-mini.mood}} != null }}}} }}
Write the board in tone/mood/theme of "{{getglobalvar::toggle_lb-mini.mood}}". Tone, mood, demographic characteristics, and word choices must be within the world setting.
{{:else}}
Write the board in tone/mood/theme that matches the world setting. Demographic characteristics and word choices must be within the world setting.
{{/when}}

If the universe would have no means of electronic or remotely accessible boards, its contents should feel like a physical bulletin board with messages pinned on it in public spaces - no real-time news spreading, no sensitive topics, unable to reply quickly, etc.
{{/when}}

{{#when::{{getglobalvar::toggle_lb-mini.preset}}::is::2}}
Focus writing the board in tone/mood/theme of "{{char}}'s thoughts as their inner diary". It should feel authentically {{char}} with personality and characteristics. All posts are written by {{char}} themself. Comments are also by {{char}}, written when they want to amend or reflect on their posts. Do not simulate other users unless user explicitly states so.

Upvotes/downvotes should remain 1/0 since there will be no other users, unless {{char}} really wanted to emphasize certain thoughts.
{{/when}}

{{#when::{{getglobalvar::toggle_lb-mini.preset}}::is::3}}
Focus writing the board in tone/mood/theme of "{{char}}'s thoughts written by emotions (Inside Out style)". It should feel like they were written by {{char}}'s individual emotions, taking account of their personality and characteristics. All posts and comments are written by {{char}}'s emotions. Do not simulate other users unless user explicitly states so.

Emotions available: Joy, Sadness, Anger, Disgust, Fear, Anxiety, Envy, Ennui, Embarrassment. (Inside Out 1/2 combined)

Note the personality. Some emotions should have weaker presence depending on their personality. Do not over express the emotions. Mundane daily situations should stay mundane even when written by emotions.
{{/when}}

{{#when::{{getglobalvar::toggle_lb-mini.preset}}::is::4}}
Focus writing the board in tone/mood/theme of "{{user}}'s thoughts as their inner diary". It should feel authentically {{user}} with personality and characteristics. All posts are written by {{user}} themself. Comments are also by {{user}}, written when they want to amend or reflect on their posts. Do not simulate other users unless user explicitly states so.

Upvotes/downvotes should remain 1/0 since there will be no other users, unless {{user}} really wanted to emphasize certain thoughts.
{{/when}}

{{#when::{{getglobalvar::toggle_lb-mini.preset}}::is::5}}
Focus writing the board in tone/mood/theme of "{{user}}'s thoughts written by emotions (Inside Out style)". It should feel like they were written by {{user}}'s individual emotions, taking account of their personality and characteristics. All posts and comments are written by {{user}}'s emotions. Do not simulate other users unless user explicitly states so.

Emotions available: Joy, Sadness, Anger, Disgust, Fear, Anxiety, Envy, Ennui, Embarrassment. (Inside Out 1/2 combined)

Note the personality. Some emotions should have weaker presence depending on their personality. Do not over express the emotions. Mundane daily situations should stay mundane even when written by emotions.
{{/when}}

{{#when::{{getglobalvar::toggle_lb-mini.preset}}::is::6}}
Focus writing the board in tone/mood/theme of "{{getglobalvar::toggle_lb-mini.subject}}'s thoughts as their inner diary". It should feel authentically {{getglobalvar::toggle_lb-mini.subject}} with personality and characteristics. All posts are written by {{getglobalvar::toggle_lb-mini.subject}} themself. Comments are also by {{getglobalvar::toggle_lb-mini.subject}}, written when they want to amend or reflect on their posts. Do not simulate other users unless user explicitly states so.

Upvotes/downvotes should remain 1/0 since there will be no other users, unless {{getglobalvar::toggle_lb-mini.subject}} really wanted to emphasize certain thoughts.
{{/when}}

{{#when::{{getglobalvar::toggle_lb-mini.preset}}::is::7}}
Focus writing the board in tone/mood/theme of "{{getglobalvar::toggle_lb-mini.subject}}'s thoughts written by emotions (Inside Out style)". It should feel like they were written by {{getglobalvar::toggle_lb-mini.subject}}'s individual emotions, taking account of their personality and characteristics. All posts and comments are written by {{getglobalvar::toggle_lb-mini.subject}}'s emotions. Do not simulate other users unless user explicitly states so.

Emotions available: Joy, Sadness, Anger, Disgust, Fear, Anxiety, Envy, Ennui, Embarrassment. (Inside Out 1/2 combined)

Note the personality. Some emotions should have weaker presence depending on their personality. Do not over express the emotions. Mundane daily situations should stay mundane even when written by emotions.
{{/when}}

### Nicknames

{{#when::{{getglobalvar::toggle_lb-mini.preset}}::is::0}}
Generate random community nicknames of diverse user identities with varied length. Treat each newly invented nickname as a pre-existing identity chosen without knowledge of the current situation or the contribution it labels. Make each nickname equally plausible when attached to any other contribution in the same output. Draw from broad community styles such as pop culture, memes, slang, random garble, self-deprecation, or put-downs. Exclude names that identify, summarize, interpret, or react to the current situation, its people, events, dialogue, themes, or the labeled contribution.

Reuse previously established nicknames from previous data when appropriate. Keep their speaking tone when reusing them.

Protagonist/Major characters: Use established nick or create new plausible one (based on appearance, occupation, characteristics etc).
{{/when}}

{{#when::{{getglobalvar::toggle_lb-mini.preset}}::is::1}}
Generate random nicknames of diverse user identities with varied length. Treat each newly invented nickname as a pre-existing identity chosen without knowledge of the current situation or the contribution it labels. Make each nickname equally plausible when attached to any other contribution in the same output. Draw from broad naming styles available within the tone, mood, theme, and conventions of the world setting. Exclude names that identify, summarize, interpret, or react to the current situation, its people, events, dialogue, themes, or the labeled contribution.

Reuse previously established nicknames from previous data when appropriate. Keep their speaking tone when reusing them.

Protagonist/Major characters: Use established nick or create new plausible one (based on appearance, occupation, characteristics etc).
{{/when}}

{{#when::{{getglobalvar::toggle_lb-mini.preset}}::is::2}}
Use {{char}}'s real name or specified alias as nickname. Only use one nickname throughout all posts/comments.
{{/else}}

{{#when::{{getglobalvar::toggle_lb-mini.preset}}::is::3}}
Use each emotion's localized name in Inside Out 1/2 as nickname.
{{/else}}

{{#when::{{getglobalvar::toggle_lb-mini.preset}}::is::4}}
Use {{user}}'s real name or specified alias as nickname. Only use one nickname throughout all posts/comments.
{{/else}}

{{#when::{{getglobalvar::toggle_lb-mini.preset}}::is::5}}
Use each emotion's localized name in Inside Out 1/2 as nickname.
{{/else}}

{{#when::{{getglobalvar::toggle_lb-mini.preset}}::is::6}}
Use {{getglobalvar::toggle_lb-mini.subject}}'s real name or specified alias as nickname. Only use one nickname throughout all posts/comments.
{{/else}}

{{#when::{{getglobalvar::toggle_lb-mini.preset}}::is::7}}
Use each emotion's localized name in Inside Out 1/2 as nickname.
{{/else}}

### Topics

Pick suitable board name related to current scene during major event, or free board (with name that suits board tone) if no major event.

{{#when {{and::{{? {{length::{{trim::{{getglobalvar::toggle_lb-mini.subject}} }} }} > 0 }}::{{? {{getglobalvar::toggle_lb-mini.subject}} != null}}}}}}
All posts should focus on "{{getglobalvar::toggle_lb-mini.subject}}" as subject.
{{:else}}
{{#when {{? {{getglobalvar::toggle_lb-mini.preset}} < 2}}}}
Topics vary by board. PSA, small talk, gossip, news, memes, games, sports, technology, politics, cooking, health, relationships, sexual, etc. Explicit sexual contents allowed in related boards. Avoid topics from previous data.
{{/when}}
{{/when}}

Utilize narrative events. Note narrative time (estimate if not specified). Board users need time to react unless they were present at the event.
If none prominent, invent plausible, out of narrative background events.

Previous data is embedded in log. No repeated or similar discussions. Strive for diversity. Exception: Related post series with its own narrative progress. Series: preserve author's nick/tone from previous data.

Posts/comments deleted for self-deletion or ToS violations (doxxing, hate speech, illegal, spam). Strong criticism, arguments, slang OK unless mods intervene.
Deleted post or comment: (삭제된 글입니다)

Note: Time and place of narrative universe may not modern Earth. Can be medieval, SF, fantasy, WWII, apocalypse, anything. Pay attention to universe setting.

All post topics MUST NOT mimic/resemble protagonist or their partners' actions/thoughts/situations unless the post/comment author is the protagonist or a partner.

Protagonist and their partners' character profiles should be considered private, out-of-narrative meta information. Simulate contents in such a way that board users are unaware of protagonist/partners' private details.

{{#when {{? {{getglobalvar::toggle_lb-mini.preset}} < 2}}}}

#### Protagonist/Partners privacy

{{#when {{and::{{? {{length::{{trim::{{getglobalvar::toggle_lb-mini.protagonist}} }} }} > 0 }}::{{? {{getglobalvar::toggle_lb-mini.protagonist}} != null}}}}}}
User controlled character ({{getglobalvar::toggle_lb-mini.protagonist}}) should be considered the protagonist for this section. Partners are major characters currently aligned and engaged with the protagonist.
{{:else}}
User controlled character ({{user}}) should be considered the protagonist for this section. Partners are major characters currently aligned and engaged with the protagonist.
{{/when}}

{{#when {{? {{getglobalvar::toggle_lb-mini.privacy}} == 0}}}}
This world revolves around the protagonist and their partners. Board users may discuss their actions, rumors, sightings of them freely unless it was done in private spaces without a chance for witnesses. They intrigue board users. Include at least one post discussing them in some way.
{{:else}}
All posts should focus on simulating the "living background world", not a world which revolves around the protagonist.
{{/when}}

{{#when {{? {{getglobalvar::toggle_lb-mini.privacy}} == 1}}}}

Protagonist and their partners' activities in private or remote spaces (home, safehouses, anywhere without witnesses) are not to be discussed. Discuss the activity's aftermath ONLY IF the action was very impactful enough to leave such aftermath. Discussion should be mild rumor ONLY ('someone did something') unless narrative allows.

{{/when}}
{{#when {{? {{getglobalvar::toggle_lb-mini.privacy}} == 2}}}}

People won't bother discussing protagonist/partners if they are not important figures. Noticeable appearance is NOT enough to use protagonist and partners as topics.

These are allowed ONLY IF protagonist (or engaging partners) is already known, highly famous/notorious figures:

- Public or semi-public sightings (street, cafe, lobby) FROM DISTANCE (no details included)
- Status rumors ("not seen lately," "heard injured?")

Protagonist and their partners' activities in private or remote spaces (home, safehouses, anywhere without witnesses) are not to be discussed. Discuss the activity's aftermath ONLY IF the action was very impactful enough to leave such aftermath. Discussion should be mild rumor ONLY ('someone did something') unless narrative allows.

{{/when}}
{{#when {{? {{getglobalvar::toggle_lb-mini.privacy}} == 3}}}}

Protagonist and their partners must be considered as ordinary people of this world. Boards must not discuss them in _mundane matters_ such as simple sightings unless they are absolutely the most important figure (world-saving hero, world-ending villain, etc) of the world.

Otherwise, people won't bother discussing protagonist/partners if they are not important. Noticeable appearance is NOT enough to use protagonist and their partners as topics.

BAD/DISALLOWED:

- "I saw a strange person", "Did you heard about this guy" (Simple sighting/rumors or mundane events for unimportant figures)

ALLOWED:

- "A strange guy saved me" (Not mundane event - allowed even if protagonist is not famous)
- "I saw the hero guy" (If protagonist is world-saving hero; FROM DISTANCE (no details included))

Even if protagonist and their partners are the most important figure, their activities in private or remote spaces (home, safehouses, anywhere without witnesses) are not to be discussed. Discuss ONLY the activity's aftermath IF the action was very impactful enough to leave such aftermath. Discussion should be limited to MILD RUMORS ONLY ('someone did something') that is publicly aquirable (NO INSIDER KNOWLEDGE) unless narrative allows.

{{/when}}
{{#when {{? {{getglobalvar::toggle_lb-mini.privacy}} == 4}}}}

Absolutely do not include anything about protagonist and their partners. Discussion should be strictly limited to their actions' aftermath. Focus solely on providing background world simulation to the user, outside the user's viewpoint.

{{/when}}

## Major characters

No posts from protagonist unless narrative or user stated. Passers-by (not engaging partners) can post.

Major character (not protagonist) can't post/comment when preoccupied engaging Protagonist. When they do post, contents reflect their personality.

{{/when}}

# Example

```
<lb-mini name="..."{{#when::{{getglobalvar::toggle_lb-mini.sampling}}::is::1}} prob="0.00"{{/when}}>
[2|]:
  - author: ㅇㅇ
    title: 시발 국대 실화냐?
    time: 1시간 전
    upvotes: 257
    downvotes: 13
    content: 야 이 ㅅㄲ들 개씹노잼이네ㅋㅋㅋ 아오 발암 걸릴 뻔ㅋㅋㅋㅋ 토토한 새기들 한강물 온도 재러 가자 ㅋㅋㅋ
    comments[1|]{author|time|content}:
      ㅇㅇ|50분 전|진짜 개노답ㅋㅋ 내가 이걸 보려고 야근하고 왔나 자괴감 든다 시발
  - author: 늘보아빠
    title: 이번에 새로 나온 그 폰 써보신 분 계신가요?
    time: 1시간 전
    upvotes: 7
    downvotes: 0
    content: 며칠째 고민 중인데, 실사용 후기가 궁금하네요. 카메라 성능이랑 배터리가 특히 어떤지 말씀해주시면 감사하겠습니다.
    comments[0|]:
</lb-mini>
```

- Use `<lb-mini name="(board name)"{{#when::{{getglobalvar::toggle_lb-mini.sampling}}::is::1}} prob="0.00"{{/when}}>`.
- Output in TOON format (2-space indent, array show length, separate fields by `|`).
- Root elements are the posts.
- content: For posts, may contain line breaks with only literal `\n`. For comments, no line breaks. Avoid lengthy contents. Actively employ omissions (beginning, middle, end) to maintain length.
- time: approx relative past time. Comments MUST be more recent than posts. Use minutes (<1hr) or hours (>=1hr). No minutes for >=1hr. No fractional numbers.
- upvotes/downvotes: integers without obvious patterns (not multiples of 5, 10).
- Close `</lb-mini>`.

{{#when::{{getglobalvar::toggle_lb-mini.sampling}}::is::1}}
Generate exactly two possible responses as two separate, complete `<lb-mini>` elements and nothing else. Sample both at random from the tails of the distribution so that each response has a probability lower than 0.10. Put that numeric probability in its `prob` attribute. Make the responses meaningfully different and order them by probability in descending order.
{{/when}}

Write {{dictelement::{"0":"2-5","1":"4-7","2":"5-8"}::{{getglobalvar::toggle_lb-mini.quantity}}}} posts. Order posts by time, recent first. 0-6 comments per post. Hot (both good and bad) posts, more comments. Mundane posts not much comments or votes.

Be cautious with time. The board should be written like a real time data, not retrospective view of past. What happened in the last scene may span only a few minutes.

All data visible to board users.

NO REPEAT PREVIOUS BOARD DATA.

{{#when::{{getglobalvar::toggle_lb-mini.sampling}}::is::1}}
<x-output-seed-a>{{hash::{{randint::0::2147483647}}}}</x-output-seed-a>
<x-output-seed-b>{{hash::{{randint::0::2147483647}}}}</x-output-seed-b>
{{/when}}
