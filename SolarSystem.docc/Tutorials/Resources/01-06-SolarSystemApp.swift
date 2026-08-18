import SwiftUI

@main
struct SolarSystemApp: App {

    @State private var model = AppModel()

    // The immersion style for the solar system module.
    @State private var solarImmersionStyle: ImmersionStyle = .full

    var body: some Scene {
        WindowGroup {
            Text("Solar System")
                .environment(model)
        }
        .windowStyle(.plain)

        ImmersiveSpace(id: model.immersiveSpaceID) {
            Text("The solar system will render here.")
                .environment(model)
        }
        .immersionStyle(selection: $solarImmersionStyle, in: .full)
    }
}
