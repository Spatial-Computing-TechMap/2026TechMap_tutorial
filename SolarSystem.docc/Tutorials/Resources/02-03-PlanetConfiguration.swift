import SwiftUI

/// Configuration information for a generic planet placed around the Sun.
struct PlanetConfiguration {
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

    /// Converts `radiusKm` to a world-space scale factor, clamped so tiny
    /// planets stay visible and huge ones stay in frame, then normalized
    /// against the planet's own base asset radius.
    func scale(worldRadiusPerKm: Float, minWorldRadius: Float, maxWorldRadius: Float) -> Float {
        let worldRadius = Float(radiusKm) * worldRadiusPerKm
        let clampedWorldRadius = min(max(worldRadius, minWorldRadius), maxWorldRadius)
        return clampedWorldRadius / baseAssetRadius
    }
}
