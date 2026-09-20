import SwiftUI
import RealityKit

struct SolarSystem: View {
    @Environment(AppModel.self) private var model

    @State private var focusStage: Entity?

    var body: some View {
        ZStack {
            Starfield()

            Sun(
                scale: model.solarSunScale,
                position: model.solarSunPosition
            )

            FocusStage(
                stageEntity: $focusStage,
                isActive: model.focusedPlanetID != nil
            )

            ForEach(model.solarPlanets, id: \.id) { configuration in
                Planet(configuration: configuration, focusStage: focusStage)
            }
        }
        .task {
            // 머리 추적은 몰입 공간이 열려 있는 동안에만 동작합니다.
            await model.headTracker.start()
        }
        .onAppear {
            model.immersiveSpaceState = .open
        }
        .onDisappear {
            model.headTracker.stop()
            model.immersiveSpaceState = .closed
        }
    }
}
