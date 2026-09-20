//
//  SolarSystem.swift
//  SolarSystem
//
//  Created by Saerom on 8/13/26.
//
/// 태양 + 행성들 ZStack으로 쌓는곳


/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
The model content for the solar system module.
*/

import SwiftUI
import RealityKit

/// The model content for the solar system module.
struct SolarSystem: View {
    @Environment(AppModel.self) private var model

    /// The shared anchor that a focused planet and its info panel animate
    /// into. Created once by `FocusStage` and handed to every `Planet`.
    @State private var focusStage: Entity?

    var body: some View {
        ZStack {
            Starfield()

            Sun(
                scale: model.solarSunScale,
                position: model.solarSunPosition,
                isHidden: model.focusedPlanetID != nil
            )

            FocusStage(stageEntity: $focusStage, isActive: model.focusedPlanetID != nil)

            ForEach(model.solarPlanets, id: \.id) { configuration in
                Planet(configuration: configuration, focusStage: focusStage)
            }
        }
        .onAppear {
            model.immersiveSpaceState = .open
            model.isShowingSolar = true
            var announcement = AttributedString(localized: "Entered the immersive star filled solar system!",
                                                comment: "Accessibility message describing the model shown.")
            announcement.accessibilitySpeechAnnouncementPriority = .high
            AccessibilityNotification.Announcement(announcement).post()
        }
        .task {
            await model.headTracker.start()
        }
        .onDisappear {
            model.headTracker.stop()
            model.immersiveSpaceState = .closed
            model.isShowingSolar = false
        }
    }
}
