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
            // 2. Position is the same meter-based RealityKit coordinates
            //    (PlanetConfiguration.position). The attachment's SwiftUI
            //    content (PlanetCardContent) handles the Model3D + card.
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
                        PlanetCardContent(
                            name: planet.name,
                            scale: planet.scale(
                                worldRadiusPerKm: model.worldRadiusPerKm,
                                minWorldRadius: model.minPlanetScale,
                                maxWorldRadius: model.maxPlanetScale
                            )
                        )
                    }
                }
            }
            Starfield()
        }
        .onAppear {
            model.immersiveSpaceState = .open
            model.isShowingSolar = true
            var announcement = AttributedString(localized: "Entered the immersive star filled solar system!",
                                                comment: "Accessibility message describing the model shown.")
            announcement.accessibilitySpeechAnnouncementPriority = .high
            AccessibilityNotification.Announcement(announcement).post()
        }
        .onDisappear {
            model.immersiveSpaceState = .closed
            model.isShowingSolar = false
        }
    }
}
