//
//  FocusStage.swift
//  SolarSystem
//
//  Created by Saerom on 8/13/26.
//

import SwiftUI
import RealityKit

/// A single, shared anchor entity positioned in front of the viewer.
///
/// Every `Planet` view reparents its planet into this entity while that
/// planet is focused, so a zoomed-in planet and its info panel always
/// appear in the same comfortable spot, regardless of where the planet's
/// orbit happened to put it.
struct FocusStage: View {
    @Binding var stageEntity: Entity?
    /// Whether a planet is currently focused, which turns the key light on.
    var isActive: Bool

    /// Lights the focused planet from the viewer's side. Without it, the
    /// only light is the Sun's, far behind the stage, so the side of the
    /// planet facing the viewer looks dim and muddy.
    @State private var keyLight: Entity?

    var body: some View {
        RealityView { content in
            let stage = Entity()
            stage.name = "FocusStage"
            stage.position = [0, 1.4, -1.6]
            content.add(stage)
            stageEntity = stage

            // A child of the stage, so it follows the stage wherever it's
            // placed in front of the viewer. The stage's +Z faces the
            // viewer, so this shines from their upper left onto the planet.
            let light = Entity()
            light.components.set(DirectionalLightComponent(color: .white, intensity: 2000))
            stage.addChild(light)
            light.look(at: .zero, from: [-0.8, 0.8, 1.5], relativeTo: stage)
            light.isEnabled = isActive
            keyLight = light

        } update: { _ in
            keyLight?.isEnabled = isActive
        }
    }
}
