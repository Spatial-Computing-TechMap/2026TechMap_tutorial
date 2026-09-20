import SwiftUI
import RealityKit

/// 안쪽 면에 밤하늘 이미지를 입힌 아주 큰 구입니다.
///
/// 사람이 구의 한가운데에 있으면 우주 공간에 떠 있는 것처럼 보입니다.
struct Starfield: View {
    var body: some View {
        RealityView { content in
            // 에셋 카탈로그에 있는 별 이미지를 불러옵니다.
            guard let resource = try? await TextureResource(named: "Starfield") else {
                fatalError("Starfield 텍스처를 불러오지 못했습니다.")
            }

            // 빛의 영향을 받지 않는 재질을 씁니다. 별은 늘 같은 밝기로 보여야 하기 때문입니다.
            var material = UnlitMaterial()
            material.color = .init(texture: .init(resource))

            let entity = Entity()
            entity.components.set(ModelComponent(
                mesh: .generateSphere(radius: 1000),
                materials: [material]
            ))

            // 구를 좌우로 뒤집어 이미지가 안쪽을 향하게 합니다.
            entity.scale *= .init(x: -1, y: 1, z: 1)

            content.add(entity)
        }
    }
}
