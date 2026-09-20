/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
A system and component for creating entity rotation.
*/

import SwiftUI
import RealityKit

/// Rotation information for an entity.
struct RotationComponent: Component {
    var speed: Float
    var axis: SIMD3<Float>

    init(speed: Float = 1.0, axis: SIMD3<Float> = [0, 1, 0]) {
        self.speed = speed
        self.axis = axis
    }
}

