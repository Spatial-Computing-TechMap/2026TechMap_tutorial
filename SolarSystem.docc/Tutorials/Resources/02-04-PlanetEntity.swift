import RealityKit
import SwiftUI
import UIKit
import WorldAssets

class PlanetEntity: Entity {

    private let orbitPivot = Entity()
    private let radiusOffset = Entity()
    private let equatorialPlane = Entity()
    private let rotator = Entity()
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

}
