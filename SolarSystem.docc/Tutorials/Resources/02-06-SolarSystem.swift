import SwiftUI
import RealityKit

/// The model content for the solar system module.
struct SolarSystem: View {
    @Environment(AppModel.self) private var model

    var body: some View {
        ZStack {
            Sun(
                scale: model.solarSunScale,
                position: model.solarSunPosition
            )

            // 1. Place each planet as a RealityView attachment.
            // 2. Position it using the same meter-based RealityKit
            //    coordinates as PlanetConfiguration.position.
            RealityView { content, attachments in
                for planet in model.solarPlanets {
                    guard let attachmentEntity = attachments.entity(for: planet.name) else { continue }
                    attachmentEntity.position = planet.position(
                        around: model.solarSunPosition,
                        spacingPerOrder: model.spacingPerOrder)
                    content.add(attachmentEntity)
                }
            } attachments: {
                ForEach(model.solarPlanets, id: \.name) { planet in
                    Attachment(id: planet.name) {
                        Text(planet.name)
                    }
                }
            }

            Starfield()
        }
    }
}
