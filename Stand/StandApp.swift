//
//  SitStandTimerApp.swift
//  SitStandTimer
//
//  Created by ash on 12/10/24.
//

import DynamicNotchKit
import SwiftUI
import Luminare

@main
struct StandApp: App {
    @ObservedObject private var timerManager = TimerManager()
    @AppStorage("sittingTime") private var sittingTime: Double = 30
    @AppStorage("standingTime") private var standingTime: Double = 10
    @AppStorage("showWelcome") private var showWelcome: Bool = true
    @State var isSettingsPresented: Bool = false
    
    var body: some Scene {
        Window("appName", id: "Main") {
            ContentView()
                .environmentObject(timerManager)
        }
        .commands {
            CommandGroup(replacing: .appInfo) {
                Button("aboutMenuLabel") {
                    AboutWindowController.shared.showAboutView(timerManager: timerManager)
                }
            }
            CommandGroup(replacing: .appSettings) {
                Button("Settings...") {
                    SettingsWindowController.shared.showSettingsView()
                }
                .keyboardShortcut(",", modifiers: .command)  // ⌘,
            }
        }
        Window("Settings", id: "settings") {
            SettingsView(model: SettingsModel())
        }
        
        // -MARK: Menu bar extra
        MenuBarExtra("appName", systemImage: timerManager.currentInterval == .sitting ? "figure.seated.side.right" : "figure.stand") {
            VStack {
                Spacer()
                Text(timerManager.currentInterval == .sitting ? "sittingLabel" : "standingLabel")
                    .font(.title)
                    .foregroundStyle(.secondary)
                Text(formatTime(timerManager.remainingTime))
                    .font(.system(.title2, design: .monospaced))
                Spacer()
                
                HStack(spacing: 16) { // Minimal Controls
                    Button(action: {
                        timerManager.resetTimer()
                    }) {
                        Image(systemName: "arrow.clockwise")
                    }
                    
                    Button(action: {
                        if timerManager.isRunning {
                            timerManager.pauseTimer()
                        } else {
                            timerManager.resumeTimer()
                        }
                    }) {
                        Image(systemName: timerManager.isRunning ? "pause.fill" : "play.fill")
                    }
                    
                    Button(action: {
                        timerManager.switchInterval()
                    }) {
                        Image(systemName: "repeat")
                    }
                }
                .foregroundStyle(.foreground)
                .imageScale(.large)
                .buttonStyle(.borderless)
                
                Spacer()
                Button(action: { NSApplication.shared.terminate(nil) }) {
                    Label("quitApp", systemImage: "power")
                }
                .buttonStyle(LuminareCompactButtonStyle())
                .frame(height: 30)
            }
            .frame(width: 150, height: 150)
            .padding()
            .background(timerManager.currentInterval == .sitting ? .indigo.opacity(0.2) : .yellow.opacity(0.2))
        }
        .menuBarExtraStyle(.window)
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
