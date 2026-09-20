SolarSystem 튜토리얼 · 에셋
===========================

1챕터 "프로젝트와 에셋 준비하기"에서 쓰는 파일입니다.

  WorldAssets/          Xcode에 로컬 패키지로 추가하세요.
                        프로젝트 폴더/Packages/WorldAssets/ 에 두고
                        File > Add Package Dependencies > Add Local.
                        태양, 지구, 달, 인공위성, 나머지 일곱 행성 모델이
                        들어 있습니다. 코드에서 `import WorldAssets`와
                        `worldAssetsBundle`로 씁니다.

  Resources/Sunlight.skybox
                        앱의 Resources 폴더로 옮기고 앱 타깃에 추가하세요.
                        지구의 낮/밤 셰이딩에 쓰는 조명 이미지입니다.

  Images/               세 개의 이미지 세트를 앱의 Assets.xcassets로
                        드래그하세요. 이름을 바꾸면 안 됩니다.
                          Starfield       별 배경
                          SolarSystem     창 카드의 미리보기
                          SolarBackground 창 카드의 배경

최소 배포 대상은 visionOS 26.0입니다.
