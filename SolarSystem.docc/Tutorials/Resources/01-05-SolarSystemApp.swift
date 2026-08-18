import SwiftUI

@main
struct SolarSystemApp: App {

    @State private var model = AppModel()

    var body: some Scene {
        WindowGroup {
            Text("Solar System")
                .environment(model)
        }
    }
}
