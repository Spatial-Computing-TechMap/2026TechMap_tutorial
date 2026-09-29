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

        Self.configureOrbitPath(orbitPath, orbitRadius: configuration.orbitRadius)

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
