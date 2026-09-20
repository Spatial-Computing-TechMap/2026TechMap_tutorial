import SwiftUI
import RealityKit

/// 엔티티를 얼마나 빠르게, 어느 축을 기준으로 돌릴지 담는 컴포넌트입니다.
///
/// 컴포넌트는 값만 가지고 있을 뿐, 스스로 무언가를 하지는 않습니다.
struct RotationComponent: Component {
    /// 초당 회전 각도입니다. 단위는 라디안입니다. 음수면 반대 방향으로 돕니다.
    var speed: Float
    /// 회전축입니다. 기본값은 세로축입니다.
    var axis: SIMD3<Float>

    init(speed: Float = 1.0, axis: SIMD3<Float> = [0, 1, 0]) {
        self.speed = speed
        self.axis = axis
    }
}

/// `RotationComponent`를 가진 엔티티를 매 프레임 찾아 조금씩 돌립니다.
///
/// 실제로 물체를 움직이는 일은 시스템이 합니다.
struct RotationSystem: System {
    /// 이 시스템이 처리할 엔티티를 고르는 조건입니다.
    static let query = EntityQuery(where: .has(RotationComponent.self))

    init(scene: RealityKit.Scene) {}

    func update(context: SceneUpdateContext) {
        for entity in context.entities(matching: Self.query, updatingSystemWhen: .rendering) {
            guard let component: RotationComponent = entity.components[RotationComponent.self] else { continue }

            // deltaTime은 지난 프레임과의 시간 간격입니다. 이 값을 곱해야
            // 화면 주사율과 상관없이 같은 속도로 돕니다.
            entity.setOrientation(
                .init(angle: component.speed * Float(context.deltaTime), axis: component.axis),
                relativeTo: entity)
        }
    }
}
