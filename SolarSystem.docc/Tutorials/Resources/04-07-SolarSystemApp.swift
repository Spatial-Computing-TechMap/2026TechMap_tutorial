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

    init() {
        // Custom RealityKit systems must be registered once before they'll
        // run -- without this, RotationComponent/TraceComponent entities
        // never actually rotate or draw a trace, and Earth's day/night
        // shading never updates.
        RotationSystem.registerSystem()
        TraceSystem.registerSystem()
        SunPositionSystem.registerSystem()
    }

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
    