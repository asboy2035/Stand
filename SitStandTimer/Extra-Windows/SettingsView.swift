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
        .navigationTitle("standSettingsTitle")
        .toolbar {
            ToolbarItem(placement: .principal) {
                Button(action: {
                    AboutWindowController.shared.showAboutView()
                }) {
                    Label("aboutMenuLabel", systemImage: "info.circle")
                }
            }
        }
        .listStyle(.sidebar)
        .scrollContentBackground(.hidden)
        .frame(width: 350)
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                if let window = NSApp.keyWindow {
                    window.titlebarAppearsTransparent = true
                    window.isOpaque = false
                    window.backgroundColor = .clear
                    window.styleMask.insert(.fullSizeContentView)
                }
            }
        }
        .background(VisualEffectView(material: .sidebar, blendingMode: .behindWindow).edgesIgnoringSafeArea(.all))
    }
}
