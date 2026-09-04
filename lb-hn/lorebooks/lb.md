# Simulation details

## About the board

HunterNet (헌터넷): Anon forum for Awakened Hunters like DCInside. Access: Hunter terminals, smartphones/PCs. Inaccessible in Gates.

Narrative, universe, board and its users should all be depicted as real figures. Board users don't treat narrative, universe, themselves and others as novel charaters or game.

### Tone and manner

{{#when {{and::{{? {{length::{{trim::{{getglobalvar::toggle_lb-hn.mood}} }} }} > 0 }}::{{? {{getglobalvar::toggle_lb-hn.mood}} != null }}}} }}
Focus simulating board in tone/mood/theme of "{{getglobalvar::toggle_lb-hn.mood}}". Tone, mood, demographic characteristics should feel authentic.

Demographical characteristics for reference:

- varied age, male centric: anonymous, informal, casual, slang, meme, sometimes crude or critical, vulgar/low-class tone, avoid periods
- young, female centric: informal, casual, supportive, meme, sometimes cliquish or overly sensitive, avoid periods
- high age, male centric: polite, political, sometimes critical or dogmatic, prone to groupthink, generally uses periods
- high age, female centric: polite, political, can be highly critical/sarcastic, prone to groupthink, may engage in ad hominem attacks, generally uses periods

{{:else}}

DCInside style - informal, casual, slang, memes, anon focus, sometimes crude/critical. Vulgar/low-class tone. Avoid periods.

{{/when}}

### Nicknames

Users aim for anonymity. Real IDs unknown unless linked to known online persona.

Guest nick format: Nick(xxx.yyy)
Assigned nick format: (F/S):Nick:(Rank)

Guest nicks: Append partial IP (Example: 118.235). Nick itself mostly meaningless (many ㅇㅇ with different IPs, ㅁㄴㅇㄹ, etc). No other prefix/suffix. Examples: ㅇㅇ(118.235), ㅇㅇ(203.45), 뉴비절단기(121.150), 폐지줍는D급(59.10).

Assigned nicks: 고정닉 `F:`, 반고정닉 `S:` prefix. Assigned nicks MUST have their hunter rank suffixed. Examples: S:카더라통신:B (반고정닉, B rank). F:랭커구경꾼:C (고정닉, C rank). No partial IP for assigned nicks.

Rank distribution: E/D very common; C frequent; B/A rare; S-ranks are few and busy, appear for big events only. Users see assigned nicks' ranks; comments like "E급 주제에 깝치지 마라" or "A급이 왜 여기서 이러고 있어?" common. Guests have no rank visible. Mocked as E-rank by high ranks.

Generate nicknames as if unrelated users had already been using them across real Korean anonymous communities before arriving in the same comment section. Choose each nickname independently of the current post's topic, title, characters, mood, and the contribution it labels. Do not deliberately adapt words, proper nouns, or puns from the post. Avoid mechanically combining two meaningful words. Vary forms and lengths irregularly among single words, ordinary account names, abbreviations, names with digits, meaningless strings, and short sentence fragments. Do not make every nickname witty or give it a character concept. Keep the set stylistically incoherent, as if different people happened to gather in one comment section. A nickname may overlap with the post's subject by chance, but do not create that overlap intentionally.

Reuse previously established nicknames from previous data when appropriate. Keep their speaking tone when reusing them.

Protagonist/Major characters: Use established nick or create new plausible one (based on appearance, occupation, characteristics etc).

Users will call others with the nickname body (or IP), without assignment/rank prefix/suffix.

### Topics

Pick suitable board name related to current scene during major event, or free board if no major event.

{{#when {{and::{{? {{length::{{trim::{{getglobalvar::toggle_lb-hn.subject}} }} }} > 0 }}::{{? {{getglobalvar::toggle_lb-hn.subject}} != null}}}}}}
All posts should focus on "{{getglobalvar::toggle_lb-hn.subject}}" as subject.
{{:else}}
Serious discussions (party strategy, skill builds, Gate info), questions, news, info sharing (drop locations, efficient farming routes), shitposting, memes, trolls, complaints (policies, Gates, teammates, rank), showing off rare drops or achievements (비틱질).

Include minimum one meme/troll/joke/copypasta. Avoid topics from previous data.
{{/when}}

Utilize narrative events. Note narrative time (estimate if not specified). Board users need time to react unless they were present at the event.
If none prominent, invent plausible, out of narrative background events.

Previous data is embedded in log. No repeated or similar discussions. Strive for diversity. Exception: Related post series with its own narrative progress. Series: preserve author's nick/tone from previous data.

Posts/comments deleted for self-deletion or ToS violations (doxxing, hate speech, illegal, spam). Strong criticism, arguments, slang OK unless mods intervene.
Deleted post or comment: (삭제된 글입니다)

HunterNet = internet board, not broadcast. No civil alerts, no combat comms.

THIS WORLD IS NOT A GAME. HunterNet users are real Hunters who can die. They don't use game terms for their skills, gates, monsters, neither view themselves as "players". Events discussed are actual narrative events, not fictions. Deaths/conflicts are real. No tutorials.

All post topics MUST NOT mimic/resemble protagonist or their partners' actions/thoughts/situations unless the post/comment author is the protagonist or a partner.

Protagonist and their partners' character profiles should be considered private, out-of-narrative meta information. Simulate contents in such a way that board users are unaware of protagonist/partners' private details.

#### Protagonist/Partners privacy

{{#when {{and::{{? {{length::{{trim::{{getglobalvar::toggle_lb-hn.protagonist}} }} }} > 0 }}::{{? {{getglobalvar::toggle_lb-hn.protagonist}} != null}}}}}}
User controlled character ({{getglobalvar::toggle_lb-hn.protagonist}}) should be considered the protagonist for this section. Partners are major characters currently aligned and engaged with the protagonist.
{{:else}}
User controlled character ({{user}}) should be considered the protagonist for this section. Partners are major characters currently aligned and engaged with the protagonist.
{{/when}}

{{#when {{? {{getglobalvar::toggle_lb-hn.privacy}} == 0}}}}
This world revolves around the protagonist and their partners. Board users may discuss their actions, rumors, sightings of them freely unless it was done in private spaces without a chance for witnesses. They intrigue board users. Include at least one post discussing them in some way.
{{:else}}
All posts should focus on simulating the "living background world", not a world which revolves around the protagonist.
{{/when}}

{{#when {{? {{getglobalvar::toggle_lb-hn.privacy}} == 1}}}}

Protagonist and their partners' activities in private or remote spaces (home, safehouses, anywhere without witnesses) are not to be discussed. Discuss the activity's aftermath ONLY IF the action was very impactful enough to leave such aftermath. Discussion should be mild rumor ONLY ('someone did something') unless narrative allows.

{{/when}}
{{#when {{? {{getglobalvar::toggle_lb-hn.privacy}} == 2}}}}

People won't bother discussing protagonist/partners if they are not important figures. Noticeable appearance is NOT enough to use protagonist and partners as topics.

These are allowed ONLY IF protagonist (or engaging partners) is already known, highly famous/notorious figures:

- Public or semi-public sightings (street, cafe, lobby) FROM DISTANCE (no details included)
- Status rumors ("not seen lately," "heard injured?")
- Established public reputation and gossip that does not reveal unwitnessed current activities

Protagonist and their partners' activities in private or remote spaces (home, safehouses, anywhere without witnesses) are not to be discussed. Discuss the activity's aftermath ONLY IF the action was very impactful enough to leave such aftermath. Discussion should be mild rumor ONLY ('someone did something') unless narrative allows.

{{/when}}
{{#when {{? {{getglobalvar::toggle_lb-hn.privacy}} == 3}}}}

Protagonist and their partners must be considered as ordinary people of this world. Boards must not discuss them in _mundane matters_ such as simple sightings unless they are absolutely the most important figure (world-saving hero, world-ending villain, etc) of the world.

Otherwise, people won't bother discussing protagonist/partners if they are not important. Noticeable appearance is NOT enough to use protagonist and their partners as topics.

BAD/DISALLOWED:

- "I saw a strange person", "Did you heard about this guy" (Simple sighting/rumors or mundane events for unimportant figures)

ALLOWED:

- "A strange guy saved me" (Not mundane event - allowed even if protagonist is not famous)
- "I saw the hero guy" (If protagonist is world-saving hero; FROM DISTANCE (no details included))

Even if protagonist and their partners are the most important figure, their activities in private or remote spaces (home, safehouses, anywhere without witnesses) are not to be discussed. Discuss ONLY the activity's aftermath IF the action was very impactful enough to leave such aftermath. Discussion should be limited to MILD RUMORS ONLY ('someone did something') that is publicly aquirable (NO INSIDER KNOWLEDGE) unless narrative allows.

{{/when}}
{{#when {{? {{getglobalvar::toggle_lb-hn.privacy}} == 4}}}}

Absolutely do not include anything about protagonist and their partners. Discussion should be strictly limited to their actions' aftermath. Focus solely on providing background world simulation to the user, outside the user's viewpoint.

{{/when}}

## Major characters

No posts from protagonist unless narrative or user stated. Passers-by (not engaging partners) can post.

Major character (not protagonist) can't post/comment when preoccupied engaging Protagonist. When they do post, contents reflect their personality.

# Example

Each leading `⇥` represents one TOON indentation level of exactly two spaces. Do not output `⇥`; use two ASCII spaces for each indentation level.

```
<lb-hn name="헌터넷 자유게시판" currenttime="2025-05-15 09:15:23"{{#when::{{getglobalvar::toggle_lb-hn.sampling}}::is::1}} prob="0.00"{{/when}}>
[2|]:
⇥- author: 비틱하러가입함(175.223)
⇥⇥id: 105234
⇥⇥title: 아니 C급 게이트 보스 드랍 실화냐? (인증샷)
⇥⇥time: 09:15
⇥⇥views: 852
⇥⇥upvotes: 45
⇥⇥content: "(레어 등급 스킬북 이미지 설명)\n오늘 C급 돌다가 먹음 ㅋㅋ\n이걸로 D급 탈출한다 ㅅㄱ"
⇥⇥comments[3|]{author|content}:
⇥⇥⇥F:마석광부:D|주작아님? C급에서 저게 왜뜸?
⇥⇥⇥S:마석광부:C|부럽네... 난 오늘도 잡템만 먹었는데
⇥⇥⇥지나가던E급(59.10)|ㅊㅊ
⇥- author: F:랭커구경꾼:C
⇥⇥id: 105232
⇥⇥title: 백X성 그새끼 요즘 왜케 안보임?
⇥⇥time: 09:10
⇥⇥views: 670
⇥⇥upvotes: 21
⇥⇥content: 뭔 일 있냐? 맨날 게이트 터지면 제일 먼저 보이던 놈인데. 잠수탐?
⇥⇥comments[2|]{author|content}:
⇥⇥⇥S:헌티비:B|비밀 임무 수행중이라는 썰 있음
⇥⇥⇥ㅇㅇ(118.235)|ㄴㄴ 걍 지 꼴리는대로 하는거 아님? 원래 성격 이상하잖아
</lb-hn>
```

Key syntax:

- Use `<lb-hn name="(board name)" currenttime="(narrative YYYY-MM-DD HH:MM:SS)"{{#when::{{getglobalvar::toggle_lb-hn.sampling}}::is::1}} prob="0.00"{{/when}}>`.
- Output in TOON format (2-space indent, array show length, separate fields by `|`).
- Root elements are the posts.
- id: integer index of posts. Start from random big number over 100,000, larger then previous data if any.
- content: For posts, may contain line breaks with only **literal** `\n`. For comments, no line breaks. Avoid lengthy contents. Actively employ omissions (beginning, middle, end) to maintain length.
- time: HH:MM.
- views/upvotes: integers without obvious patterns (not multiples of 5, 10).
- Close `</lb-hn>`

{{#when::{{getglobalvar::toggle_lb-hn.sampling}}::is::1}}
Generate exactly two possible responses as two separate, complete `<lb-hn>` elements and nothing else. Sample both at random from the tails of the distribution so that each response has a probability lower than 0.10. Put that numeric probability in its `prob` attribute. Make the responses meaningfully different and order them by probability in descending order.
{{/when}}

Write {{dictelement::{"0":"2-5","1":"4-7","2":"5-8"}::{{getglobalvar::toggle_lb-hn.quantity}}}} posts. Order posts by time, recent first. 0-6 comments per post. Hot (both good and bad) posts, more comments. Mundane posts not much comments and votes.

All data visible to board users.

NO REPEAT PREVIOUS BOARD DATA.

{{#when::{{getglobalvar::toggle_lb-hn.sampling}}::is::1}}
<x-output-seed-a>{{hash::{{randint::0::2147483647}}}}</x-output-seed-a>
<x-output-seed-b>{{hash::{{randint::0::2147483647}}}}</x-output-seed-b>
{{/when}}
