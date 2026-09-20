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

    /// 이 행성의 궤도를 그리는 얇은 고리입니다. `orbitPivot`과 달리 절대
    /// 돌지 않아서, 행성이 궤도 어디에 있든 경로 자체는 제자리에 남습니다.
    private let orbitPath = Entity()

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

        // `orbitPath`는 `orbitPivot`의 자식이 아니라 형제입니다. 자식으로
        // 넣으면 궤도선까지 행성과 함께 돌아버립니다.
        addChild(orbitPath)
        Self.configureOrbitPath(orbitPath, orbitRadius: configuration.orbitRadius)

        // 모든 행성이 같은 중심(태양 모델이 그려지는 자리)과 같은 기울기를
        // 공유합니다. 한 번만 정하고 이후로는 건드리지 않습니다.
        position = configuration.sceneCenter
        orientation = configuration.presentationTilt

        // 행성이 전부 일직선에 서지 않도록 궤도 시작점을 어긋나게 둡니다.
        // 이 값도 여기서 한 번만 설정합니다. `update(...)`가 다시 건드리면
        // 갱신될 때마다 공전 진행도가 0으로 되돌아갑니다.
        orbitPivot.orientation = .init(
            angle: Float(configuration.initialOrbitAngle.radians),
            axis: [0, 1, 0])

        // 자전축 기울기도 한 번만 정합니다.
        equatorialPlane.orientation = Self.tiltOrientation(configuration.axialTilt)

        // 모델을 불러와 가장 안쪽인 `rotator`에 매답니다. 이제 이 모델은
        // 자전(rotator) + 기울기(equatorialPlane) + 거리(radiusOffset) +
        // 공전(orbitPivot)을 한꺼번에 물려받습니다.
        model = await Self.loadModel(
            assetName: configuration.id.assetName,
            radius: configuration.visualRadius,
            color: .gray)
        rotator.addChild(model)

        update(configuration: configuration, animateUpdates: false)
    }

    // MARK: - 모델 불러오기

    /// 이름이 같은 실제 모델을 먼저 찾고, 없으면 단색 구로 대신합니다.
    private static func loadModel(assetName: String, radius: Float, color: Color) async -> Entity {
        if let asset = try? await Entity(named: assetName, in: worldAssetsBundle) {
            return normalizedToUnitRadius(asset)
        }
        let material = SimpleMaterial(color: UIColor(color), isMetallic: false)
        return ModelEntity(mesh: .generateSphere(radius: radius), materials: [material])
    }

    /// 어떤 크기로 만들어진 모델이든 반지름 1로 맞춰 감쌉니다. 그래야
    /// `update(...)`에서 `visualRadius`를 곱하면 정확히 그 크기가 됩니다.
    ///
    /// 가장 넓은 쪽이 아니라 극-극(Y) 길이로 재는 이유는, 토성의 납작한
    /// 고리가 반지름으로 계산되어 본체를 쪼그라뜨리지 않게 하기 위해서입니다.
    private static func normalizedToUnitRadius(_ asset: Entity) -> Entity {
        let bounds = asset.visualBounds(relativeTo: nil)
        let radius = bounds.extents.y / 2
        guard radius > 0 else { return asset }

        asset.scale = SIMD3(repeating: 1 / radius)
        asset.position = -bounds.center / radius

        let container = Entity()
        container.addChild(asset)
        return container
    }

    private static func tiltOrientation(_ tilt: Angle) -> simd_quatf {
        .init(angle: Float(tilt.radians), axis: [0, 0, 1])
    }

    // MARK: - 갱신

    /// 설정이 바뀔 때마다 불려서 거리와 회전 속도를 다시 맞춥니다.
    func update(configuration: Configuration, animateUpdates: Bool) {
        self.configuration = configuration

        radiusOffset.position = [0, 0, configuration.orbitRadius]
        model.scale = SIMD3(repeating: configuration.visualRadius)

        // 공전과 자전은 서로 다른 엔티티가 맡으므로, 같은 컴포넌트를
        // 각각 붙여 주기만 하면 됩니다. 실제로 돌리는 일은
        // `RotationSystem`이 매 프레임 알아서 합니다.
        setRotationSpeed(configuration.currentRevolutionSpeed, on: orbitPivot)
        setRotationSpeed(configuration.currentRotationSpeed, on: rotator)
    }

    private func setRotationSpeed(_ speed: Float, on entity: Entity) {
        if var rotation: RotationComponent = entity.components[RotationComponent.self] {
            rotation.speed = speed
            entity.components[RotationComponent.self] = rotation
        } else {
            entity.components.set(RotationComponent(speed: speed))
        }
    }
}
