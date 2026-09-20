import SwiftUI

@main
struct SolarSystemApp: App {

    var body: some SwiftUI.Scene {
        WindowGroup {
            SwitchWindows()
        }
        .windowStyle(.plain)
    }
}
