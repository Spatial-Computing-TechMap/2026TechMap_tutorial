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

    var body: some SwiftUI.Scene {
        WindowGroup {
            SwitchWindows()
                .environment(model)
        }
        .windowStyle(.plain)
     }
}
