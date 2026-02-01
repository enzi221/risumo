# LightBoard Backend: sideEffect Manifest 지원

## 개요

sideEffect manifest는 LBDATA 블록 외부(본문)를 직접 수정하기 위한 기능.
일반 manifest는 LBDATA 블록 내에 결과를 삽입하지만, sideEffect manifest는 본문 전체를 수정할 수 있음.

## 요구사항

### 1. Manifest 필드 추가

- `sideEffect: boolean` - true일 경우 LBDATA 외부 수정 모드
- `insertOrder: number` - lorebook item의 insertorder 사용, 내림차순 정렬

### 2. 실행 순서

1. 일반 manifests 전체 병렬 실행
2. 일반 manifests 결과를 LBDATA 블록에 조립
3. sideEffect manifests 순차 실행 (insertOrder 내림차순)
4. 각 sideEffect의 `onOutput(tid, llmResult, currentChatContent) → modifiedChatContent`로 본문 수정

### 3. sideEffect onOutput 시그니처

- 일반: `onOutput(triggerId, output) → processedOutput`
- sideEffect: `onOutput(triggerId, output, chatContent) → modifiedChatContent`

### 4. sideEffect는 LBDATA에서 제외

- sideEffect manifest의 결과는 LBDATA 블록에 포함되지 않음
- onOutput이 본문 전체를 직접 수정

### 5. 오류 처리

- 개별 sideEffect 실패 시 로그 남기고 다음으로 진행 (전체 중단하지 않음)

### 6. reroll/interaction 지원

- sideEffect manifest도 reroll/interaction 지원
- 태그 제거 후 `runPipeline` → `onOutput(tid, result, cleanedChat)` 호출
- 기존 위치 복원 불필요, onOutput 반환값으로 전체 교체

---

## 구현 단계

### Step 1: manifest.lua 수정

**파일**: `lb--be/manifest.lua`

- [ ] `tbl.insertOrder = item.insertOrder or 0` 저장
- [ ] `tbl.sideEffect = resolveConfig(triggerId, tbl.sideEffect, id, "sideEffect", false)` 추가
- [ ] 반환 전 정렬: `table.sort(parsedManifests, function(a,b) return (a.insertOrder or 0) > (b.insertOrder or 0) end)`

### Step 2: main() 함수 분리 - init.lua

**파일**: `lb--be/init.lua` (L272-290)

- [ ] manifests를 `normalManifests`, `sideEffectManifests`로 필터링
- [ ] 둘 다 insertOrder 정렬 유지

### Step 3: 일반 manifest 실행 및 LBDATA 조립 - init.lua

**파일**: `lb--be/init.lua` (L292-345)

- [ ] 기존 병렬 실행 로직을 `normalManifests`만 대상으로 변경
- [ ] LBDATA 조립 로직 유지

### Step 4: sideEffect 실행 단계 추가 - init.lua

**파일**: `lb--be/init.lua` (LBDATA 조립 후)

- [ ] LBDATA 조립 완료 후 sideEffect 단계 추가
- [ ] sideEffect manifests 순차 실행
- [ ] 각 sideEffect: `runPipeline` → `onOutput(tid, llmResult, currentChatContent)`
- [ ] 반환값으로 `lastCharChat` 갱신 → 최종 `setChat()`
- [ ] 개별 실패 시 pcall로 감싸서 로그 후 계속 진행

### Step 5: reroll() 함수 sideEffect 분기 - init.lua

**파일**: `lb--be/init.lua` (L403-480)

- [ ] `man.sideEffect` 체크 분기 추가
- [ ] sideEffect일 경우:
  - `removeNode()`로 identifier 태그 제거
  - `runPipeline` 실행
  - `onOutput(tid, result, cleanedChat)` 호출
  - 반환값으로 전체 교체 (기존 insertAtPosition/fallbackInsert 대신)
- [ ] 일반일 경우: 기존 로직 유지

### Step 6: interact() 함수 sideEffect 분기 - init.lua

**파일**: `lb--be/init.lua` (L527-620)

- [ ] `man.sideEffect` 체크 분기 추가
- [ ] sideEffect일 경우:
  - `removeNode()`로 identifier 태그 제거
  - `runPipeline` 실행
  - `onOutput(tid, result, cleanedChat)` 호출
  - 반환값으로 전체 교체
- [ ] 일반일 경우: 기존 로직 유지

### Step 7: 타입 주석 업데이트

**파일**: `lb--be/manifest.lua` 또는 별도 타입 파일

- [ ] `Manifest` 타입에 `sideEffect: boolean?`, `insertOrder: number?` 추가
- [ ] sideEffect용 onOutput 시그니처 문서화

---

## 테스트 시나리오

1. **일반 manifest만 있는 경우**: 기존 동작과 동일
2. **sideEffect manifest만 있는 경우**: LBDATA 비어있음, 본문만 수정
3. **혼합된 경우**: 일반 → LBDATA, sideEffect → 본문 순서대로 처리
4. **sideEffect reroll**: 태그 제거 후 재생성, onOutput으로 본문 수정
5. **sideEffect interaction**: 동일 플로우
6. **sideEffect 오류 시**: 해당 manifest만 실패, 나머지 계속 진행
