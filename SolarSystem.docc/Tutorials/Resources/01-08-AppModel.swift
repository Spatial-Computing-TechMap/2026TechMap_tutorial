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
}
