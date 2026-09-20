import SwiftUI
import RealityKit

/// 선택된 행성과 설명 패널이 모여드는, 단 하나뿐인 무대입니다.
///
/// 모든 `Planet` 뷰가 자기 행성을 여기로 옮겨 붙이기 때문에, 그 행성이
/// 궤도 어디에 있었든 늘 같은 자리에 같은 크기로 나타납니다.
struct FocusStage: View {
    @Binding var stageEntity: Entity?
    /// 행성이 선택되어 있는 동안에만 키 라이트를 켭니다.
    var isActive: Bool

    /// 보는 사람 쪽에서 행성을 비추는 빛입니다. 이게 없으면 유일한 광원인
    /// 태양이 무대 훨씬 뒤에 있어서, 정면이 어둡고 탁하게 보입니다.
    @State private var keyLight: Entity?

    var body: some View {
        RealityView { content in
            let stage = Entity()
            stage.name = "FocusStage"
            stage.position = [0, 1.4, -1.6]
            content.add(stage)
            stageEntity = stage

            let light = Entity()
            light.components.set(DirectionalLightComponent(color: .white, intensity: 2000))
            stage.addChild(light)
            light.look(at: .zero, from: [-0.8, 0.8, 1.5], relativeTo: stage)
            light.isEnabled = isActive
            keyLight = light

        } update: { _ in
            keyLight?.isEnabled = isActive
        }
    }
}
