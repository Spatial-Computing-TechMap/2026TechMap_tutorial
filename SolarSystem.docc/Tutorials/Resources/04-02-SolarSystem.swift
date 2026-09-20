import SwiftUI
import RealityKit

/// 몰입 공간에 들어갈 내용을 한자리에 쌓는 뷰입니다.
struct SolarSystem: View {
    @Environment(AppModel.self) private var model

    /// `FocusStage`가 만들어 모든 `Planet`에게 나눠 주는 공용 무대입니다.
    @State private var focusStage: Entity?

    var body: some View {
        ZStack {
            Starfield()

            Sun(scale: model.solarSunScale,
                position: model.solarSunPosition,
                isHidden: model.focusedPlanetID != nil)

            FocusStage(stageEntity: $focusStage, isActive: model.focusedPlanetID != nil)

            ForEach(model.solarPlanets, id: \.id) { configuration in
                Planet(configuration: configuration, focusStage: focusStage)
            }
        }
        .onAppear {
            model.immersiveSpaceState = .open
            model.isShowingSolar = true
        }
        .onDisappear {
            model.immersiveSpaceState = .closed
            model.isShowingSolar = false
        }
    }
}
