//
//  PlanetEntity.swift
//  SolarSystem
//
//  Created by Saerom on 8/13/26.
//

import RealityKit
import SwiftUI
import UIKit
import WorldAssets

/// An entity that represents one planet: it orbits the Sun on a visible
/// path, spins on a tilted axis, and can itself be looked at and pinched to
/// focus on it.
///
/// Earth is special-cased to wrap the existing `EarthEntity` (which already
/// manages its own tilt, spin, Moon, and satellites), while every other
/// planet uses a procedurally generated placeholder sphere until a real
/// textured asset is added to `WorldAssets`.
class PlanetEntity: Entity {

    // MARK: - Sub-entities

    /// Rotates around the Sun to create the planet's revolution.
    private let orbitPivot = Entity()
    /// Positions the planet at its distance from the Sun.
    private let radiusOffset = Entity()
    /// Holds the planet's axial tilt. This is the entity that gets
    /// reparented into the focus stage when someone selects this planet.
    private let equatorialPlane = Entity()
    /// Spins around the tilted axis to create the planet's rotation.
    private let rotator = Entity()
    /// A thin, static ring tracing this planet's orbit around the Sun --
    /// unlike `orbitPivot`, this never rotates, so the path itself stays
    /// visible regardless of where the planet currently is on it.
    private let orbitPath = Entity()
    /// An invisible hover/pinch target sized to the planet, kept as its own
    /// entity rather than components on `model` -- Earth's model wraps a
    /// whole `EarthEntity` hierarchy that may own its own colliders on
    /// nested children, which would otherwise catch the tap first and hide
    /// our `PlanetSelectionComponent` from it.
    private let selectionTarget = Entity()

    /// The visible model. For Earth this is the shared `EarthEntity`; for
    /// every other planet it's a loaded or generated sphere.
    private var model: Entity = Entity()

    /// Set only when this planet wraps an `EarthEntity`, so `update(...)`
    /// can forward Earth-specific configuration to it.
    private var earthEntity: EarthEntity?

    // MARK: - Internal state

    // Named `planetID`, not `id` -- `Entity` already declares a non-open
    // `id: UInt64` that a subclass can't override.
    let planetID: PlanetID
    private var configuration: Configuration
    private var isFocused = false

    // MARK: - Initializers

    @MainActor required init() {
        planetID = .mercury
        configuration = .mercury
        super.init()
    }

    /// Creates a new planet entity with the specified configuration.
    init(configuration: Configuration) async {
        self.planetID = configuration.id
        self.configuration = configuration
        super.init()

        // Build the orbit -> tilt -> spin hierarchy. `orbitPath` is a
        // sibling of `orbitPivot`, not a child of it, so it stays fixed in
        // place while the planet revolves around it.
        addChild(orbitPivot)
        addChild(orbitPath)
        orbitPivot.addChild(radiusOffset)
        radiusOffset.addChild(equatorialPlane)
        equatorialPlane.addChild(rotator)

        // Every planet shares the same center (where the Sun model is
        // drawn) and the same presentation tilt (so the whole system reads
        // as seen from above). Set once -- this never changes afterward.
        position = configuration.sceneCenter
        orientation = configuration.presentationTilt

        Self.configureOrbitPath(orbitPath, orbitRadius: configuration.orbitRadius)

        // Stagger the starting point along the orbit so planets don't all
        // line up, and set this only once -- `update(...)` must never touch
        // it again, or the planet's orbit progress would reset every time.
        orbitPivot.orientation = .init(angle: Float(configuration.initialOrbitAngle.radians), axis: [0, 1, 0])

        // Set the planet's axial tilt once. It doesn't change after
        // creation, so `setFocused(...)` can reapply this same value when
        // it reparents `equatorialPlane` without fighting `update(...)`.
        equatorialPlane.orientation = Self.tiltOrientation(configuration.axialTilt)

        // Load this planet's model.
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

        // An invisible target, sized to the planet, is what people look at
        // and pinch to focus it -- no separate visible marker floating
        // above it.
        rotator.addChild(selectionTarget)
        Self.configureSelectionTarget(selectionTarget, planetID: configuration.id, radius: configuration.ringRadius)

        update(configuration: configuration, animateUpdates: false)
    }

    // MARK: - Updates

    /// Updates all the entity's configurable elements.
    func update(configuration: Configuration, animateUpdates: Bool) {
        self.configuration = configuration

        // Hides this entire planet (model, orbit path, hit target) while a
        // different planet is focused. This entity's own focused content
        // has already been reparented into the shared focus stage by
        // `setFocused(...)` and isn't affected by `isEnabled` here.
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

    // MARK: - Focus

    /// The size every planet is scaled to when focused, regardless of its
    /// natural size -- so tiny Mercury and huge Jupiter both read clearly
    /// at a glance instead of the focused planet's size varying wildly.
    static let focusDisplayRadius: Float = 0.35
    /// How much the info panel is enlarged while focused, so its text reads
    /// comfortably next to the enlarged planet.
    static let focusPanelScale: Float = 1.4
    /// Half the focused panel's width in meters: `PlanetInfoPanel` is 760
    /// points wide (about 0.56 m), times `focusPanelScale`.
    static let focusPanelHalfWidth: Float = 0.28 * focusPanelScale
    /// Where the info panel's center offsets from a focused planet's center,
    /// leaving a small gap so the two sit side by side as roughly equal
    /// halves of the view.
    static let focusPanelOffset: Float = focusDisplayRadius + 0.1 + focusPanelHalfWidth

    /// How much bigger (or smaller) this planet gets scaled to reach
    /// `focusDisplayRadius` once focused.
    private var focusScale: Float {
        Self.focusDisplayRadius / max(configuration.ringRadius, 0.05)
    }

    /// Animates the planet in or out of a fixed "focus" position so it can
    /// appear side-by-side with its info panel, and pauses its revolution
    /// around the Sun while focused.
    ///
    /// - Parameters:
    ///   - focused: Whether this planet should be in the focus stage.
    ///   - stage: The shared entity that hosts the currently focused planet.
    ///   - animated: Whether to animate the transition.
    func setFocused(_ focused: Bool, stage: Entity, animated: Bool = true) {
        guard focused != isFocused else { return }
        isFocused = focused

        let newParent = focused ? stage : radiusOffset
        newParent.addChild(equatorialPlane, preservingWorldTransform: true)

        // The target keeps the planet's axial tilt but resets its position
        // relative to the new parent, so it lands centered on the stage (or
        // back at its normal orbit offset). Focused planets also scale up
        // to a consistent, clearly visible size.
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

        setRotationSpeed(focused ? 0 : configuration.currentRevolutionSpeed, on: orbitPivot)
    }

    // MARK: - Model loading

    /// Tries to load a real model named for this planet from `WorldAssets`,
    /// and falls back to a plain colored sphere when one doesn't exist yet.
    /// Unlike `WorldAssets.entity(named:)`, this never aborts the app -- a
    /// missing asset is the expected, common case for most planets today.
    private static func loadPlaceholderModel(assetName: String, radius: Float, color: Color) async -> Entity {
        if let asset = try? await Entity(named: assetName, in: worldAssetsBundle) {
            return normalizedToUnitRadius(asset)
        }
        let material = SimpleMaterial(color: UIColor(color), isMetallic: false)
        return ModelEntity(mesh: .generateSphere(radius: radius), materials: [material])
    }

    /// Wraps a loaded asset so it's centered with a radius of 1, whatever
    /// size it was authored at -- `update(...)` then scales it by
    /// `visualRadius`, so the planet ends up exactly that big.
    ///
    /// Measures the pole-to-pole (Y) extent rather than the widest one, so
    /// Saturn's flat rings don't count toward its radius and shrink the body.
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

    /// Configures an invisible sphere, centered on the planet, as its
    /// hover/pinch target -- so people look at or pinch the planet directly
    /// instead of a separate marker floating above it.
    private static func configureSelectionTarget(_ target: Entity, planetID: PlanetID, radius: Float) {
        target.name = "\(planetID.displayName)-selectionTarget"
        target.components.set(PlanetSelectionComponent(planetID: planetID))
        target.components.set(InputTargetComponent())
        target.components.set(HoverEffectComponent())
        target.components.set(CollisionComponent(shapes: [.generateSphere(radius: max(radius, 0.05))]))
    }

    /// Builds the thin, static ring that traces this planet's orbit around
    /// the Sun, so the path itself is visible, not just implied by the
    /// planet's motion.
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

        // The ring mesh faces +Z by default; lay it flat into the orbital
        // (XZ) plane it's meant to trace.
        path.orientation = .init(angle: -.pi / 2, axis: [1, 0, 0])
    }

    /// Builds a flat, ring-shaped (annulus) mesh facing +Z, since RealityKit
    /// has no built-in torus/ring generator.
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
            // Front face.
            indices.append(contentsOf: [outerA, innerA, outerB])
            indices.append(contentsOf: [innerA, innerB, outerB])
            // Back face, so the ring reads from both sides.
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
