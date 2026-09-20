import SwiftUI

@main
struct SolarSystemApp: App {

    /// 창과 몰입 공간이 함께 보는 상태입니다.
    @State private var model = AppModel()

    /// 몰입의 정도입니다. `.full`은 주변 현실을 완전히 가립니다.
    @State private var solarImmersionStyle: ImmersionStyle = .full

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
