import Foundation

/// 여덟 개의 행성입니다. 태양에서 가까운 순서로 적습니다.
enum PlanetID: Int, CaseIterable, Identifiable, Hashable {
    case mercury, venus, earth, mars, jupiter, saturn, uranus, neptune

    var id: Int { rawValue }

    /// 화면에 보여 줄 이름입니다.
    var displayName: String {
        switch self {
        case .mercury: String(localized: "수성")
        case .venus: String(localized: "금성")
        case .earth: String(localized: "지구")
        case .mars: String(localized: "화성")
        case .jupiter: String(localized: "목성")
        case .saturn: String(localized: "토성")
        case .uranus: String(localized: "천왕성")
        case .neptune: String(localized: "해왕성")
        }
    }

    /// SolarSystemAssets 패키지에서 찾을 모델 이름입니다.
    /// 앞의 `Planets/`는 폴더 이름, 뒤는 확장자를 뺀 파일 이름입니다.
    var assetName: String {
        switch self {
        case .mercury: "Planets/Mercury"
        case .venus: "Planets/Venus"
        case .earth: "Earth"
        case .mars: "Planets/Mars"
        case .jupiter: "Planets/Jupiter"
        case .saturn: "Planets/Saturn"
        case .uranus: "Planets/Uranus"
        case .neptune: "Planets/Neptune"
        }
    }

    /// 설명 패널에 보여 줄 한 줄 정보입니다.
    var fact: String {
        switch self {
        case .mercury: String(localized: "태양에 가장 가깝고 가장 작은 행성으로, 자전축이 거의 기울어 있지 않습니다.")
        case .venus: String(localized: "다른 행성과 반대 방향으로 돌고, 표면이 태양계에서 가장 뜨겁습니다.")
        case .earth: String(localized: "우리가 사는 행성입니다. 23.5도 기울어진 자전축이 계절을 만듭니다.")
        case .mars: String(localized: "붉은 행성입니다. 하루의 길이가 지구와 거의 같습니다.")
        case .jupiter: String(localized: "가장 큰 행성입니다. 매우 빠르게 돌아 하루가 열 시간도 되지 않습니다.")
        case .saturn: String(localized: "고리로 유명합니다. 태양계에서 밀도가 가장 낮은 행성입니다.")
        case .uranus: String(localized: "자전축이 약 98도 기울어 거의 누운 채로 돕니다.")
        case .neptune: String(localized: "가장 바깥의 행성으로, 태양계에서 바람이 가장 빠릅니다.")
        }
    }
}
