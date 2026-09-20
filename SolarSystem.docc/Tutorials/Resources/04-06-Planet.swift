import SwiftUI
import RealityKit

/// 행성 하나를 보여 주고, 핀치하면 확대하는 뷰입니다.
struct Planet: View {
    @Environment(AppModel.self) private var model

    var configuration: PlanetEntity.Configuration
    /// 확대한 행성이 들어갈 공용 자리입니다.
    var focusStage: Entity?

    @State private var planetEntity: PlanetEntity?

    private var isFocused: Bool {
        model.focusedPlanetID == configuration.id
    }

    var body: some View {
        RealityView { content in
            let planetEntity = await PlanetEntity(configuration: configuration)
            content.add(planetEntity)
            self.planetEntity = planetEntity

        } update: { content in
            guard let planetEntity else { return }
            planetEntity.update(configuration: configuration)

            // 다른 행성이 확대된 동안에는 이 행성을 숨깁니다.
            // 확대는 그 행성만 들여다보는 화면이어야 하기 때문입니다.
            planetEntity.isEnabled = model.focusedPlanetID == nil || isFocused

            guard let focusStage else { return }
            planetEntity.setFocused(isFocused, stage: focusStage)
        }
        .gesture(
            SpatialTapGesture()
                .targetedToAnyEntity()
                .onEnded { value in
                    // 집은 것이 행성 선택 대상인지 확인합니다.
                    guard value.entity.components[PlanetSelectionComponent.self] != nil else { return }
                    model.focusedPlanetID = configuration.id
                }
        )
    }
}
