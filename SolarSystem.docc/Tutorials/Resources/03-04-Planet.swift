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
    }
}
