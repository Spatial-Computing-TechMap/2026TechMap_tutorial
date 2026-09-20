import SwiftUI
import RealityKit

/// 몰입 공간에 보여 줄 내용 전체입니다.
struct SolarSystem: View {
    @Environment(AppModel.self) private var model

    var body: some View {
        ZStack {
            Starfield()
        }
        .onAppear {
            model.immersiveSpaceState = .open
        }
        .onDisappear {
            model.immersiveSpaceState = .closed
        }
    }
}
