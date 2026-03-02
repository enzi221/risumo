# sideEffect 구조 통일

## 현재 구조

### 퓨어 모듈

- **메인/리롤/인터랙션** 모두 init.lua에서 `pipeline.runPipelineAsync` 호출 → 결과를 직접 삽입

### 사이드이펙트 모듈

- **메인**: `sideeffect.runSideEffects` (순회 + pipeline + onOutput + 쓰기 올인원)
- **리롤/인터랙션**: init.lua에서 pipeline 호출 → `sideeffect.handleSideEffectResult` (onOutput + 쓰기)

## 문제

- 메인만 `runSideEffects`라는 별도 함수를 사용
- 리롤/인터랙션은 퓨어와 동일하게 init.lua에서 pipeline 호출 후 `handleSideEffectResult`로 후처리
- 같은 사이드이펙트인데 메인과 리롤/인터랙션의 진입점이 다름

## 개선안: runSideEffects 제거, main에서 직접 순회

`runSideEffects`가 하는 일 = 순회 + pipeline + onOutput + 쓰기
이 중 "순회 + pipeline"은 퓨어에서 main이 이미 하고 있는 것
"onOutput + 쓰기"만 sideeffect.lua 고유 책임

```
-- init.lua main() 에서
for _, man in ipairs(sideEffectManifests) do
  local ok, result = pcall(pipeline call)
  -- 에러 처리 (퓨어와 동일: 빈 lb-lazy + alert)
  sideeffect.handleSideEffectResult(triggerId, { result = result, ... })
end
```

- `runSideEffects` 삭제
- 3종(메인/리롤/인터랙션) 모두 `handleSideEffectResult` 하나로 통일
- 퓨어/사이드이펙트 구조 대칭

### 주의사항

- `runSideEffects`는 결과를 모아서 한번에 `setChat`하는 배치 쓰기를 함 (lazyPlaceholders + lbdataContents)
- `handleSideEffectResult`는 건별 `setChat`
- 메인에서 사이드이펙트가 여러 개일 때 배치 쓰기 로직을 유지할지 결정 필요
