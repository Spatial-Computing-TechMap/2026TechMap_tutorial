import SwiftUI
import RealityKit

/// 엔티티를 얼마나 빠르게, 어느 축으로 돌릴지 담는 값입니다.
///
/// 컴포넌트는 값만 들고 있을 뿐, 스스로 아무 일도 하지 않습니다.
/// 실제로 돌리는 일은 아래 `RotationSystem`이 맡습니다.
struct RotationComponent: Component {
    var speed: Float
    var axis: SIMD3<Float>

    init(speed: Float = 1.0, axis: SIMD3<Float> = [0, 1, 0]) {
        self.speed = speed
        self.axis = axis
    }
}
