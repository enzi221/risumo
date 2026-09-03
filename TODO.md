# TODO

- [ ] 삽화 완료음이 과거 채팅의 재렌더링으로 다시 재생되지 않게 한다
  - 대상: `temp/삽화 3.4.1 v26 (작노포함).module`
  - 원인: 원본 채팅에 `<lb-xnai completion-sound />`가 계속 남아 있어, 해당 채팅이 다시 마지막 채팅이 되면 `editdisplay`가 `<audio autoplay>`를 다시 출력한다
  - 방향: 다음 사용자 입력 후 실행되는 `onStart`에서 `getChat(triggerId, -2)`로 직전 캐릭터 채팅만 읽고 완료음 태그를 제거한다. 전체 채팅을 읽거나 다시 쓰지 않는다
  - 주의: 기존 `onStart`가 생기면 덮어쓰지 말고 정리 호출을 병합한다
