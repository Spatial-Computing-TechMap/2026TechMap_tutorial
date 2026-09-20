태양·지구·달·인공위성과 여덟 행성 모델을 포함한 WorldAssets 로컬 Swift 패키지입니다.

- WorldAssets: 태양·지구·달·망원경·수성·금성·화성·목성·토성·천왕성·해왕성 모델과 연결 텍스처
- Resources/Sunlight.skybox: 지구의 낮/밤 셰이딩에 쓰는 이미지 기반 조명
- Images: 앱의 Assets에 추가하는 Starfield(별 배경), SolarSystem, SolarBackground
- README.txt: Xcode에서 Add Local로 연결하는 방법

Xcode 26 이상과 visionOS 26 이상을 사용합니다. WorldAssets 폴더 전체를 프로젝트의
Packages 폴더로 복사한 후 앱 타깃에 연결하세요.

이전 assets-v1의 SolarSystemAssets 패키지를 대체합니다. 공개 API가
solarSystemAssetsBundle에서 worldAssetsBundle / WorldAssets.entity(named:)로
바뀌었고, 달·인공위성 모델과 조명 이미지가 추가되었습니다.
