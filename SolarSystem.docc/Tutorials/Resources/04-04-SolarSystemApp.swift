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

    var body: some SwiftUI.Scene {
        WindowGroup {
            SwitchWindows()
        }
        .windowStyle(.plain)
     }
}
