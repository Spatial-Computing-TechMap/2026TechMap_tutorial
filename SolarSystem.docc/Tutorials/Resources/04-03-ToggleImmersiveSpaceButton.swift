import SwiftUI

/// 몰입 공간을 여닫는 버튼입니다.
struct ToggleImmersiveSpaceButton: View {
    @Environment(AppModel.self) private var model

    @Environment(\.dismissImmersiveSpace) private var dismissImmersiveSpace
    @Environment(\.openImmersiveSpace) private var openImmersiveSpace

    var body: some View {
        Button {
            Task { @MainActor in
                switch model.immersiveSpaceState {
                case .open:
                    model.immersiveSpaceState = .inTransition
                    await dismissImmersiveSpace()
                    // 닫힌 뒤의 상태는 `SolarSystem`의 `onDisappear`가
                    // 설정하므로 여기서 다시 쓰지 않습니다.

                case .closed:
                    model.immersiveSpaceState = .inTransition
                    // 여기 쓰는 id가 `@main`의 `ImmersiveSpace(id:)`와
                    // 같아야 합니다. 다르면 조용히 열리지 않습니다.
                    switch await openImmersiveSpace(id: model.immersiveSpaceID) {
                    case .opened:
                        break
                    case .userCancelled, .error:
                        fallthrough
                    @unknown default:
                        model.immersiveSpaceState = .closed
                    }

                case .inTransition:
                    // 전환 중에는 아무것도 하지 않습니다.
                    break
                }
            }
        } label: {
            Text(model.immersiveSpaceState == .open ? "태양계 닫기" : "태양계 열기")
        }
        // 전환이 끝날 때까지 버튼을 잠급니다.
        .disabled(model.immersiveSpaceState == .inTransition)
        .animation(.none, value: 0)
        .fontWeight(.semibold)
    }
}
