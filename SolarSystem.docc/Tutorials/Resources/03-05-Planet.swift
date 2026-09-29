import SwiftUI
import RealityKit

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
        .gesture(
            SpatialTapGesture()
                .targetedToAnyEntity()
                .onEnded { value in
                    guard value.entity.components[PlanetSelectionComponent.self] != nil else { return }
                    model.focusedPlanetID = configuration.id
                }
        )
    }
}
