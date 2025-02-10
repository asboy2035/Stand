//
//  SettingsView.swift
//  SitStandTimer
//
//  Created by ash on 2/8/25.
//

import LaunchAtLogin
import SwiftUI
import Luminare

struct SettingsView: View {
    @Binding var sittingTime: Double
    @Binding var standingTime: Double
    @EnvironmentObject private var timerManager: TimerManager
    let availableSounds = ["Funk", "Ping", "Tink", "Glass", "Basso"]
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
        .listStyle(.sidebar)
        .scrollContentBackground(.hidden)
        .frame(width: 350, height: 300)
        .background(VisualEffectView(material: .sidebar, blendingMode: .behindWindow).edgesIgnoringSafeArea(.all))
    }
}
