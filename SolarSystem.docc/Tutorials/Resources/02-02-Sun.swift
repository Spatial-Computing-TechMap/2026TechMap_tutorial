import SwiftUI
import RealityKit
import SolarSystemAssets

/// 태양 모델과, 장면 전체를 비추는 빛입니다.
struct Sun: View {
    var scale: Float = 1
    var position: SIMD3<Float> = .zero

    @State private var sun: Entity?

    /// 빛은 모델과 분리해 둡니다. 모델의 크기를 키우면 자식 엔티티의 빛이 닿는 거리도
    /// 함께 늘어나기 때문에, 밝기를 따로 다루기 위해서입니다.
    @State private var light: Entity?

    var body: some View {
        RealityView { content in
            guard let sun = try? await Entity(named: "Sun", in: solarSystemAssetsBundle) else {
                return
            }
            content.add(sun)
            self.sun = sun

            // 전체 몰입 공간에는 기본 조명이 없습니다. 빛을 직접 넣지 않으면
            // 행성이 모두 새까맣게 보입니다.
            let light = Entity()
            light.components.set(PointLightComponent(
                color: .white,
                intensity: 200_000,
                attenuationRadius: 60))
            content.add(light)
            self.light = light

            configure()

        } update: { content in
            configure()
        }
    }

    private func configure() {
        sun?.scale = SIMD3(repeating: scale)
        sun?.position = position
        light?.position = position
    }
}
