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

    /// 보이지 않는 시선/핀치 타겟입니다. `model`에 컴포넌트를 직접 붙이지
    /// 않고 별도 엔티티로 둔 이유는, 불러온 모델이 자기 하위 엔티티에
    /// 콜라이더를 갖고 있을 수 있어서입니다. 그 콜라이더가 탭을 먼저
    /// 가로채면 `PlanetSelectionComponent`를 찾지 못합니다.
    private let selectionTarget = Entity()

    /// 눈에 보이는 모델입니다.
    private var model: Entity = Entity()

    // MARK: - 상태

    // `id`가 아니라 `planetID`입니다. `Entity`가 이미 재정의할 수 없는
    // `id: UInt64`를 갖고 있습니다.
    let planetID: PlanetID
    private var configuration: Configuration
    private var isFocused = false

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

        // 사람들이 실제로 바라보고 집는 대상입니다.
        rotator.addChild(selectionTarget)
        Self.configureSelectionTarget(
            selectionTarget,
            planetID: configuration.id,
            radius: configuration.ringRadius)

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

        // 다른 행성이 선택된 동안에는 이 행성을 통째로 숨깁니다.
        isEnabled = !configuration.isHidden

        radiusOffset.position = [0, 0, configuration.orbitRadius]
        model.scale = SIMD3(repeating: configuration.visualRadius)

        // 공전과 자전은 서로 다른 엔티티가 맡으므로, 같은 컴포넌트를
        // 각각 붙여 주기만 하면 됩니다. 실제로 돌리는 일은
        // `RotationSystem`이 매 프레임 알아서 합니다.
        setRotationSpeed(isFocused ? 0 : configuration.currentRevolutionSpeed, on: orbitPivot)
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

    // MARK: - 포커스

    /// 어떤 행성이든 선택되면 똑같이 이 크기가 됩니다. 그래야 작은 수성과
    /// 거대한 목성이 둘 다 한눈에 읽힙니다.
    static let focusDisplayRadius: Float = 0.35
    /// 확대된 행성 옆에서 글씨가 읽히도록 패널을 키우는 배율입니다.
    static let focusPanelScale: Float = 1.4
    /// 패널 너비의 절반(미터)입니다. `PlanetInfoPanel`이 760포인트,
    /// 약 0.56미터이므로 절반은 0.28미터입니다.
    static let focusPanelHalfWidth: Float = 0.28 * focusPanelScale
    /// 행성 중심에서 패널 중심까지의 거리입니다.
    static let focusPanelOffset: Float = focusDisplayRadius + 0.1 + focusPanelHalfWidth

    private var focusScale: Float {
        Self.focusDisplayRadius / max(configuration.ringRadius, 0.05)
    }


    /// 행성을 포커스 무대로 옮기거나 원래 궤도로 되돌립니다.
    func setFocused(_ focused: Bool, stage: Entity, animated: Bool = true) {
        guard focused != isFocused else { return }
        isFocused = focused

        let newParent = focused ? stage : radiusOffset

        // `preservingWorldTransform: true`가 핵심입니다. 부모만 바뀌고
        // 화면상 위치는 그대로라, 행성이 순간이동하지 않습니다. 그 다음
        // `move(to:)`가 제자리에서 목적지까지 부드럽게 이어 줍니다.
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

        // 포커스 중에는 공전을 멈춥니다.
        setRotationSpeed(focused ? 0 : configuration.currentRevolutionSpeed, on: orbitPivot)
    }

    // MARK: - 선택 타겟

    /// 행성 중심에 맞춘 보이지 않는 구를 시선/핀치 타겟으로 설정합니다.
    ///
    /// 세 컴포넌트가 모두 있어야 합니다. `CollisionComponent`가 없으면
    /// 광선이 맞을 형태가 없고, `InputTargetComponent`가 없으면 입력
    /// 대상으로 등록되지 않으며, `HoverEffectComponent`가 없으면 바라봐도
    /// 하이라이트가 뜨지 않습니다.
    private static func configureSelectionTarget(_ target: Entity, planetID: PlanetID, radius: Float) {
        target.name = "\(planetID.displayName)-selectionTarget"
        target.components.set(PlanetSelectionComponent(planetID: planetID))
        target.components.set(InputTargetComponent())
        target.components.set(HoverEffectComponent())
        target.components.set(CollisionComponent(shapes: [.generateSphere(radius: max(radius, 0.05))]))
    }
}
