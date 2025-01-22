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
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @ObservedObject private var timerManager = TimerManager()
    
    var body: some Scene {
        WindowGroup("appName") {
            ContentView()
                .environmentObject(timerManager)
        }
        .commands {
            CommandGroup(replacing: .appInfo) {
                Button("aboutMenuLabel") {
                    showingAbout.toggle()
                }
            }
        }
        
        MenuBarExtra("appName", systemImage: timerManager.currentInterval == .sitting ? "figure.seated.side.right" : "figure.stand") {
            VStack {
                Text(timerManager.currentInterval == .sitting ? "sittingLabel" : "standingLabel")
                    .font(.headline)
                    .padding(.bottom, 5)
                
                Text(formatTime(timerManager.remainingTime))
                    .font(.system(.body, design: .monospaced))
                    .padding(.bottom, 10)
                
                Button(timerManager.isRunning ? "Pause Timer" : "Resume Timer") {
                    toggleTimer()
                }
                
                Button("Quit") {
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
