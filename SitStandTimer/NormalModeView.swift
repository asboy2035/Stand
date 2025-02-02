//
//  NormalModeView.swift
//  SitStandTimer
//
//  Created by ash on 1/18/25.
//

import SwiftUI
import LaunchAtLogin

struct NormalModeView: View {
    @EnvironmentObject private var timerManager: TimerManager
    @Binding var sittingTime: Double
    @Binding var standingTime: Double
    
    var body: some View {
        NavigationSplitView {
            SidebarView(sittingTime: $sittingTime, standingTime: $standingTime)
        } content: {
            DetailView()
                .layoutPriority(1)
        } detail: {
            RightSidebarView()
        }
        .onAppear {
            timerManager.initializeWithStoredTimes(sitting: sittingTime, standing: standingTime)
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
    
    var body: some View {
        List {
            Section(header: Text(NSLocalizedString("intervalsLabel", comment: "Intervals header in sidebar"))) {
                VStack(alignment: .leading, spacing: 10) {
                    VStack(alignment: .leading) {
                        Text(NSLocalizedString("sittingTimeLabel", comment: "Sitting time label"))
                        Slider(value: $sittingTime, in: 5...60, step: 5)
                            .onChange(of: sittingTime) { newValue in
                                timerManager.updateIntervalTime(type: .sitting, time: newValue)
                            }
                        Text("\(Int(sittingTime)) \(NSLocalizedString("minutesAbbr", comment: "Minutes abbreviation"))")
                            .font(.caption)
                    }
                    
                    VStack(alignment: .leading) {
                        Text(NSLocalizedString("standingTimeLabel", comment: "Standing time label"))
                        Slider(value: $standingTime, in: 5...60, step: 5)
                            .onChange(of: standingTime) { newValue in
                                timerManager.updateIntervalTime(type: .standing, time: newValue)
                            }
                        Text("\(Int(standingTime)) \(NSLocalizedString("minutesAbbr", comment: "Minutes abbreviation"))")
                            .font(.caption)
                    }
                }
            }
            
            Section(header: Text(NSLocalizedString("appOptionsLabel", comment: "App options header in sidebar"))) {
                LaunchAtLogin.Toggle("\(NSLocalizedString("launchAtLoginLabel", comment: "Launch at login label"))")
                
                Picker("alertSoundSettingLabel", selection: $timerManager.selectedSound) {
                    ForEach(availableSounds, id: \.self) { sound in
                        Text(sound).tag(sound)
                    }
                }
                .pickerStyle(MenuPickerStyle())
                .onChange(of: timerManager.selectedSound) { _ in
                    timerManager.playSound()
                }
            }
                
                
            Section(header: Text(NSLocalizedString("atLaunchOptionsLabel", comment: "At launch header in sidebar"))) {
                Toggle(isOn: $startTimerAtLaunch) {
                    Text(NSLocalizedString("startTimerAtLaunchLabel", comment: "Start timer at launch label"))
                }
                
                Toggle(isOn: $showWidgetAtLaunch) {
                    Text(NSLocalizedString("showWidgetAtLaunchLabel", comment: "Show widget at launch label"))
                }
            }
        }
        .frame(minWidth: 230)
    }
}

struct DetailView: View {
    @EnvironmentObject private var timerManager: TimerManager
    @State private var currentChallenge: Challenge = challenges.randomElement()!
    
    var body: some View {
        VStack(spacing: 15) {
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
                
                Button(action: {
                    timerManager.switchInterval()
                }) {
                    Image(systemName: "repeat")
                        .frame(width: 10, height: 25)
                }
            }
            
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
        .frame(minWidth: 500, idealWidth: nil, maxWidth: .infinity, minHeight: 470, idealHeight: nil, maxHeight: .infinity)
        .background(VisualEffectView(material: .headerView, blendingMode: .behindWindow).edgesIgnoringSafeArea(.all))
    }
    
    private func timeString(from timeInterval: TimeInterval) -> String {
        let minutes = Int(timeInterval) / 60
        let seconds = Int(timeInterval) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}

struct RightSidebarView: View {
    @EnvironmentObject private var timerManager: TimerManager
    
    private func formatTime(minutes: Int) -> String {
        let hours = minutes / 60
        let remainingMinutes = minutes % 60
        return "\(hours)h \(remainingMinutes)m"
    }
    
    var body: some View {
        List {
            Section(header: Text(NSLocalizedString("totalTimeLabel", comment: "Total time header"))) {
                VStack(alignment: .leading, spacing: 16) {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Image(systemName: "clock.fill")
                                .frame(width: 10, height: 10)
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
                    .padding(.bottom, 16)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Image(systemName: "figure.seated.side.right")
                                .frame(width: 10, height: 10)
                            Text(NSLocalizedString("sittingLabel", comment: "Sitting label"))
                        }
                        .foregroundColor(.indigo)
                        Text(formatTime(minutes: timerManager.timeHistory.sittingMinutes))
                            .font(.system(.title, design: .monospaced))
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Image(systemName: "figure.stand")
                                .frame(width: 10, height: 10)
                            Text(NSLocalizedString("standingLabel", comment: "Standing label"))
                        }
                        .foregroundColor(.yellow)
                        Text(formatTime(minutes: timerManager.timeHistory.standingMinutes))
                            .font(.system(.title, design: .monospaced))
                    }
                }
            }
        }
        .listStyle(.sidebar)
        .frame(minWidth: 230)
    }
}

#Preview {
    NormalModeView(sittingTime: .constant(30), standingTime: .constant(30))
        .environmentObject(TimerManager())
}
