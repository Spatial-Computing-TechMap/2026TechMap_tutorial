import SwiftUI

/// 몰입 공간을 여닫는 창입니다.
struct ContentView: View {
    @Environment(AppModel.self) private var model
    @Environment(\.openImmersiveSpace) private var openImmersiveSpace
    @Environment(\.dismissImmersiveSpace) private var dismissImmersiveSpace

    var body: some View {
        VStack(spacing: 24) {
            Text("태양계")
                .font(.largeTitle)

            Button {
                Task {
                    switch model.immersiveSpaceState {
                    case .open:
                        // 닫는 동안에는 버튼을 눌러도 아무 일이 없도록 상태를 먼저 바꿉니다.
                        model.immersiveSpaceState = .inTransition
                        await dismissImmersiveSpace()
                        // 실제로 닫힌 뒤의 상태는 몰입 공간 쪽에서 갱신합니다.

                    case .closed:
                        model.immersiveSpaceState = .inTransition
                        switch await openImmersiveSpace(id: model.immersiveSpaceID) {
                        case .opened:
                            // 열린 뒤의 상태도 몰입 공간 쪽에서 갱신합니다.
                            break
                        case .userCancelled, .error:
                            model.immersiveSpaceState = .closed
                        @unknown default:
                            model.immersiveSpaceState = .closed
                        }

                    case .inTransition:
                        break
                    }
                }
            } label: {
                Text(model.immersiveSpaceState == .open ? "태양계 닫기" : "태양계 열기")
            }
            .disabled(model.immersiveSpaceState == .inTransition)
        }
        .padding(60)
        .glassBackgroundEffect()
    }
}
