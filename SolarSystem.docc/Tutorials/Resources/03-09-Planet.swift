import SwiftUI
import RealityKit

/// 행성 하나를 그리는 뷰입니다.
struct Planet: View {
    @Environment(AppModel.self) private var model

    var configuration: PlanetEntity.Configuration
    var focusStage: Entity?

    @State private var planetEntity: PlanetEntity?

    private var isFocused: Bool {
        model.focusedPlanetID == configuration.id
    }

    var body: some View {
        RealityView { content, _ in
            let planetEntity = await PlanetEntity(configuration: configuration)
            content.add(planetEntity)
            self.planetEntity = planetEntity

        } update: { _, attachments in
            guard let planetEntity else { return }
            planetEntity.update(configuration: configuration, animateUpdates: true)

            guard let focusStage,
                  let panel = attachments.entity(for: PlanetInfoPanel.attachmentID)
            else { return }
            planetEntity.setFocused(isFocused, stage: focusStage)

            if isFocused {
                if panel.parent !== focusStage {
                    focusStage.addChild(panel)
                }
                panel.position = [PlanetEntity.focusPanelOffset, 0, 0]
                panel.scale = SIMD3(repeating: PlanetEntity.focusPanelScale)
            }

        } attachments: {
            // 평범한 SwiftUI 뷰가 여기서 엔티티가 되어 3D 공간에 놓입니다.
            Attachment(id: PlanetInfoPanel.attachmentID) {
                PlanetInfoPanel(
                    planetID: configuration.id,
                    onPrevious: { model.focusPrevious() },
                    onNext: { model.focusNext() },
                    onClose: { model.closeFocus() })
                .opacity(isFocused ? 1 : 0)
                .allowsHitTesting(isFocused)
            }
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
