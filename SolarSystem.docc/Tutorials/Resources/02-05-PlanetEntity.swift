import RealityKit
import SwiftUI
import UIKit
import WorldAssets

/// 행성 하나를 나타내는 엔티티입니다.
///
/// 태양 주위를 공전하고, 기울어진 축을 중심으로 제자리에서 자전합니다.
/// 회전이 두 가지라 한 엔티티로는 표현할 수 없어서, 역할마다 빈 엔티티를
/// 하나씩 두고 부모-자식으로 엮습니다.
class PlanetEntity: Entity {

    // MARK: - 하위 엔티티

    /// 태양 주위를 돌아 공전을 만듭니다.
    private let orbitPivot = Entity()
    /// 행성을 태양에서 떨어진 거리만큼 밀어냅니다.
    private let radiusOffset = Entity()
    /// 행성의 자전축 기울기를 담습니다.
    private let equatorialPlane = Entity()
    /// 기울어진 축을 중심으로 돌아 자전을 만듭니다.
    private let rotator = Entity()

    /// 눈에 보이는 모델입니다.
    private var model: Entity = Entity()

    // MARK: - 상태

    // `id`가 아니라 `planetID`입니다. `Entity`가 이미 재정의할 수 없는
    // `id: UInt64`를 갖고 있습니다.
    let planetID: PlanetID
    private var configuration: Configuration

    @MainActor required init() {
        planetID = .mercury
        configuration = .mercury
        super.init()
    }

    // MARK: - 초기화

    init(configuration: Configuration) async {
        self.planetID = configuration.id
        self.configuration = configuration
        super.init()

        // 공전 -> 거리 -> 축 기울기 -> 자전 순으로 계층을 쌓습니다.
        // 부모의 변환이 자식에게 누적되므로, 각 엔티티는 자기 역할 하나만
        // 맡으면서도 결과적으로 네 가지가 한꺼번에 적용됩니다.
        addChild(orbitPivot)
        orbitPivot.addChild(radiusOffset)
        radiusOffset.addChild(equatorialPlane)
        equatorialPlane.addChild(rotator)
    }
}
