import RealityKit
import SwiftUI

@main
struct SolarSystemApp: App {

    /// 창과 몰입 공간이 함께 보는 상태입니다. 여기서 딱 한 번 만듭니다.
    @State private var model = AppModel()

    /// 몰입 스타일입니다. `.full`은 주변 현실을 완전히 가립니다.
    @State private var solarImmersionStyle: ImmersionStyle = .full

    init() {
        // 직접 만든 시스템은 앱이 시작할 때 한 번 등록해야 돌아갑니다.
        // 이 줄이 없으면 컴파일도 되고 크래시도 나지 않지만, 행성에
        // 아무리 `RotationComponent`를 붙여도 아무 일도 일어나지 않습니다.
        RotationSystem.registerSystem()
    }

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
