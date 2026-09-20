import SwiftUI
import RealityKit

struct SolarSystem: View {
    @Environment(AppModel.self) private var model

    /// `FocusStage`가 만들어 준 자리를 받아, 모든 행성에게 나눠 줍니다.
    @State private var focusStage: Entity?

    var body: some View {
        ZStack {
            Starfield()

            Sun(
                scale: model.solarSunScale,
                position: model.solarSunPosition
            )

            FocusStage(stageEntity: $focusStage)

            ForEach(model.solarPlanets, id: \.id) { configuration in
                Planet(configuration: configuration, focusStage: focusStage)
            }
        }
        .onAppear {
            model.immersiveSpaceState = .open
        }
        .onDisappear {
            model.immersiveSpaceState = .closed
        }
    }
}
