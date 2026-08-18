import SwiftUI
import RealityKit

/// The model content for the solar system module.
struct SolarSystem: View {
    @Environment(AppModel.self) private var model

    var body: some View {
        ZStack {
            Sun(
                scale: model.solarSunScale,
                position: model.solarSunPosition
            )

            Starfield()
        }
    }
}
