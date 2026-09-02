import SwiftUI

/// Configuration information for a generic planet placed around the Sun.
struct PlanetConfiguration {
    /// Must match the entity name in WorldAssets.rkassets (e.g. "Mercury").
    var name: String
    var order: Int
    var radiusKm: Double
    var orbitAngle: Angle
    var baseAssetRadius: Float = 0.1

    /// Places the planet on the sun-centered xz plane, `order` orbit-widths
    /// away from the Sun, at `orbitAngle` around it.
    func position(around sunPosition: SIMD3<Float>, spacingPerOrder: Double) -> SIMD3<Float> {
        let distance = Double(order) * spacingPerOrder
        return sunPosition + [
            Float(distance * sin(orbitAngle.radians)),
            0,
            Float(distance * cos(orbitAngle.radians))
        ]
    }
}
