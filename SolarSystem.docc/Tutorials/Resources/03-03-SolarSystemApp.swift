import RealityKit
import SwiftUI

@main
struct SolarSystemApp: App {

    @State private var model = AppModel()
    @State private var solarImmersionStyle: ImmersionStyle = .full

    init() {
        // 직접 만든 시스템은 앱이 시작할 때 한 번 등록해야 합니다.
        // 등록하지 않으면 RotationComponent를 붙여도 아무 일도 일어나지 않습니다.
        RotationSystem.registerSystem()
    }

    var body: some SwiftUI.Scene {
        WindowGroup {
            ContentView()
                .environment(model)
        }
        .windowStyle(.plain)

        ImmersiveSpace(id: model.immersiveSpaceID) {
            SolarSystem()
                .environment(model)
        }
        .immersionStyle(selection: $solarImmersionStyle, in: .full)
    }
}
