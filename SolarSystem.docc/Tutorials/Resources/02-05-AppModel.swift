import SwiftUI

/// Maintains app-wide state
@MainActor
@Observable
class AppModel {
    let immersiveSpaceID = "SolarSystem"

    /// Prevents a second tap from racing a transition that's already in flight.
    enum ImmersiveSpaceState {
        case closed
        case inTransition
        case open
    }
    var immersiveSpaceState = ImmersiveSpaceState.closed

    /// Whether the solar system module is currently visible.
    var isShowingSolar = false

    /// The scale applied to the Sun entity in SolarSystem.swift.
    var solarSunScale: Float = 50

    // MARK: - Sun
    var solarSunPosition: SIMD3<Float> = [-2, 0.4, -5]

    // MARK: - Planets
    var spacingPerOrder: Double = 2.3
    var worldRadiusPerKm: Float = 0.28 / 6371

    var minPlanetScale: Float = 0.08
    var maxPlanetScale: Float = 1.2

    var solarPlanets: [PlanetConfiguration] = [
        .init(name: "Mercury", order: 1, radiusKm: 2439.7, orbitAngle: .degrees(45)),
        .init(name: "Venus",   order: 2, radiusKm: 6051.8, orbitAngle: .degrees(90)),
        .init(name: "Earth",   order: 3, radiusKm: 6371,   orbitAngle: .degrees(135), baseAssetRadius: 0.5025),
        .init(name: "Mars",    order: 4, radiusKm: 3389.5, orbitAngle: .degrees(180)),
        .init(name: "Jupiter", order: 5, radiusKm: 69911,  orbitAngle: .degrees(225)),
        .init(name: "Saturn",  order: 6, radiusKm: 58232,  orbitAngle: .degrees(270)),
        .init(name: "Uranus",  order: 7, radiusKm: 25362,  orbitAngle: .degrees(315)),
        .init(name: "Neptune", order: 8, radiusKm: 24622,  orbitAngle: .degrees(360)),
    ]
}
