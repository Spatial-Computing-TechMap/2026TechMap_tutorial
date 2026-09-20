import SwiftUI
import RealityKit

struct Planet: View {
    @Environment(AppModel.self) private var model

    var configuration: PlanetEntity.Configuration
    var focusStage: Entity?

    @State private var planetEntity: PlanetEntity?

    private var isFocused: Bool {
        model.focusedPlanetID == configuration.id
    }

    var body: some View {
        // attachments를 쓰면 RealityView의 두 블록이 인자를 하나씩 더 받습니다.
        RealityView { content, attachments in
            let planetEntity = await PlanetEntity(configuration: configuration)
            content.add(planetEntity)
            self.planetEntity = planetEntity

        } update: { content, attachments in
            guard let planetEntity else { return }
            planetEntity.update(configuration: configuration)
            planetEntity.isEnabled = model.focusedPlanetID == nil || isFocused

            guard let focusStage,
                  let panel = attachments.entity(for: PlanetInfoPanel.attachmentID)
            else { return }

            planetEntity.setFocused(isFocused, stage: focusStage)

            if isFocused {
                // 패널도 확대 자리의 자식으로 옮겨, 행성과 늘 함께 움직이게 합니다.
                if panel.parent !== focusStage {
                    focusStage.addChild(panel)
                }
                panel.position = [PlanetInfoPanel.offset, 0, 0]
                panel.scale = SIMD3(repeating: PlanetInfoPanel.focusScale)
            }

        } attachments: {
            Attachment(id: PlanetInfoPanel.attachmentID) {
                PlanetInfoPanel(
                    planetID: configuration.id,
                    onPrevious: { model.focusPrevious() },
                    onNext: { model.focusNext() },
                    onClose: { model.closeFocus() })
                // 확대하지 않은 동안에는 보이지 않게 하고, 입력도 받지 않게 합니다.
                .opacity(isFocused ? 1 : 0)
                .allowsHitTesting(isFocused)
            }
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
