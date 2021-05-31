# MedInfo

한성대학교 iOS프로그래밍 수업 - 기말(개인프로젝트)

UITabBarController, UINavigationController, UIViewController를 이용
AutoLayout을 이용해 다양한 기종에서 사용할 수 있게 구현

의약품 검색 탭
- 의약품 검색(예: 타이레놀)
- 결과선택시 자세한 정보 확인

- 공공데이터 포털 (e약은요) API 활용

- UISearchBar, UITableView
- json파싱을 통해 정보 출력, prepare함수를 통해 자세한 정보 출력을 위한 뷰 컨트롤러에 데이터 전달

복용 기록 탭
- 처음 접근 시도에는 휴대폰 비밀번호가 있을 경우 비밀번호 해제시 접근 가능(Face ID, Touch ID, Password), 비밀번호 입력 취소 또는 실패시 의약품 검색 탭으로 이동시켜 접근 차단
- 복용기록 선택시 자세한 내용 확인
- 길게 눌러 목록의 위치 수정
- 오른쪽에서 왼쪽으로 드래그해서 삭제

- Local Authentication 사용 (비밀번호)
- Userdefaults를 활용해 데이터 저장, 로딩
