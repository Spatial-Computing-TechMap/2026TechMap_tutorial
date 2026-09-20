import SwiftUI

@main
struct SolarSystemApp: App {

    /// 창과 몰입 공간이 함께 보는 상태입니다. 여기서 딱 한 번 만듭니다.
    @State private var model = AppModel()

    /// 몰입 스타일입니다. `.full`은 주변 현실을 완전히 가립니다.
    @State private var solarImmersionStyle: ImmersionStyle = .full

    var body: some SwiftUI.Scene {
        WindowGroup {
            SwitchWindows()
                .environment(model)
        }
        .windowStyle(.plain)

        // 같은 `model`을 몰입 공간에도 주입합니다. 두 Scene이 서로를
        // 직접 알지 못해도, 같은 인스턴스를 나눠 보기 때문에 한쪽의
        // 변화가 다른 쪽에 그대로 비칩니다.
        ImmersiveSpace(id: model.immersiveSpaceID) {
            SolarSystem()
                .environment(model)
        }
        .immersionStyle(selection: $solarImmersionStyle, in: .full)
    }
}
