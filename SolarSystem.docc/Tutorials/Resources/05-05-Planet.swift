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
                .opacity(isFocused ? 1 : 0)
                .allowsHitTesting(isFocused)
            }
        }
        .gesture(
            SpatialTapGesture()
                .targetedToAnyEntity()
                .onEnded { value in
                    guard value.entity.components[PlanetSelectionComponent.self] != nil else { return }

                    // 확대가 처음 열릴 때만 자리를 옮깁니다.
                    // 이전/다음으로 넘길 때는 같은 자리를 그대로 씁니다.
                    // 옮기는 일을 먼저 해야 행성이 곧장 그 자리로 날아옵니다.
                    if model.focusedPlanetID == nil, let focusStage {
                        model.placeFocusStageInFrontOfViewer(focusStage)
                    }
                    model.focusedPlanetID = configuration.id
                }
        )
    }
}
