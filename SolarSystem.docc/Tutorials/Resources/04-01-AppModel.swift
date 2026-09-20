import RealityKit
import SwiftUI

/// 창과 몰입 공간이 함께 보는 앱 전역 상태입니다.
@MainActor
@Observable
class AppModel {

    /// `ImmersiveSpace`를 열고 닫을 때 쓰는 이름입니다. `@main`에서
    /// 선언하는 `ImmersiveSpace(id:)`와 반드시 같아야 합니다.
    let immersiveSpaceID = "SolarSystem"

    /// 몰입 공간을 여닫는 일은 `await`라서 시간이 걸립니다. 그 사이에
    /// 버튼이 또 눌리는 것을 막으려고 "전환 중"이라는 중간 상태를 둡니다.
    enum ImmersiveSpaceState {
        case closed
        case inTransition
        case open
    }
    var immersiveSpaceState = ImmersiveSpaceState.closed
    /// 몰입 공간이 실제로 화면에 올라와 있는지입니다.
    var isShowingSolar: Bool = false

    /// 지금 확대해서 보고 있는 행성입니다. `nil`이면 아무것도 선택되지
    /// 않은, 태양계 전체를 보는 상태입니다.
    var focusedPlanetID: PlanetID? = nil

    /// 지구만 달과 인공위성을 함께 거느리므로 설정을 따로 들고 있습니다.
    /// 나머지 일곱 행성은 `PlanetEntity.Configuration`에 미리 정의되어 있습니다.
    var solarEarth: EarthEntity.Configuration = .solarEarthDefault
    var solarSatellite: SatelliteEntity.Configuration = .solarTelescopeDefault
    var solarMoon: SatelliteEntity.Configuration = .solarMoonDefault

    /// 태양에서 가까운 순서대로 늘어놓은 여덟 행성입니다.
    var solarPlanets: [PlanetEntity.Configuration] {
        let planets: [PlanetEntity.Configuration] = [
            .mercury,
            .venus,
            // 지구만 팩토리 이름이 다릅니다. 달과 위성 설정을 함께 받습니다.
            .makeEarth(configuration: solarEarth, satellites: [solarSatellite], moon: solarMoon),
            .mars,
            .jupiter,
            .saturn,
            .uranus,
            .neptune
        ]
        return planets.map {
            var configuration = $0
            configuration.sceneCenter = solarSunPosition
            configuration.presentationTilt = solarSystemTilt
            // 한 행성이 선택되면 나머지는 전부 숨깁니다. 선택된 행성은
            // 이미 포커스 무대로 옮겨져 있어서 이 설정에 영향받지 않습니다.
            configuration.isHidden = focusedPlanetID != nil
            return configuration
        }
    }

    func focusNext() { focusedPlanetID = (focusedPlanetID ?? .neptune).next }
    func focusPrevious() { focusedPlanetID = (focusedPlanetID ?? .mercury).previous }
    func closeFocus() { focusedPlanetID = nil }

    // 태양이 놓이는 자리이자, 모든 행성 궤도의 중심입니다.
    let solarSunPosition: SIMD3<Float> = [0, 1.0, -9]
    let solarSunScale: Float = 2.0

    // 궤도면 전체를 기울여, 태양계를 위에서 비스듬히 내려다보게 만듭니다.
    let solarSystemTilt: simd_quatf = .init(
        angle: Float(Angle.degrees(28).radians), axis: [1, 0, 0])
}
