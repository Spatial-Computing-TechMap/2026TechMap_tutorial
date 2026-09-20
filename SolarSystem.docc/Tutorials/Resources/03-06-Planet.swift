import SwiftUI
import RealityKit

/// 행성 하나를 보여 주는 RealityView입니다.
struct Planet: View {
    var configuration: PlanetEntity.Configuration

    @State private var planetEntity: PlanetEntity?

    var body: some View {
        RealityView { content in
            let planetEntity = await PlanetEntity(configuration: configuration)
            content.add(planetEntity)
            self.planetEntity = planetEntity

        } update: { content in
            planetEntity?.update(configuration: configuration)
        }
    }
}
