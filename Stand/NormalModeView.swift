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
        LuminareDividedStack {
            if showSidebar {
                SidebarView(sittingTime: $sittingTime, standingTime: $standingTime)
                    .padding(.top, 2)
            }

            DetailView()
                .toolbar {
                    ToolbarItem(placement: .navigation) {
                        Button(action: { showSidebar.toggle() }) {
                            Label("sidebarToggleLabel", systemImage: "sidebar.squares.left")
                        }
                    }
                }
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .padding(4)
                        .ignoresSafeArea()
                        .frame(
                            minWidth: nil,
                            maxWidth: .infinity,
                            minHeight: nil,
                            maxHeight: .infinity
                        )
                        .foregroundStyle(timerManager.currentInterval.color.opacity(0.2))
                )
                .layoutPriority(1)
        }
        .frame(minWidth: showSidebar ? 635 : 450)
        
        .background(
            VisualEffectView(
                material: .menu,
                blendingMode: .behindWindow
            )
            .ignoresSafeArea()
        )
        .onAppear {
            timerManager.initializeWithStoredTimes(
                sitting: sittingTime,
                standing: standingTime
            )
            
            if let window = NSApplication.shared.windows.first {
                window.titlebarAppearsTransparent = true
                window.isOpaque = false
                window.backgroundColor = .clear // Set the background color to clear
                
                window.styleMask.insert(.fullSizeContentView)
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: NSWindow.didExitFullScreenNotification)) { _ in
            if let window = NSApplication.shared.windows.first {
                window.titlebarAppearsTransparent = true
                window.isOpaque = false
                window.backgroundColor = .clear // Set the background color to clear
                
                window.styleMask.insert(.fullSizeContentView)
            }
        }
    }
}

// -MARK: Sidebar
struct SidebarView: View {
    @Binding var sittingTime: Double
    @Binding var standingTime: Double
    @EnvironmentObject private var timerManager: TimerManager
    let availableSounds = ["Funk", "Ping", "Tink", "Glass", "Basso"]
    @State var showStats = false
    @AppStorage("showOccasionalReminders") private var showOccasionalReminders = true
    
    var body: some View {
        List {
#if DEBUG
            LuminareSection("DEBUG") { // Debug tools
                LuminareToggle("showOccasionalRemindersLabel", isOn: $showOccasionalReminders)
                
                Button(action: {
                    AboutWindowController.shared.showAboutView(timerManager: timerManager)
                    UpdateWindowController.shared.showUpdateView()
                    WelcomeWindowController.shared.showWelcomeView(timerManager: timerManager)
                    SettingsWindowController.shared.showSettingsView()
                }) {
                    Label("Show all windows", systemImage: "macwindow.on.rectangle")
                }

                Button("Test Notification") {
                    var testNotification = AdaptableNotificationType(
                        style: timerManager.notificationType,
                        title: "Test Reminder",
                        description: "This is a debug reminder test.",
                        image: "bell",
                        iconColor: .blue
                    )
                    testNotification.show(for: 3)
                }
            }
#endif
            
            LuminareSection {
                Button(action: {
                    timerManager.toggleFloatingWindow()
                }) {
                    Label("toggleWidgetLabel", systemImage: "widget.small")
                }
                
                Button(action: { showStats.toggle() }) {
                    Label("showStatsLabel", systemImage: "chart.bar")
                }
            }
            
            LuminareSection("intervalsLabel") {
                LuminareValueAdjuster(
                    "sittingTimeLabel",
                    value: $sittingTime,
                    sliderRange: 5...60,
                    suffix: "minutesAbbr"
                )
                LuminareValueAdjuster(
                    "standingTimeLabel",
                    value: $standingTime,
                    sliderRange: 5...60,
                    suffix: "minutesAbbr"
                )
            }
        }
        .buttonStyle(LuminareButtonStyle())
        .luminareModal(isPresented: $showStats, closeOnDefocus: true) {
            StatsView(showStats: $showStats)
                .environmentObject(timerManager)
        }
        .listStyle(.sidebar)
        .scrollContentBackground(.hidden)
        .frame(minWidth: 225)
    }
}

// -MARK: Detail (timer)
struct DetailView: View {
    @EnvironmentObject private var timerManager: TimerManager
    @State private var currentChallenge: Challenge = challenges.randomElement()!
    
    var body: some View {
        VStack(spacing: 20) {
            HStack(spacing: 15) {
                Image(systemName: timerManager.currentInterval.systemImage)
                    .font(.largeTitle)
                Text(timerManager.currentInterval.localizedString)
                    .font(.title)
            }
            .foregroundStyle(.secondary)

            Text(timeString(from: timerManager.remainingTime))
                .animation(
                    .easeInOut(duration: 0.1),
                    value: timerManager.remainingTime
                )
                .font(.system(size: 48, design: .monospaced))
            
            ControlButtons()
                .environmentObject(timerManager)
            
            ChallengeCard()
                .padding(.horizontal)
                .padding(.top, 20)

        }
        .navigationTitle(NSLocalizedString("appName", comment: "App name for main content title"))
        .toolbar {
            ToolbarItem(placement: .automatic) {
                Button(action: {
                    AboutWindowController.shared.showAboutView(timerManager: timerManager)
                }) {
                    Label("aboutMenuLabel", systemImage: "info.circle")
                }
            }
            
            if timerManager.isPaused {
                ToolbarItem(placement: .automatic) {
                    Button(action: {
                        if timerManager.isPauseNotchVisible {
                            timerManager.handlePauseNotch(action: .hide)
                        } else {
                            timerManager.handlePauseNotch(action: .show)
                        }
                    }) {
                        Label(
                            timerManager.isPauseNotchVisible ?
                                "hideNotchLabel" :
                                "showNotchLabel",
                            systemImage: timerManager.isPauseNotchVisible ?
                                "bell.badge.slash.fill" :
                                "bell.badge.fill"
                        )
                    }
                }
            }
        }
        .frame(minWidth: 375, idealWidth: nil, maxWidth: .infinity, minHeight: 375, idealHeight: nil, maxHeight: .infinity)
    }
    
    private func timeString(from timeInterval: TimeInterval) -> String {
        let minutes = Int(timeInterval) / 60
        let seconds = Int(timeInterval) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}

// -MARK: Stats
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
                    Text(
                        formatTime(minutes:
                            timerManager.timeHistory.standingMinutes +
                            timerManager.timeHistory.sittingMinutes
                        )
                    )
                    .font(.system(.title, design: .monospaced))
                }
                
                VStack(spacing: 4) {
                    HStack {
                        Image(systemName: "figure.seated.side.right")
                            .frame(width: 20, height: 20)
                        Text(NSLocalizedString("sittingLabel", comment: "Sitting label"))
                    }
                    .foregroundStyle(.indigo)
                    Text(formatTime(minutes:
                            timerManager.timeHistory.sittingMinutes
                       )
                    )
                    .font(.system(.title, design: .monospaced))
                }
                
                VStack(spacing: 4) {
                    HStack {
                        Image(systemName: "figure.stand")
                            .frame(width: 20, height: 20)
                        Text(NSLocalizedString("standingLabel", comment: "Standing label"))
                    }
                    .foregroundStyle(.yellow)
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

// -MARK: Misc
#Preview {
//    StatsView()
    NormalModeView(sittingTime: .constant(30), standingTime: .constant(30))
        .environmentObject(TimerManager())
}
