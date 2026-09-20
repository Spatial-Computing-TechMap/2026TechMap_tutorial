import RealityKit
import SwiftUI

/// 앱 전체가 공유하는 상태입니다.
@MainActor
@Observable
class AppModel {
    let immersiveSpaceID = "SolarSystem"

    enum ImmersiveSpaceState {
        case closed
        case inTransition
        case open
    }

    var immersiveSpaceState = ImmersiveSpaceState.closed

    // MARK: - 태양

    let solarSunPosition: SIMD3<Float> = [0, 1.0, -9]
    let solarSunScale: Float = 2.0

    /// 궤도면을 기울여 태양계를 비스듬히 내려다보는 각도로 보여 줍니다.
    let solarSystemTilt: simd_quatf = .init(angle: Float(Angle.degrees(28).radians), axis: [1, 0, 0])

    // MARK: - 행성

    /// 태양에서 가까운 순서대로 나열한 여덟 개의 행성입니다.
    /// 중심과 기울기는 모든 행성이 같은 값을 쓰도록 여기서 한 번에 넣어 줍니다.
    var solarPlanets: [PlanetEntity.Configuration] {
        let planets: [PlanetEntity.Configuration] = [
            .mercury, .venus, .earth, .mars,
            .jupiter, .saturn, .uranus, .neptune
        ]
        return planets.map {
            var configuration = $0
            configuration.sceneCenter = solarSunPosition
            configuration.presentationTilt = solarSystemTilt
            return configuration
        }
    }
}
