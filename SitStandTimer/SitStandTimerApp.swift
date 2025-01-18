//
//  SitStandTimerApp.swift
//  SitStandTimer
//
//  Created by ash on 12/10/24.
//

import DynamicNotchKit
import SwiftUI

@main
struct SitStandTimerApp: App {
    @State private var showingAbout = false
    
    var body: some Scene {
        WindowGroup("appName") {
            ContentView()
        }
        .commands {
            CommandGroup(replacing: .appInfo) {
                Button("aboutMenuLabel") {
                    AboutWindowController.shared.showAboutView()
                }
            }
        }
    }
}
