import SwiftUI

/// Configuration information for a generic planet placed around the Sun.
struct PlanetConfiguration {
    /// Must match the entity name in WorldAssets.rkassets (e.g. "Mercury").
    var name: String
    var order: Int
    var radiusKm: Double
    var orbitAngle: Angle
    var baseAssetRadius: Float = 0.1
}
