import SwiftUI
import RealityKit

/// 행성 하나를 그리는 뷰입니다.
struct Planet: View {
    @Environment(AppModel.self) private var model

    var configuration: PlanetEntity.Configuration

    @State private var planetEntity: PlanetEntity?

    var body: some View {
        RealityView { content, _ in
            let planetEntity = await PlanetEntity(configuration: configuration)
            content.add(planetEntity)
            self.planetEntity = planetEntity

        } update: { _, attachments in
            guard let planetEntity else { return }
            planetEntity.update(configuration: configuration, animateUpdates: true)
        }
        .gesture(
            // 어떤 엔티티든 받아 놓고, 우리가 붙인 꼬리표가 있는지로
            // 걸러냅니다. 이래야 궤도선이나 배경을 집었을 때 반응하지
            // 않습니다.
            SpatialTapGesture()
                .targetedToAnyEntity()
                .onEnded { value in
                    guard value.entity.components[PlanetSelectionComponent.self] != nil else { return }
                    model.focusedPlanetID = configuration.id
                }
        )
    }
}
