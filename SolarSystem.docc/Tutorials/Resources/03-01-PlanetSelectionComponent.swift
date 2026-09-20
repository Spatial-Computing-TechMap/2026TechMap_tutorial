//
//  PlanetSelectionComponent.swift
//  SolarSystem
//
//  Created by Saerom on 8/13/26.
//

import RealityKit

/// Marks a planet's model as a hover/pinch target for focusing that planet.
/// Combine with `InputTargetComponent`, `CollisionComponent`, and
/// `HoverEffectComponent` for the gaze highlight and pinch-to-select
/// behavior that visionOS provides automatically.
struct PlanetSelectionComponent: Component {
    let planetID: PlanetID
}
