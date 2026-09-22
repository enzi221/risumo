# 삽화

![스플래시 이미지](./l-xnai.png)

> > > [처음사용자용 가이드](https://arca.live/b/characterai/181037530)를 따라 백엔드와 삽화 기본 설정을 완료하세요

## 프리셋 관리

다음 위치 중 원하는 곳에, "프리셋 (이름)"이라는 이름의 로어북을 생성하세요.

- 캐릭터 로어북
- 활성화된 모듈

내용을 다음과 같이 교체하세요.

```
[Positive]
{prompt}, year 2025, masterpiece

[Negative]
bad quality, worst quality
```

`[Positive]`와 `[Negative]` 아래 내용은 사용 중인 NovelAI 그림체 관련 태그를 사용하세요. `{prompt}`의 위치는 적절한 곳으로 바꿀 수 있어요.

```
[Positive]
..., year 2025,

{prompt},

masterpiece, ...
```

삽화 토글의 "프리셋" 칸에 "이름"을 입력하면, 재생성을 포함한 이후 이미지는 그 프리셋을 사용해 생성됩니다.

## 태깅 가이드

다음 위치 중 원하는 곳에, 정확히 `lb-xnai.lb.extra` (엘비-엑스엔에이아이.엘비.엑스트라)라는 이름의 로어북을 생성하세요.

- 캐릭터 로어북
- 활성화된 모듈

내용을 다음과 같이 교체하세요.

```
## Tagging Guide for {{char}}

...
```

헤딩도 포함해서 정해진 형식은 없어요. 단, `##`부터 시작하세요.

태그를 제일 잘 표현할 수 있는 형태로 작성하세요. "may"와 "must" 따위로 준수 요구 수준을 정할 수 있어요. 캐릭터 외에 장소같은 것도 지정할 수 있어요.

```
## Tagging Guide

### Mephistopheles

Mephistopheles is red. State such with e.g. `interior, red bus` etc.

### Project Moon Characters

For appearance, ALWAYS prepend "x (project moon)" where `x` is the character's English name, e.g. "yi sang (project moon)".

LCB sinner uniform in its full set: Black jacket or coat, black vest, white shirt, red necktie, black shoes. Sinners may not wear some items.

#### Don Quixote

`short blonde hair`
```

[Limbus Company](...)에서의 예시

### 사용자 요구사항 고급

`lb-xnai.lb.extra`는 여러 개 넣으면 여러 개 들어가요.

- 페소 외형 태그용, 외부 모듈 로어북
- 캐릭터 외형 태그용, 캐릭터 로어북

외형 태그 시, 삽화는 준수 수준을 3단계로 나눠 생각해요.

- 참조(Reference): 상황에 따라 모델이 자유롭게 재구성할 수 있어요.
- 잠김(Locked): 주어진 태그는 반드시 넣어야 하지만, 주어지지 않은 태그는 상황에 따라 모델이 자유롭게 추가할 수 있어요.
- 확정(Closed): 주어진 태그는 반드시 넣어야 하고, 넣지 않은 태그는 임의로 추가하지 않아요.

기본적으로, 자연어로 안내를 제공하면 참조가 되고, 태그를 제공하면 잠김이 돼요. 한 개의 가이드 안에서 다른 준수 지침을 제공하려면 이 용어를 참고하세요.

```
## Tagging Guide for {{char}}

Locked tags for her appearance: `medium blonde hair, 1.1::golden eyes::, ...`
Reference tags for her signature fashion: `black techpunk jacket with blue lining, black boots, ...`
```

## 토글 가이드


