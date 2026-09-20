import RealityKit

/// 이 엔티티가 "어느 행성의 탭 타겟인지" 표시하는 꼬리표입니다.
///
/// `InputTargetComponent`, `CollisionComponent`, `HoverEffectComponent`와
/// 함께 붙이면 visionOS가 시선 하이라이트와 핀치 선택을 알아서 처리합니다.
/// 이 컴포넌트는 제스처가 들어왔을 때 "어느 행성인지"를 되찾기 위한
/// 표식일 뿐, 스스로 하는 일은 없습니다.
struct PlanetSelectionComponent: Component {
    let planetID: PlanetID
}
