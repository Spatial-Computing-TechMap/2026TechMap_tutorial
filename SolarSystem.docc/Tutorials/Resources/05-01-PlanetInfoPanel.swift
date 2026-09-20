import SwiftUI

/// 확대한 행성 옆에 뜨는 설명 패널입니다.
struct PlanetInfoPanel: View {
    /// RealityView에 붙일 때 쓰는 이름입니다.
    static let attachmentID = "planetInfoPanel"

    /// 패널을 3차원 공간에서 몇 배로 키울지 정합니다.
    /// 1.4배로 두면 확대한 행성 옆에서 글씨가 읽기 좋은 크기가 됩니다.
    static let focusScale: Float = 1.4

    /// 패널 너비의 절반입니다. 미터 단위입니다.
    /// 760포인트는 약 0.56미터이므로, 절반은 0.28미터입니다.
    static let halfWidth: Float = 0.28 * focusScale

    /// 행성 중심에서 패널 중심까지의 거리입니다.
    /// 행성 반지름 + 사이 여백 + 패널 절반 너비입니다.
    static let offset: Float = PlanetEntity.focusDisplayRadius + 0.1 + halfWidth

    var planetID: PlanetID
    var onPrevious: () -> Void
    var onNext: () -> Void
    var onClose: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            HStack {
                Text(planetID.displayName)
                    .font(.largeTitle)
                    .fontWeight(.semibold)

                Spacer()

                Button(action: onClose) {
                    Label("닫기", systemImage: "xmark")
                }
                .buttonStyle(.borderless)
                .labelStyle(.iconOnly)
            }

            Text(planetID.fact)
                .font(.title3)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)

            Spacer()

            HStack {
                Button(action: onPrevious) {
                    Label("이전 행성", systemImage: "chevron.left")
                }

                Spacer()

                Button(action: onNext) {
                    Label("다음 행성", systemImage: "chevron.right")
                }
            }
            .labelStyle(.iconOnly)
        }
        .padding(40)
        .frame(width: 760, height: 520)
        .glassBackgroundEffect(in: .rect(cornerRadius: 36))
    }
}
