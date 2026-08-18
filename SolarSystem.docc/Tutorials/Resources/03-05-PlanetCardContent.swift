import SwiftUI
import RealityKit
import WorldAssets

/// The content shown for one placed planet: its 3D model, and (on tap) a
/// description card depth-aligned beside it.
///
/// Positioning in the scene happens outside this view — SolarSystem.swift
/// places this as a RealityView attachment using ordinary RealityKit
/// meter-based coordinates (PlanetConfiguration.position), so this view only
/// needs to worry about what's shown, not where.
struct PlanetCardContent: View {
    let name: String
    let scale: Float

    @State private var isCardShown = false

    private var info: PlanetInfo {
        .info(for: name)
    }

    var body: some View {
        HStackLayout().depthAlignment(.center) {
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

            if isCardShown {
                VStack(alignment: .leading, spacing: 12) {
                    Text(info.heading)
                        .font(.title.bold())
                    Text(info.abstract)
                        .font(.body)
                }
                .frame(width: 260, alignment: .leading)
                .padding(30)
                .glassBackgroundEffect()
            }
        }
    }
}
