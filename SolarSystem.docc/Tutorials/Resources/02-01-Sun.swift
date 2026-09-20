import SwiftUI
import RealityKit
import SolarSystemAssets

/// 태양 모델입니다.
struct Sun: View {
    var scale: Float = 1
    var position: SIMD3<Float> = .zero

    /// 나중에 크기와 위치를 바꾸기 위해 만들어 둔 엔티티를 보관합니다.
    @State private var sun: Entity?

    var body: some View {
        RealityView { content in
            // SolarSystemAssets 패키지에서 "Sun"이라는 이름의 모델을 불러옵니다.
            guard let sun = try? await Entity(named: "Sun", in: solarSystemAssetsBundle) else {
                return
            }
            content.add(sun)
            self.sun = sun

            configure()

        } update: { content in
            // 바깥에서 scale이나 position이 바뀌면 여기가 다시 실행됩니다.
            configure()
        }
    }

    private func configure() {
        sun?.scale = SIMD3(repeating: scale)
        sun?.position = position
    }
}
