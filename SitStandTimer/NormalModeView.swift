//
//  NormalModeView.swift
//  SitStandTimer
//
//  Created by ash on 1/18/25.
//

import SwiftUI
import LaunchAtLogin
import Luminare

struct NormalModeView: View {
    @EnvironmentObject private var timerManager: TimerManager
    @State var showSidebar = true
    @Binding var sittingTime: Double
    @Binding var standingTime: Double
    
    var body: some View {
        HStack {
            if showSidebar {
                SidebarView(sittingTime: $sittingTime, standingTime: $standingTime)
                    .padding(.top, 2)
            }
            DetailView()
                .toolbar {
                    ToolbarItem(placement: .navigation) {
                        Button(action: { showSidebar.toggle() }) {                            Label("sidebarToggleLabel", systemImage: "sidebar.squares.left")
                        }
                    }
                }
                .layoutPriority(1)
        }
        .frame(minWidth: showSidebar ? 725 : 500)
        
        .background(VisualEffectView(material: .sidebar, blendingMode: .behindWindow).edgesIgnoringSafeArea(.all))
        .onAppear {
            timerManager.initializeWithStoredTimes(sitting: sittingTime, standing: standingTime)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                if let window = NSApplication.shared.windows.first {
                    window.titlebarAppearsTransparent = true
                    window.backgroundColor = .clear
                }
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: NSWindow.didExitFullScreenNotification)) { _ in
            if let window = NSApplication.shared.windows.first {
                window.titlebarAppearsTransparent = true
                window.backgroundColor = .clear
            }
        }
    }
}

struct SidebarView: View {
    @Binding var sittingTime: Double
    @Binding var standingTime: Double
    @EnvironmentObject private var timerManager: TimerManager
    let availableSounds = ["Funk", "Ping", "Tink", "Glass", "Basso"]
    @AppStorage("startTimerAtLaunch") private var startTimerAtLaunch = false
    @AppStorage("showWidgetAtLaunch") private var showWidgetAtLaunch = false
    @State var launchAtLogin = LaunchAtLogin.isEnabled
    @State var showStats = false
    
    var body: some View {
        List {
            LuminareSection {
                Button(action: { showStats.toggle() }) {
                    Text("showStatsLabel")
                }
                .buttonStyle(LuminareButtonStyle())
            }
            Divider()
            
            LuminareSection("intervalsLabel") {
                LuminareValueAdjuster("sittingTimeLabel", value: $sittingTime, sliderRange: 5...60, suffix: "minutesAbbr")
                LuminareValueAdjuster("standingTimeLabel", value: $standingTime, sliderRange: 5...60, suffix: "minutesAbbr")
            }
            
            LuminareSection("appOptionsLabel") {
                LuminareToggle("launchAtLoginLabel", isOn: $launchAtLogin)
                    .onChange(of: launchAtLogin) { newValue in
                        LaunchAtLogin.isEnabled = newValue
                    }
                
                Picker("alertSoundSettingLabel", selection: $timerManager.selectedSound) {
                    ForEach(availableSounds, id: \.self) { sound in
                        Text(sound).tag(sound)
                    }
                }
                .padding(8)
                .pickerStyle(MenuPickerStyle())
                .onChange(of: timerManager.selectedSound) { _ in
                    timerManager.playSound()
                }
            }
                
            LuminareSection("atLaunchOptionsLabel") {
                LuminareToggle("startTimerAtLaunchLabel", isOn: $startTimerAtLaunch)
                LuminareToggle("showWidgetAtLaunchLabel", isOn: $showWidgetAtLaunch)
            }
        }
        .luminareModal(isPresented: $showStats) {
            StatsView(showStats: $showStats)
                .environmentObject(timerManager)
        }
        .listStyle(.sidebar)
        .scrollContentBackground(.hidden)
        .frame(minWidth: 250)
    }
}

struct DetailView: View {
    @EnvironmentObject private var timerManager: TimerManager
    @State private var currentChallenge: Challenge = challenges.randomElement()!
    
    var body: some View {
        VStack(spacing: 20) {
            HStack(spacing: 15) {
                Image(systemName: timerManager.currentInterval == .sitting ? "figure.seated.side.right" : "figure.stand")
                    .font(.largeTitle)
                    .foregroundColor(timerManager.currentInterval == .sitting ? .indigo : .yellow)
                Text(timerManager.currentInterval == .sitting ? "sittingLabel" : "standingLabel")
                    .font(.title)
                    .foregroundColor(timerManager.currentInterval == .sitting ? .indigo : .yellow)
            }

            Text(timeString(from: timerManager.remainingTime))
                .animation(.easeInOut(duration: 0.1), value: timerManager.remainingTime)
                .font(.system(size: 48, design: .monospaced))
            
            // Control Buttons
            HStack(spacing: 15) {
                Button(action: {
                    timerManager.resetTimer()
                }) {
                    Image(systemName: "arrow.clockwise")
                        .frame(width: 10, height: 25)
                }
                
                Button(action: {
                    if timerManager.isRunning {
                        timerManager.pauseTimer()
                    } else {
                        timerManager.resumeTimer()
                    }
                }) {
                    Image(systemName: timerManager.isRunning ? "pause.fill" : "play.fill")
                        .frame(width: 20, height: 35)
                }
                .frame(height: 45)
                
                Button(action: {
                    timerManager.switchInterval()
                }) {
                    Image(systemName: "repeat")
                        .frame(width: 10, height: 25)
                }
            }
            .frame(width: 100, height: 35)
            .buttonStyle(LuminareCompactButtonStyle())
            
            ChallengeCard()
            .padding(.top, 20)

        }
        .navigationTitle(NSLocalizedString("appName", comment: "App name for main content title"))
        .toolbar {
            ToolbarItem(placement: .automatic) {
                Button(action: {
                    timerManager.toggleFloatingWindow()
                }) {
                    Label("toggleWidgetLabel", systemImage: "widget.small")
                }
            }
            ToolbarItem(placement: .automatic) {
                Button(action: {
                    AboutWindowController.shared.showAboutView()
                }) {
                    Label("aboutMenuLabel", systemImage: "info.circle")
                }
            }
            
            if timerManager.isPaused {
                ToolbarItem(placement: .automatic) {
                    Button(action: {
                        if timerManager.isPauseNotchVisible {
                            timerManager.hidePauseNotch()
                        } else {
                            timerManager.showPauseNotch()
                        }
                    }) {
                        Label(timerManager.isPauseNotchVisible ? "hideNotchLabel" : "showNotchLabel", systemImage: timerManager.isPauseNotchVisible ? "bell.badge.slash.fill" : "bell.badge.fill")
                    }
                }
            }
        }
        .frame(minWidth: 475, idealWidth: nil, maxWidth: .infinity, minHeight: 450, idealHeight: nil, maxHeight: .infinity)
    }
    
    private func timeString(from timeInterval: TimeInterval) -> String {
        let minutes = Int(timeInterval) / 60
        let seconds = Int(timeInterval) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}

struct StatsView: View {
    @EnvironmentObject private var timerManager: TimerManager
    @Binding var showStats: Bool  // Add the binding to control the modal
    
    private func formatTime(minutes: Int) -> String {
        let hours = minutes / 60
        let remainingMinutes = minutes % 60
        return "\(hours)h \(remainingMinutes)m"
    }
    
    var body: some View {
        VStack {
            LuminareSection {
                VStack(spacing: 4) {
                    HStack {
                        Image(systemName: "clock.fill")
                            .frame(width: 20, height: 20)
                        Text(NSLocalizedString("totalLabel", comment: "Total label"))
                    }
                    .foregroundStyle(
                        LinearGradient(
                            gradient: Gradient(colors: [.yellow, .indigo]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    Text(formatTime(minutes: timerManager.timeHistory.standingMinutes + timerManager.timeHistory.sittingMinutes))
                        .font(.system(.title, design: .monospaced))
                }
                
                VStack(spacing: 4) {
                    HStack {
                        Image(systemName: "figure.seated.side.right")
                            .frame(width: 20, height: 20)
                        Text(NSLocalizedString("sittingLabel", comment: "Sitting label"))
                    }
                    .foregroundColor(.indigo)
                    Text(formatTime(minutes: timerManager.timeHistory.sittingMinutes))
                        .font(.system(.title, design: .monospaced))
                }
                
                VStack(spacing: 4) {
                    HStack {
                        Image(systemName: "figure.stand")
                            .frame(width: 20, height: 20)
                        Text(NSLocalizedString("standingLabel", comment: "Standing label"))
                    }
                    .foregroundColor(.yellow)
                    Text(formatTime(minutes: timerManager.timeHistory.standingMinutes))
                        .font(.system(.title, design: .monospaced))
                }
            }
            
            // Close button to dismiss the modal
            Button(action: {
                showStats = false
            }) {
                Text("closeLabel")
            }
            .buttonStyle(LuminareCompactButtonStyle())
        }
        .frame(minWidth: 150)
    }
}

#Preview {
//    StatsView()
    NormalModeView(sittingTime: .constant(30), standingTime: .constant(30))
        .environmentObject(TimerManager())
}
