//
//  ContentView.swift
//  SitStandTimer
//
//  Created by ash on 12/10/24.
//

import SwiftUI
import DynamicNotchKit

struct ContentView: View {
    @EnvironmentObject private var timerManager: TimerManager
    @AppStorage("sittingTime") private var sittingTime: Double = 30
    @AppStorage("standingTime") private var standingTime: Double = 10
    @AppStorage("showWelcome") private var showWelcome: Bool = true
    @State private var isFullScreen = false
    @State private var currentTime = Date()

    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        HStack {
            if isFullScreen {
                IdleModeView(currentTime: currentTime)
                        .environmentObject(timerManager)
            } else {
                NormalModeView(sittingTime: $sittingTime, standingTime: $standingTime)
                        .environmentObject(timerManager)
            }
        }
        .onAppear() {
            if showWelcome {
                WelcomeWindowController.shared.showWelcomeView()
            }
        }
        .onReceive(timer) { input in
            currentTime = input
        }
        .onReceive(NotificationCenter.default.publisher(for: NSWindow.willEnterFullScreenNotification)) { _ in
            isFullScreen = true
        }
        .onReceive(NotificationCenter.default.publisher(for: NSWindow.willExitFullScreenNotification)) { _ in
            isFullScreen = false
        }
    }
}

struct VisualEffectView: NSViewRepresentable {
    let material: NSVisualEffectView.Material
    let blendingMode: NSVisualEffectView.BlendingMode
    
    func makeNSView(context: Context) -> NSVisualEffectView {
        let visualEffectView = NSVisualEffectView()
        visualEffectView.material = material
        visualEffectView.blendingMode = blendingMode
        visualEffectView.state = .active
        return visualEffectView
    }
    
    func updateNSView(_ visualEffectView: NSVisualEffectView, context: Context) {
        visualEffectView.material = material
        visualEffectView.blendingMode = blendingMode
    }
}

