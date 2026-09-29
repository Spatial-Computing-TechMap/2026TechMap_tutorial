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
    var isShowingSolar: Bool = false

    var solarEarth: EarthEntity.Configuration = .solarEarthDefault
    var solarSatellite: SatelliteEntity.Configuration = .solarTelescopeDefault
    var solarMoon: SatelliteEntity.Configuration = .solarMoonDefault

    var solarPlanets: [PlanetEntity.Configuration] {
        let planets: [PlanetEntity.Configuration] = [
            .mercury,
            .venus,
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
            configuration.isHidden = focusedPlanetID != nil
            return configuration
        }
    }

    var focusedPlanetID: PlanetID? = nil

    @ObservationIgnored let headTracker = HeadTracker()

    let focusDistance: Float = 1.3

    func placeFocusStageInFrontOfViewer(_ stage: Entity) {
        guard let head = headTracker.headTransform() else { return }

        let headPosition = SIMD3<Float>(head.columns.3.x, head.columns.3.y, head.columns.3.z)
        var forward = -SIMD3<Float>(head.columns.2.x, 0, head.columns.2.z)
        guard length(forward) > 0.001 else { return }
        forward = normalize(forward)

        let yaw = atan2(-forward.x, -forward.z)
        let orientation = simd_quatf(angle: yaw, axis: [0, 1, 0])
        let right = orientation.act([1, 0, 0])

        let groupLeft = -PlanetEntity.focusDisplayRadius
        let groupRight = PlanetEntity.focusPanelOffset + PlanetEntity.focusPanelHalfWidth
        let groupCenter = (groupLeft + groupRight) / 2

        stage.orientation = orientation
        stage.position = headPosition + forward * focusDistance - right * groupCenter
    }

    func focusNext() {
        focusedPlanetID = (focusedPlanetID ?? .neptune).next
    }

    func focusPrevious() {
        focusedPlanetID = (focusedPlanetID ?? .mercury).previous
    }

    func closeFocus() {
        focusedPlanetID = nil
    }

    let solarSunPosition: SIMD3<Float> = [0, 1.0, -9]
    let solarSunScale: Float = 2.0

    let solarSystemTilt: simd_quatf = .init(angle: Float(Angle.degrees(28).radians), axis: [1, 0, 0])
}
