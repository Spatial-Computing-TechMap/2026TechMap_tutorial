import SwiftUI
import RealityKit
import WorldAssets

/// The content shown for one placed planet: its 3D model, and (on tap)
/// a description card.
struct PlanetCardContent: View {
    let name: String
    let scale: Float

    @State private var isCardShown = false

    var body: some View {
        Model3D(named: name, bundle: worldAssetsBundle) { model in
            model
                .resizable()
                .scaledToFit()
        } placeholder: {
            ProgressView()
        }
        .frame(width: CGFloat(scale) * 300, height: CGFloat(scale) * 300)
        .frame(depth: CGFloat(scale) * 300)
        .onTapGesture {
            isCardShown.toggle()
        }
    }
}
