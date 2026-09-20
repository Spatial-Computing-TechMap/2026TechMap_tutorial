import SwiftUI

@main
struct SolarSystemApp: App {

    /// 창과 몰입 공간이 함께 보는 상태입니다.
    @State private var model = AppModel()

    var body: some SwiftUI.Scene {
        WindowGroup {
            ContentView()
                .environment(model)
        }
        .windowStyle(.plain)
    }
}
