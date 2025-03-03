//
//  SettingsView.swift
//  SitStandTimer
//
//  Created by ash on 2/8/25.
//

import LaunchAtLogin
import SwiftUI
import Luminare

struct GeneralSettingsView: View {
    @AppStorage("startTimerAtLaunch") private var startTimerAtLaunch = false
    @AppStorage("showWidgetAtLaunch") private var showWidgetAtLaunch = false
    @State var launchAtLogin = LaunchAtLogin.isEnabled
    
    var body: some View {
        List {
            LuminareSection("appOptionsLabel") {
                LuminareToggle("launchAtLoginLabel", isOn: $launchAtLogin)
                    .onChange(of: launchAtLogin) { newValue in
                        LaunchAtLogin.isEnabled = newValue
                    }
            }

            LuminareSection("atLaunchOptionsLabel") {
                LuminareToggle("startTimerAtLaunchLabel", isOn: $startTimerAtLaunch)
                LuminareToggle("showWidgetAtLaunchLabel", isOn: $showWidgetAtLaunch)
            }
        }
        .listStyle(.sidebar)
        .scrollContentBackground(.hidden)
    }
}

struct NotificationsSettingsView: View {
    @EnvironmentObject private var timerManager: TimerManager
    let availableSounds = ["Funk", "Ping", "Tink", "Glass", "Basso"]
    
    var body: some View {
        List {
            LuminareSection("notificationsSettings") {
                // Sound Picker
                Picker("alertSoundSettingLabel", selection: $timerManager.selectedSound) {
                    ForEach(availableSounds, id: \.self) { sound in
                        Text(sound).tag(sound)
                    }
                }
                .padding(8)
                .onChange(of: timerManager.selectedSound) { _ in
                    timerManager.playSound()
                }
                
                // Notification Type Picker
                Picker("Notification Type", selection: $timerManager.notificationType) {
                    ForEach(NotificationType.allCases, id: \.self) { type in
                        Text(type.localizedString)
                            .tag(type)
                    }
                }
                .padding(8)
                .onChange(of: timerManager.notificationType) { newValue in
                    // Update the pause notch style whenever the notification type changes
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) { // Wait 2 seconds for the setted HUD to show
                        timerManager.handlePauseNotch(action: .auto)
                    }
                }
            }
        }
        .listStyle(.sidebar)
        .scrollContentBackground(.hidden)
    }
}
