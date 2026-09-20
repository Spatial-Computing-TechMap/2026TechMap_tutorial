import SwiftUI
import RealityKit

/// 확대한 행성이 들어가는, 비어 있는 자리입니다.
///
/// 행성마다 따로 자리를 만들지 않고 하나를 함께 씁니다. 어떤 행성을 골라도 늘 같은
/// 위치에 나타나게 하기 위해서입니다.
struct FocusStage: View {
    @Binding var stageEntity: Entity?

    var body: some View {
        RealityView { content in
            let stage = Entity()
            stage.name = "FocusStage"
            // 눈높이보다 조금 위, 1.6미터 앞입니다.
            // 다음 챕터에서 이 위치를 시선에 맞춰 옮깁니다.
            stage.position = [0, 1.4, -1.6]
            content.add(stage)
            stageEntity = stage
        }
    }
}
