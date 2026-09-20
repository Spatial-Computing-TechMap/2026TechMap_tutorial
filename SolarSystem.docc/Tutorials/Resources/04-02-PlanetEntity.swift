import RealityKit
import SwiftUI
import UIKit
import SolarSystemAssets

class PlanetEntity: Entity {

    private let orbitPivot = Entity()
    private let radiusOffset = Entity()
    private let equatorialPlane = Entity()
    private let rotator = Entity()

    private var model: Entity = Entity()

    /// 눈으로 보고 손가락을 맞댈 때 반응하는, 눈에 보이지 않는 대상입니다.
    /// 모델에 직접 붙이지 않고 따로 두면, 모델의 구조가 어떻든 상관없이
    /// 행성 전체를 감싸는 하나의 대상으로 다룰 수 있습니다.
    private let selectionTarget = Entity()

    let planetID: PlanetID
    private var configuration: Configuration

    @MainActor required init() {
        planetID = .mercury
        configuration = .mercury
        super.init()
    }

    init(configuration: Configuration) async {
        self.planetID = configuration.id
        self.configuration = configuration
        super.init()

        addChild(orbitPivot)
        orbitPivot.addChild(radiusOffset)
        radiusOffset.addChild(equatorialPlane)
        equatorialPlane.addChild(rotator)

        position = configuration.sceneCenter
        orientation = configuration.presentationTilt

        orbitPivot.orientation = .init(
            angle: Float(configuration.initialOrbitAngle.radians),
            axis: [0, 1, 0])
        equatorialPlane.orientation = Self.tiltOrientation(configuration.axialTilt)

        model = await Self.loadModel(
            assetName: configuration.id.assetName,
            radius: configuration.visualRadius,
            color: configuration.placeholderColor)
        rotator.addChild(model)

        // 선택 대상도 자전하는 엔티티에 붙여, 행성과 늘 같은 자리에 있게 합니다.
        rotator.addChild(selectionTarget)
        Self.configureSelectionTarget(
            selectionTarget,
            planetID: configuration.id,
            radius: configuration.visualRadius)

        update(configuration: configuration)
    }

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

    // MARK: - 선택 대상

    /// 행성을 감싸는, 눈에 보이지 않는 구를 선택 대상으로 만듭니다.
    ///
    /// 세 가지 컴포넌트가 함께 필요합니다.
    /// - `PlanetSelectionComponent`: 어느 행성인지 알려 주는 표식
    /// - `InputTargetComponent`: 입력을 받을 수 있다는 표시
    /// - `CollisionComponent`: 어디까지가 그 대상인지 정하는 영역
    /// - `HoverEffectComponent`: 바라볼 때 은은하게 밝아지는 효과
    private static func configureSelectionTarget(_ target: Entity, planetID: PlanetID, radius: Float) {
        target.name = "\(planetID.displayName)-selectionTarget"
        target.components.set(PlanetSelectionComponent(planetID: planetID))
        target.components.set(InputTargetComponent())
        target.components.set(HoverEffectComponent())

        // 모델보다 조금 넉넉하게 잡아, 가장자리를 봐도 선택되게 합니다.
        target.components.set(CollisionComponent(shapes: [
            .generateSphere(radius: max(radius * 1.3, 0.05))
        ]))
    }

    // MARK: - 모델 불러오기

    private static func loadModel(assetName: String, radius: Float, color: Color) async -> Entity {
        if let asset = try? await Entity(named: assetName, in: solarSystemAssetsBundle) {
            return normalizedToUnitRadius(asset)
        }
        let material = SimpleMaterial(color: UIColor(color), isMetallic: false)
        return ModelEntity(mesh: .generateSphere(radius: radius), materials: [material])
    }

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
