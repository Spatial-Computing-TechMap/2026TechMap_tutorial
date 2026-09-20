//
//  SolarSystemApp.swift
//  SolarSystem
//
//  Created by Saerom on 8/12/26.
//

import RealityKit
import SwiftUI
import WorldAssets

@main
struct SolarSystemApp: App {

    @State private var model = AppModel()

    // The immersion styles for different modules.
    @State private var solarImmersionStyle: ImmersionStyle = .full

    var body: some SwiftUI.Scene {
        WindowGroup {
            SwitchWindows()
                .environment(model)
        }
        .windowStyle(.plain)
        
        ImmersiveSpace(id: model.immersiveSpaceID) {
            SolarSystem()
                .environment(model)
        }
        .immersionStyle(selection: $solarImmersionStyle, in: .full)
     }
}
    