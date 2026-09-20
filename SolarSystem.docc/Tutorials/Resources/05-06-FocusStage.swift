import SwiftUI
import RealityKit

/// 확대한 행성이 들어가는 자리와, 그 행성을 비추는 조명입니다.
struct FocusStage: View {
    @Binding var stageEntity: Entity?

    /// 지금 확대된 행성이 있는지 여부입니다. 조명을 켜고 끄는 데 씁니다.
    var isActive: Bool

    @State private var keyLight: Entity?

    var body: some View {
        RealityView { content in
            let stage = Entity()
            stage.name = "FocusStage"
            stage.position = [0, 1.4, -1.6]
            content.add(stage)
            stageEntity = stage

            // 조명을 자리의 자식으로 붙입니다. 자리가 시선 앞으로 옮겨질 때
            // 조명도 함께 따라갑니다.
            //
            // 태양은 멀리 뒤쪽에 있어서, 확대한 행성의 사람을 향한 면이 어둡습니다.
            // 그래서 사람 쪽 왼쪽 위에서 비추는 빛을 따로 둡니다.
            let light = Entity()
            light.components.set(DirectionalLightComponent(color: .white, intensity: 2000))
            stage.addChild(light)
            light.look(at: .zero, from: [-0.8, 0.8, 1.5], relativeTo: stage)
            light.isEnabled = isActive
            keyLight = light

        } update: { content in
            keyLight?.isEnabled = isActive
        }
    }
}
