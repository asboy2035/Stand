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
                .frame(minWidth: 225, maxWidth: 250)
        } detail: {
            DetailView()
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
                    }
                    
                    VStack(alignment: .leading) {
                        Text(NSLocalizedString("standingTimeLabel", comment: "Standing time label"))
                        Slider(value: $standingTime, in: 5...60, step: 5)
                            .onChange(of: standingTime) { newValue in
                                timerManager.updateIntervalTime(type: .standing, time: newValue)
                            }
                        Text("\(Int(standingTime)) \(NSLocalizedString("minutesAbbr", comment: "Minutes abbreviation"))")
                    }
                }
                .padding(8)
                .background(.foreground.opacity(0.1))
                .mask(RoundedRectangle(cornerRadius: 10))
                .overlay(RoundedRectangle(cornerRadius: 10).stroke(.foreground.opacity(0.2), lineWidth: 1))
            }
                
                
            Section(header: Text(NSLocalizedString("optionsLabel", comment: "Options header in sidebar"))) {
                VStack(alignment: .leading) {
                    Picker("alertSoundSettingLabel", selection: $timerManager.selectedSound) {
                        ForEach(availableSounds, id: \.self) { sound in
                            Text(sound).tag(sound)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                    .onChange(of: timerManager.selectedSound) { _ in
                        timerManager.playSound()
                    }
                    LaunchAtLogin.Toggle("\(NSLocalizedString("launchAtLoginLabel", comment: "Launch at login label"))")
                }
                .padding(8)
                .background(.foreground.opacity(0.1))
                .mask(RoundedRectangle(cornerRadius: 10))
                .overlay(RoundedRectangle(cornerRadius: 10).stroke(.foreground.opacity(0.2), lineWidth: 1))
            }
        }
        .background(VisualEffectView(material: .sidebar, blendingMode: .behindWindow).edgesIgnoringSafeArea(.all))
        .frame(minWidth: 225, maxWidth: 250)
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
            .padding(.top, 25)

        }
        .navigationTitle(NSLocalizedString("appName", comment: "App name for main content title"))
        .toolbar {
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
        .frame(minWidth: 500, idealWidth: nil, maxWidth: .infinity, minHeight: 350, idealHeight: nil, maxHeight: .infinity)
        .background(VisualEffectView(material: .headerView, blendingMode: .behindWindow).edgesIgnoringSafeArea(.all))
    }
    
    private func timeString(from timeInterval: TimeInterval) -> String {
        let minutes = Int(timeInterval) / 60
        let seconds = Int(timeInterval) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}
