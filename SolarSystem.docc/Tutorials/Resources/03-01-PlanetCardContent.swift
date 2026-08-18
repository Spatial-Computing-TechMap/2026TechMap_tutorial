import SwiftUI
import RealityKit
import WorldAssets

/// The content shown for one placed planet.
struct PlanetCardContent: View {
    let name: String
    let scale: Float

    var body: some View {
        Text(name)
    }
}
