import RealityKit

/// 이 엔티티가 어떤 행성을 선택하는 대상인지 표시하는 컴포넌트입니다.
///
/// 값을 담아 두는 것 말고는 하는 일이 없습니다. 탭이 일어났을 때 "지금 집은 것이
/// 행성 선택 대상이 맞는지, 맞다면 어느 행성인지"를 알아내는 표식으로 씁니다.
struct PlanetSelectionComponent: Component {
    let planetID: PlanetID
}
