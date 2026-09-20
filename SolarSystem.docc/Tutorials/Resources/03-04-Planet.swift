//
//  Planet.swift
//  SolarSystem
//
//  Created by Saerom on 8/13/26.
//

import SwiftUI
import RealityKit

/// The RealityView for a single planet.
///
/// Builds and updates a `PlanetEntity`, wires up the pinch-to-focus gesture
/// on its selection ring, and places its info panel beside the planet once
/// it's focused.
struct Planet: View {
    @Environment(AppModel.self) private var model

    var configuration: PlanetEntity.Configuration
    private var isFocused: Bool {
        model.focusedPlanetID == configuration.id
    }

    var body: some View {
        RealityView { content, _ in
            let planetEntity = await PlanetEntity(configuration: configuration)
            content.add(planetEntity)
            self.planetEntity = planetEntity

        } update: { _, _ in
            guard let planetEntity else { return }
            planetEntity.update(configuration: configuration, animateUpdates: true)
        }
    }
}
