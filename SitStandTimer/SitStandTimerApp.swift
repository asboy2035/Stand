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
    @ObservedObject private var timerManager = TimerManager()
    
    var body: some Scene {
        WindowGroup("appName") {
            ContentView()
                .environmentObject(timerManager)
                .onAppear {
                    if let window = NSApplication.shared.windows.first {
                        configureWindow(window)
                    }
                }
        }
        .commands {
            CommandGroup(replacing: .appInfo) {
                Button("aboutMenuLabel") {
                    AboutWindowController.shared.showAboutView()
                }
            }
        }
        
        MenuBarExtra("appName", systemImage: timerManager.currentInterval == .sitting ? "figure.seated.side.right" : "figure.stand") {
            VStack {
                Text(timerManager.currentInterval == .sitting ? "sittingLabel" : "standingLabel")
                    .font(.title2)
                
                Text(formatTime(timerManager.remainingTime))
                    .font(.system(.body, design: .monospaced))
                
                Button(timerManager.isRunning ? "pauseTimerLabel" : "resumeTimerLabel") {
                    toggleTimer()
                }
                
                Divider()
                Button("aboutMenuLabel") {
                    AboutWindowController.shared.showAboutView()
                }
                Button("quitApp") {
                    NSApp.terminate(nil)
                }
            }
            .padding()
        }
    }
    
    private func formatTime(_ time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    private func toggleTimer() {
        if timerManager.isRunning {
            timerManager.pauseTimer()
        } else {
            timerManager.resumeTimer()
        }
    }
}

func configureWindow(_ window: NSWindow) {
    window.titlebarAppearsTransparent = true  // Makes the title bar blend in
    window.isMovableByWindowBackground = true // Allows dragging from any part
    window.backgroundColor = .clear           // Makes it transparent
    window.styleMask.insert(.fullSizeContentView) // Extends content into title bar
}
