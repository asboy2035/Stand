//
//  SettingsView.swift
//  SitStandTimer
//
//  Created by ash on 2/8/25.
//

import LaunchAtLogin
import SwiftUI
import Luminare

class SettingsWindowController: NSObject {
    private var window: NSWindow?

    static let shared = SettingsWindowController()
    
    private override init() {
        super.init()
    }

    func showSettingsView() {
        if window == nil {
            let settingsView = SettingsView(model: SettingsModel())
            let hostingController = NSHostingController(rootView: settingsView)

            let window = NSWindow(
                contentRect: NSRect(x: 0, y: 0, width: 1000, height: 450),
                styleMask: [.titled, .closable, .fullSizeContentView],
                backing: .buffered,
                defer: false
            )
            
            window.center()
            window.contentViewController = hostingController
            window.isReleasedWhenClosed = false
            window.titlebarAppearsTransparent = true
            window.isMovableByWindowBackground = true

            self.window = window
        }

        window?.makeKeyAndOrderFront(nil)
    }
}

// -MARK: Settings
class SettingsModel: ObservableObject {
    @Published var selection: Tab = .general
}

struct SettingsView: View {
    @StateObject var model: SettingsModel
    
    var body: some View {
        LuminareDividedStack {
            VStack {
                LuminareSidebar {
                    LuminareSidebarSection("generalSettings", selection: $model.selection, items: Tab.generalSection)
                    LuminareSidebarSection("aboutLabel", selection: $model.selection, items: Tab.aboutSection)
                    LuminareSidebarSection("moreLabel", selection: $model.selection, items: Tab.moreSection)
                }
                .padding(.top, 56)
            }
            .ignoresSafeArea()
            .frame(width: 200, height: 450, alignment: .top)
            
            LuminarePane {
                HStack {
                    model.selection.iconView()
                    
                    Text(model.selection.title)
                        .font(.title2)
                    
                    Spacer()
                }
            } content: {
                model.selection.view()
                    .padding()
                    .frame(minWidth: 500)
                    .frame(minHeight: 400, maxHeight: .infinity)
            }
        }
        .frame(minWidth: 750)
        .toolbar {
            ToolbarItem(placement: .automatic) {
                Button(action: {
                    if let url = URL(string: "https://asboy2035.pages.dev/apps/stand") {
                        NSWorkspace.shared.open(url)
                    }
                }) {
                    Label("websiteLabel", systemImage: "globe")
                }
            }
        }
        .background(
            VisualEffectView(
                material: .menu,
                blendingMode: .behindWindow
            ).ignoresSafeArea()
        )
    }
}

// -MARK: General settings
struct GeneralSettingsView: View {
    @AppStorage("startTimerAtLaunch") private var startTimerAtLaunch = false
    @AppStorage("showWidgetAtLaunch") private var showWidgetAtLaunch = false
    @State var launchAtLogin = LaunchAtLogin.isEnabled
    
    var body: some View {
        VStack {
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
            Spacer()
        }
    }
}

// -MARK: Notification settings
struct NotificationTypePickerData: Hashable, LuminarePickerData {
    var name: String
    let selectable: Bool = true
    
    static let all: [NotificationType] = [
        .banner,
        .hud
    ]
}

struct NotificationsSettingsView: View {
    @EnvironmentObject var timerManager: TimerManager
    @AppStorage("notificationType") private var notificationType: NotificationType = .banner
    @AppStorage("showOccasionalReminders") private var showOccasionalReminders = true
    let availableSounds = ["Funk", "Ping", "Tink", "Glass", "Basso"]
    
    var body: some View {
        VStack {
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
                HStack {
                    Text("Notification Type")
                        .padding(.leading, 8)
                    HStack(spacing: 4) {
                        Button(action: {
                            notificationType = .banner
                        }) {
                            Label("Banner", systemImage: "bell.badge.fill")
                        }
                        
                        Button(action: {
                            notificationType = .hud
                        }) {
                            Label("HUD", systemImage: "square.fill")
                        }
                    }
                    .frame(height: 35)
                    .buttonStyle(LuminareCompactButtonStyle())
                    .buttonStyle(.borderless)
                    .onChange(of: notificationType) { newValue in
                        timerManager.notificationType = newValue
                        var settedNoti = AdaptableNotificationType(
                            style: newValue,
                            title: NSLocalizedString("Notification style set!", comment: "Title for notification style set notification"),
                            description: NSLocalizedString("Notifications will now be in this style.", comment: "Description for notification style set notification"),
                            image: "heart.fill",
                            iconColor: .accentColor
                        )
                        settedNoti.show(for: 2)
                    }
                }
                
                LuminareToggle("showOccasionalRemindersLabel", isOn: $showOccasionalReminders)
            }
            Spacer()
        }
    }
}

// -MARK: Experiments
struct ExperimentsSettingsView: View {
    @AppStorage("usingNewColors") private var usingNewColors: Bool = false
    
    var body: some View {
        VStack {
            LuminareSection("experimentsLabel") {
                LuminareToggle("usingNewColors", isOn: $usingNewColors)
            }
            Spacer()
        }
    }
}
