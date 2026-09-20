//
//  AppModel.swift
//  SolarSystem
//
//  Created by Saerom on 8/12/26.
//

import RealityKit
import SwiftUI

/// Maintains app-wide state
@MainActor
@Observable
class AppModel {
    let immersiveSpaceID = "SolarSystem"

    var solarEarth: EarthEntity.Configuration = .solarEarthDefault
    var solarSatellite: SatelliteEntity.Configuration = .solarTelescopeDefault
    var solarMoon: SatelliteEntity.Configuration = .solarMoonDefault

    /// The eight planets that orbit the Sun in the solar system module,
    /// ordered by distance from the Sun. Earth's entry stays driven by
    /// `solarEarth`/`solarSatellite`/`solarMoon` so existing controls (like
    /// the reduce-motion pause toggle) keep working. Every planet shares
    /// the same `solarSunPosition`/`solarSystemTilt` so they all orbit
    /// exactly where the Sun model is drawn, tilted for a look-down view.
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
            // While a planet is focused, every other planet hides -- the
            // focused one already lives in the shared focus stage, so this
            // only ever hides planets that aren't the focused one.
            configuration.isHidden = focusedPlanetID != nil
            return configuration
        }
    }

    /// The planet currently zoomed in for a side-by-side view with its info
    /// panel, if any.
    var focusedPlanetID: PlanetID? = nil

    func focusNext() {
        focusedPlanetID = (focusedPlanetID ?? .neptune).next
    }

    func focusPrevious() {
        focusedPlanetID = (focusedPlanetID ?? .mercury).previous
    }

    func closeFocus() {
        focusedPlanetID = nil
    }

    // A fixed spot and size for the Sun -- also the point every planet's
    // orbit is centered on (see `solarPlanets` above). Positioned below eye
    // height and in front so the whole system reads as something you
    // look down and out at, not something at eye level. These aren't
    // derived from real units -- nudge them in Xcode if the Sun looks too
    // small/large, or too close/far, next to the planets.
    //
    // The Sun sits farther back than it otherwise would because the orbits
    // are spaced wide enough that planets never overlap (see
    // PlanetEntity+Configuration.swift) -- Neptune orbits 7.8 m out,
    // and this keeps its near edge in front of the viewer.
    let solarSunPosition: SIMD3<Float> = [0, 1.0, -9]
    let solarSunScale: Float = 2.0

    // Tilts every planet's orbital plane so the near edge dips down and the
    // far edge rises, presenting the whole solar system at a raking,
    // look-down angle from the start -- rather than relying on people
    // happening to look downward themselves.
    let solarSystemTilt: simd_quatf = .init(angle: Float(Angle.degrees(28).radians), axis: [1, 0, 0])
}
