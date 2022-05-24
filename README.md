# 전환 계획

1. Developers 문서 jekyll standalone으로 변경
   1. gitbook 컴포넌트 -> liquid custom tag 전환
      1. hint
      2. embed
         1. youtube (jekyll-spaceship)
         2. 일반 링크
      3. file
      4. api
      5. tab
      6. details
      7. content-ref
      8. 수식 (jekyll-spaceship)
      9. table (jekyll-spaceship)
   2. gitbook 지원요소 -> standalone으로 사용할 수 있도록 전환
      1. 메뉴트리
      2. 빈 페이지
      3. pagination
      4. 검색
      5. google analytics
   3. content 수정
2. 가이드 공유
   > 초기 디자인, 마크업 작업을 어떻게 해야 하는지에 대한 가이드
3. initial-document 생성
   > 1번중 문서부분 제거
   > liquid custom tag 사용법 및 jekyll-spaceship 사용 가이드 추가
   > 2번 문서를 정리하여 theme 생성 가이드 추가
4. 디자인, 마크업 적용
5. 검증
6. 상용 배포