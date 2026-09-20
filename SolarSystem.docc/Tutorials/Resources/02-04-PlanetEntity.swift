//
//  PlanetEntity.swift
//  SolarSystem
//
//  Created by Saerom on 8/13/26.
//

import RealityKit
import SwiftUI
import UIKit
import WorldAssets

/// An entity that represents one planet: it orbits the Sun on a visible
/// path, spins on a tilted axis, and can itself be looked at and pinched to
/// focus on it.
///
/// Earth is special-cased to wrap the existing `EarthEntity` (which already
/// manages its own tilt, spin, Moon, and satellites), while every other
/// planet uses a procedurally generated placeholder sphere until a real
/// textured asset is added to `WorldAssets`.
class PlanetEntity: Entity {

    // MARK: - Sub-entities

    /// Rotates around the Sun to create the planet's revolution.
    private let orbitPivot = Entity()
    /// Positions the planet at its distance from the Sun.
    private let radiusOffset = Entity()
    /// Holds the planet's axial tilt. This is the entity that gets
    /// reparented into the focus stage when someone selects this planet.
    private let equatorialPlane = Entity()
    /// Spins around the tilted axis to create the planet's rotation.
    private let rotator = Entity()
    /// The visible model. For Earth this is the shared `EarthEntity`; for
    /// every other planet it's a loaded or generated sphere.
    private var model: Entity = Entity()

    /// Set only when this planet wraps an `EarthEntity`, so `update(...)`
    /// can forward Earth-specific configuration to it.
    private var earthEntity: EarthEntity?

    // MARK: - Internal state

    // Named `planetID`, not `id` -- `Entity` already declares a non-open
    // `id: UInt64` that a subclass can't override.
    let planetID: PlanetID
    private var configuration: Configuration
    private var isFocused = false

    // MARK: - Initializers

    @MainActor required init() {
        planetID = .mercury
        configuration = .mercury
        super.init()
    }

}
