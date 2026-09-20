import SwiftUI

/// 몰입 공간 상태에 따라 창에 보여줄 내용을 갈아 끼우는 뷰입니다.
struct SwitchWindows: View {
    @Environment(AppModel.self) private var model

    var body: some View {
        // 여러 뷰를 같은 3차원 공간에 겹쳐 두는 컨테이너입니다.
        // `alignment`에는 기본값이 없어서 반드시 적어야 합니다.
        SpatialContainer(alignment: .center) {
            SolarSystemControls()
                .opacity(model.isShowingSolar ? 1 : 0)
        }
    }
}
