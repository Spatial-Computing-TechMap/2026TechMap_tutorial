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

    // MARK: - 태양과 행성

    let solarSunPosition: SIMD3<Float> = [0, 1.0, -9]
    let solarSunScale: Float = 2.0
    let solarSystemTilt: simd_quatf = .init(angle: Float(Angle.degrees(28).radians), axis: [1, 0, 0])

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

    var focusedPlanetID: PlanetID? = nil

    func focusNext() {
        guard let current = focusedPlanetID else { return }
        let next = (current.rawValue + 1) % PlanetID.allCases.count
        focusedPlanetID = PlanetID(rawValue: next)
    }

    func focusPrevious() {
        guard let current = focusedPlanetID else { return }
        let count = PlanetID.allCases.count
        let previous = (current.rawValue - 1 + count) % count
        focusedPlanetID = PlanetID(rawValue: previous)
    }

    func closeFocus() {
        focusedPlanetID = nil
    }

    // MARK: - 시선 앞 배치

    @ObservationIgnored let headTracker = HeadTracker()

    /// 확대한 행성이 사람에게서 얼마나 떨어져 나타날지 정합니다.
    let focusDistance: Float = 1.3

    /// 확대 자리를 지금 바라보는 방향 정면으로 옮깁니다.
    func placeFocusStageInFrontOfViewer(_ stage: Entity) {
        guard let head = headTracker.headTransform() else { return }

        // 4x4 행렬의 네 번째 열이 위치입니다.
        let headPosition = SIMD3<Float>(head.columns.3.x, head.columns.3.y, head.columns.3.z)

        // 세 번째 열이 뒤쪽 방향이라, 부호를 뒤집으면 앞쪽이 됩니다.
        // y를 0으로 만들어 수평 방향만 남깁니다. 위를 올려다보고 있어도
        // 행성이 기울어진 자리에 놓이지 않게 하기 위해서입니다.
        var forward = -SIMD3<Float>(head.columns.2.x, 0, head.columns.2.z)
        guard length(forward) > 0.001 else { return }
        forward = normalize(forward)

        // 자리의 앞면(+Z)이 사람을 향하도록 돌립니다.
        let yaw = atan2(-forward.x, -forward.z)
        let orientation = simd_quatf(angle: yaw, axis: [0, 1, 0])
        let right = orientation.act([1, 0, 0])

        // 행성은 자리의 원점에, 패널은 그 오른쪽에 놓입니다.
        // 둘을 합친 묶음이 시야 한가운데 오도록 자리를 왼쪽으로 밀어 줍니다.
        let groupLeft = -PlanetEntity.focusDisplayRadius
        let groupRight = PlanetInfoPanel.offset + PlanetInfoPanel.halfWidth
        let groupCenter = (groupLeft + groupRight) / 2

        stage.orientation = orientation
        stage.position = headPosition + forward * focusDistance - right * groupCenter
    }
}
