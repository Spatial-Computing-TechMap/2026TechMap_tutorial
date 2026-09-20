import SwiftUI

@main
struct SolarSystemApp: App {

    /// 창과 몰입 공간이 함께 보는 상태입니다. 여기서 딱 한 번 만듭니다.
    @State private var model = AppModel()

    var body: some SwiftUI.Scene {
        WindowGroup {
            SwitchWindows()
                .environment(model)
        }
        .windowStyle(.plain)
    }
}
