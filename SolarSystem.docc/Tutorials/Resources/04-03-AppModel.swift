import RealityKit
import SwiftUI

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
    let solarSystemTilt: simd_quatf = .init(angle: Float(Angle.degrees(28).radians), axis: [1, 0, 0])

    // MARK: - 행성

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

    // MARK: - 포커스

    /// 지금 확대해서 보고 있는 행성입니다. 아무것도 고르지 않았으면 `nil`입니다.
    var focusedPlanetID: PlanetID? = nil

    /// 바깥쪽 행성으로 넘어갑니다. 해왕성 다음은 다시 수성입니다.
    func focusNext() {
        guard let current = focusedPlanetID else { return }
        let next = (current.rawValue + 1) % PlanetID.allCases.count
        focusedPlanetID = PlanetID(rawValue: next)
    }

    /// 안쪽 행성으로 넘어갑니다. 수성 이전은 해왕성입니다.
    func focusPrevious() {
        guard let current = focusedPlanetID else { return }
        let count = PlanetID.allCases.count
        let previous = (current.rawValue - 1 + count) % count
        focusedPlanetID = PlanetID(rawValue: previous)
    }

    /// 확대를 끝내고 원래 궤도로 돌려보냅니다.
    func closeFocus() {
        focusedPlanetID = nil
    }
}
