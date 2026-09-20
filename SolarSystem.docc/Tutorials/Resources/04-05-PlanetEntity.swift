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
    private let selectionTarget = Entity()

    let planetID: PlanetID
    private var configuration: Configuration
    private var isFocused = false

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

        // 확대된 동안에는 공전을 멈춥니다. 궤도를 계속 돌면 제자리에 머물지 않습니다.
        setRotationSpeed(isFocused ? 0 : configuration.revolutionSpeed, on: orbitPivot)
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

    // MARK: - 확대해서 보기

    /// 확대했을 때의 반지름입니다. 어떤 행성을 골라도 같은 크기로 보이게 합니다.
    /// 작은 수성과 큰 목성이 매번 다른 크기로 나타나면 읽기 어렵기 때문입니다.
    static let focusDisplayRadius: Float = 0.35

    /// 이 행성이 `focusDisplayRadius`가 되려면 몇 배로 키워야 하는지 구합니다.
    private var focusScale: Float {
        Self.focusDisplayRadius / max(configuration.visualRadius, 0.05)
    }

    /// 행성을 확대 자리로 옮기거나, 원래 궤도로 돌려보냅니다.
    ///
    /// - Parameters:
    ///   - focused: 확대할지 여부입니다.
    ///   - stage: 확대한 행성이 들어갈 공용 자리입니다.
    ///   - animated: 움직임을 애니메이션으로 보여 줄지 여부입니다.
    func setFocused(_ focused: Bool, stage: Entity, animated: Bool = true) {
        // 상태가 그대로면 아무것도 하지 않습니다.
        // 이 검사가 없으면 화면이 갱신될 때마다 애니메이션이 다시 시작됩니다.
        guard focused != isFocused else { return }
        isFocused = focused

        let newParent = focused ? stage : radiusOffset

        // 부모를 바꾸면서도 지금 보이는 위치는 그대로 두는 방식입니다.
        // 그래야 행성이 순간이동하지 않고 지금 자리에서 부드럽게 날아옵니다.
        newParent.addChild(equatorialPlane, preservingWorldTransform: true)

        let scale: Float = focused ? focusScale : 1
        let target = Transform(
            scale: SIMD3(repeating: scale),
            rotation: Self.tiltOrientation(configuration.axialTilt),
            translation: .zero)

        if animated {
            equatorialPlane.move(to: target, relativeTo: newParent, duration: 0.6)
        } else {
            equatorialPlane.move(to: target, relativeTo: newParent)
        }

        setRotationSpeed(focused ? 0 : configuration.revolutionSpeed, on: orbitPivot)
    }

    // MARK: - 선택 대상

    private static func configureSelectionTarget(_ target: Entity, planetID: PlanetID, radius: Float) {
        target.name = "\(planetID.displayName)-selectionTarget"
        target.components.set(PlanetSelectionComponent(planetID: planetID))
        target.components.set(InputTargetComponent())
        target.components.set(HoverEffectComponent())
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
