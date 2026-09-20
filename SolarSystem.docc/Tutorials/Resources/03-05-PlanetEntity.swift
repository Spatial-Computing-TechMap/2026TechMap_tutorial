import RealityKit
import SwiftUI
import UIKit
import SolarSystemAssets

/// 행성 하나를 나타내는 엔티티입니다.
///
/// 공전과 자전을 분리하기 위해, 빈 엔티티 네 개를 층층이 겹쳐 씁니다.
class PlanetEntity: Entity {

    // MARK: - 하위 엔티티

    /// 태양을 중심으로 돌며 공전을 만듭니다.
    private let orbitPivot = Entity()
    /// 행성을 태양에서 궤도 반지름만큼 떨어뜨립니다.
    private let radiusOffset = Entity()
    /// 자전축의 기울기를 담당합니다.
    private let equatorialPlane = Entity()
    /// 기울어진 축을 기준으로 돌며 자전을 만듭니다.
    private let rotator = Entity()

    /// 눈에 보이는 모델입니다.
    private var model: Entity = Entity()

    // MARK: - 상태

    // `id`가 아니라 `planetID`로 이름 붙입니다.
    // `Entity`가 이미 `id`라는 이름을 쓰고 있기 때문입니다.
    let planetID: PlanetID
    private var configuration: Configuration

    // MARK: - 초기화

    @MainActor required init() {
        planetID = .mercury
        configuration = .mercury
        super.init()
    }

    init(configuration: Configuration) async {
        self.planetID = configuration.id
        self.configuration = configuration
        super.init()

        // 공전 -> 거리 -> 기울기 -> 자전 순서로 층을 쌓습니다.
        addChild(orbitPivot)
        orbitPivot.addChild(radiusOffset)
        radiusOffset.addChild(equatorialPlane)
        equatorialPlane.addChild(rotator)

        // 모든 행성이 같은 중심과 같은 기울기를 씁니다.
        position = configuration.sceneCenter
        orientation = configuration.presentationTilt

        // 출발 각도는 처음 한 번만 정합니다.
        // 나중에 다시 건드리면 공전하던 위치가 처음으로 되돌아갑니다.
        orbitPivot.orientation = .init(
            angle: Float(configuration.initialOrbitAngle.radians),
            axis: [0, 1, 0])

        // 자전축 기울기도 처음 한 번만 정합니다.
        equatorialPlane.orientation = Self.tiltOrientation(configuration.axialTilt)

        // 모델을 불러옵니다.
        model = await Self.loadModel(
            assetName: configuration.id.assetName,
            radius: configuration.visualRadius,
            color: configuration.placeholderColor)
        rotator.addChild(model)

        update(configuration: configuration)
    }

    // MARK: - 갱신

    /// 바깥에서 설정이 바뀔 때마다 불립니다.
    func update(configuration: Configuration) {
        self.configuration = configuration

        radiusOffset.position = [0, 0, configuration.orbitRadius]

        setRotationSpeed(configuration.revolutionSpeed, on: orbitPivot)
        setRotationSpeed(configuration.rotationSpeed, on: rotator)

        model.scale = SIMD3(repeating: configuration.visualRadius)
    }

    private func setRotationSpeed(_ speed: Float, on entity: Entity) {
        if var rotation: RotationComponent = entity.components[RotationComponent.self] {
            rotation.speed = speed
            entity.components[RotationComponent.self] = rotation
        } else {
            entity.components.set(RotationComponent(speed: speed))
        }
    }

    // MARK: - 모델 불러오기

    /// 모델을 이름으로 찾고, 없으면 색만 칠한 구를 대신 만듭니다.
    private static func loadModel(assetName: String, radius: Float, color: Color) async -> Entity {
        if let asset = try? await Entity(named: assetName, in: solarSystemAssetsBundle) {
            return normalizedToUnitRadius(asset)
        }
        let material = SimpleMaterial(color: UIColor(color), isMetallic: false)
        return ModelEntity(mesh: .generateSphere(radius: radius), materials: [material])
    }

    /// 불러온 모델의 반지름을 1로 맞춥니다.
    /// 모델마다 원래 크기가 달라서, 이렇게 맞춰 두면 `visualRadius`가 곧 반지름이 됩니다.
    ///
    /// 가장 넓은 폭이 아니라 위아래 높이를 기준으로 재는 이유는 토성 때문입니다.
    /// 납작한 고리가 옆으로 넓게 퍼져 있어서, 폭으로 재면 본체가 작아집니다.
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
}
