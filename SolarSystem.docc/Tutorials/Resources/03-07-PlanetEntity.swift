import RealityKit
import SwiftUI
import UIKit
import WorldAssets

class PlanetEntity: Entity {

    private let orbitPivot = Entity()
    private let radiusOffset = Entity()
    private let equatorialPlane = Entity()
    private let rotator = Entity()
    private let orbitPath = Entity()
    private let selectionTarget = Entity()

    private var model: Entity = Entity()

    private var earthEntity: EarthEntity?

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
        addChild(orbitPath)
        orbitPivot.addChild(radiusOffset)
        radiusOffset.addChild(equatorialPlane)
        equatorialPlane.addChild(rotator)

        position = configuration.sceneCenter
        orientation = configuration.presentationTilt

        Self.configureOrbitPath(orbitPath, orbitRadius: configuration.orbitRadius)

        orbitPivot.orientation = .init(angle: Float(configuration.initialOrbitAngle.radians), axis: [0, 1, 0])

        equatorialPlane.orientation = Self.tiltOrientation(configuration.axialTilt)

        switch configuration.modelKind {
        case let .earth(earthConfiguration, satellites, moon):
            let earth = await EarthEntity(
                configuration: earthConfiguration,
                satelliteConfiguration: satellites,
                moonConfiguration: moon)
            earthEntity = earth
            model = earth

        case let .placeholder(color):
            model = await Self.loadPlaceholderModel(
                assetName: configuration.id.assetName,
                radius: configuration.visualRadius,
                color: color)
        }
        rotator.addChild(model)

        rotator.addChild(selectionTarget)
        Self.configureSelectionTarget(selectionTarget, planetID: configuration.id, radius: configuration.ringRadius)

        update(configuration: configuration, animateUpdates: false)
    }

    func update(configuration: Configuration, animateUpdates: Bool) {
        self.configuration = configuration

        isEnabled = !configuration.isHidden

        radiusOffset.position = [0, 0, configuration.orbitRadius]

        setRotationSpeed(isFocused ? 0 : configuration.currentRevolutionSpeed, on: orbitPivot)
        setRotationSpeed(configuration.currentRotationSpeed, on: rotator)

        switch configuration.modelKind {
        case let .earth(earthConfiguration, satellites, moon):
            earthEntity?.update(
                configuration: earthConfiguration,
                satelliteConfiguration: satellites,
                moonConfiguration: moon,
                animateUpdates: animateUpdates)

        case .placeholder:
            model.scale = SIMD3(repeating: configuration.visualRadius)
        }
    }

    private func setRotationSpeed(_ speed: Float, on entity: Entity) {
        if var rotation: RotationComponent = entity.components[RotationComponent.self] {
            rotation.speed = speed
            entity.components[RotationComponent.self] = rotation
        } else {
            entity.components.set(RotationComponent(speed: speed))
        }
    }

    static let focusDisplayRadius: Float = 0.35
    static let focusPanelScale: Float = 1.4
    static let focusPanelHalfWidth: Float = 0.28 * focusPanelScale
    static let focusPanelOffset: Float = focusDisplayRadius + 0.1 + focusPanelHalfWidth

    private var focusScale: Float {
        Self.focusDisplayRadius / max(configuration.ringRadius, 0.05)
    }

    private static func loadPlaceholderModel(assetName: String, radius: Float, color: Color) async -> Entity {
        if let asset = try? await Entity(named: assetName, in: worldAssetsBundle) {
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

    private static func configureSelectionTarget(_ target: Entity, planetID: PlanetID, radius: Float) {
        target.name = "\(planetID.displayName)-selectionTarget"
        target.components.set(PlanetSelectionComponent(planetID: planetID))
        target.components.set(InputTargetComponent())
        target.components.set(HoverEffectComponent())
        target.components.set(CollisionComponent(shapes: [.generateSphere(radius: max(radius, 0.05))]))
    }

    private static func configureOrbitPath(_ path: Entity, orbitRadius: Float) {
        let thickness: Float = 0.012
        guard let mesh = try? makeRingMesh(
            innerRadius: max(orbitRadius - thickness, 0),
            outerRadius: orbitRadius,
            segments: 96
        ) else { return }

        let material = UnlitMaterial(color: UIColor(white: 0.75, alpha: 1))
        let visual = ModelEntity(mesh: mesh, materials: [material])
        path.addChild(visual)

        path.orientation = .init(angle: -.pi / 2, axis: [1, 0, 0])
    }

    private static func makeRingMesh(innerRadius: Float, outerRadius: Float, segments: Int = 48) throws -> MeshResource {
        var positions: [SIMD3<Float>] = []
        var normals: [SIMD3<Float>] = []
        var uvs: [SIMD2<Float>] = []

        for i in 0...segments {
            let angle = Float(i) / Float(segments) * 2.0 * .pi
            let x = cos(angle)
            let y = sin(angle)
            positions.append([x * outerRadius, y * outerRadius, 0])
            positions.append([x * innerRadius, y * innerRadius, 0])
            normals.append([0, 0, 1])
            normals.append([0, 0, 1])
            let u = Float(i) / Float(segments)
            uvs.append([u, 0])
            uvs.append([u, 1])
        }

        var indices: [UInt32] = []
        for i in 0..<segments {
            let outerA = UInt32(i * 2)
            let innerA = UInt32(i * 2 + 1)
            let outerB = UInt32((i + 1) * 2)
            let innerB = UInt32((i + 1) * 2 + 1)
            indices.append(contentsOf: [outerA, innerA, outerB])
            indices.append(contentsOf: [innerA, innerB, outerB])
            indices.append(contentsOf: [outerB, innerA, outerA])
            indices.append(contentsOf: [outerB, innerB, innerA])
        }

        var descriptor = MeshDescriptor(name: "selectionRing")
        descriptor.positions = MeshBuffers.Positions(positions)
        descriptor.normals = MeshBuffers.Normals(normals)
        descriptor.textureCoordinates = MeshBuffers.TextureCoordinates(uvs)
        descriptor.primitives = .triangles(indices)

        return try MeshResource.generate(from: [descriptor])
    }
}
