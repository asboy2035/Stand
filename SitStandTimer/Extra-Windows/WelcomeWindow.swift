//
//  WelcomeWindow.swift
//  SitStandTimer
//
//  Created by ash on 1/19/25.
//

import SwiftUI
import LaunchAtLogin
import Luminare
import DynamicNotchKit

// -MARK: Welcome controller
class WelcomeWindowController: NSObject {
    private var window: NSWindow?

    static let shared = WelcomeWindowController()
    
    private override init() {
        super.init()
    }
    
    func close() {
        window?.close()
    }

    func showWelcomeView(timerManager: TimerManager) {
        if window == nil {
            let welcomeView = WelcomeView()
                .environmentObject(timerManager)
            let hostingController = NSHostingController(rootView: welcomeView)

            let window = NSWindow(
                contentRect: NSRect(x: 0, y: 0, width: 400, height: 400),
                styleMask: [.fullSizeContentView],
                backing: .buffered,
                defer: false
            )
            
            window.center()
            window.contentViewController = hostingController
            window.isReleasedWhenClosed = false
            window.titlebarAppearsTransparent = true
            window.isMovableByWindowBackground = true
            window.backgroundColor = .clear

            self.window = window
        }

        window?.makeKeyAndOrderFront(nil)
    }
}

// -MARK: Welcome View
struct WelcomeView: View {
    @EnvironmentObject private var timerManager: TimerManager
    @AppStorage("showWelcome") var showWelcome: Bool = true
    @State private var currentSlideIndex = 0
    
    // Define slides
    private var slides: [Slide] = [
        Slide(
            titleKey: "keepTrackTitle",
            descriptionKey: "keepTrackDescription",
            view: AnyView(TimerDemoView())
        ),
        Slide(
            titleKey: "intervalsTitle",
            descriptionKey: "intervalsDescription",
            view: AnyView(IntervalsDemoView())
        ),
        Slide(
            titleKey: "notificationsTitle",
            descriptionKey: "notificationsDescription",
            view: AnyView(NotificationsDemoView())
        )
    ]
    
    var body: some View {
        VStack {
            Text("welcome")
                .font(.headline)
                .foregroundStyle(.secondary)
            
            if currentSlideIndex < slides.count {
                // Slideshow content
                VStack {
                    Spacer()
                    slides[currentSlideIndex].view
                        .environmentObject(timerManager)
                        .frame(height: 200)
                    Spacer()
                    
                    Text(NSLocalizedString(
                        slides[currentSlideIndex].titleKey,
                        tableName: "WelcomeLocalizations",
                        comment: "Slide description")
                    )
                    .font(.title)
                    
                    Text(NSLocalizedString(
                        slides[currentSlideIndex].descriptionKey,
                        tableName: "WelcomeLocalizations",
                        comment: "Slide description")
                    )
                    .foregroundStyle(.secondary)
                    .padding(.bottom)
                    
                    HStack {
                        Button(action: {
                            if currentSlideIndex > 0 {
                                currentSlideIndex -= 1
                            }
                        }) {
                            Image(systemName: "arrow.left")
                        }
                        
                        Spacer()
                        
                        Button(action: {
                            if currentSlideIndex < slides.count - 1 {
                                currentSlideIndex += 1
                            } else {
                                // End of slideshow, show main content
                                currentSlideIndex = slides.count
                            }
                        }) {
                            Image(systemName: currentSlideIndex == slides.count - 1 ? "checkmark" : "arrow.right")
                        }
                    }
                    .buttonStyle(LuminareCompactButtonStyle())
                    .frame(height: 35)
                }
                .multilineTextAlignment(.center)
                
            // -MARK: After slides
            } else {
                // After slideshow, show original content
                VStack {
                    AppIconView()

                    VStack (spacing: 2) {
                        Text("welcomeTitle")
                            .font(.title)
                        Text("\(NSLocalizedString("appName", comment:"app name")) \(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "0.0.0")")
                            .foregroundStyle(.secondary)
                        
                        Text("welcomeContent")
                            .multilineTextAlignment(.center)
                            .padding(.vertical)
                    }
                    
                    Spacer()

                    LaunchAtLogin.Toggle("\(NSLocalizedString("launchAtLoginLabel", comment: "Launch at login label"))")
                    
                    HStack {
                        Button(action: {
                            if currentSlideIndex > 0 {
                                currentSlideIndex -= 1
                            }
                        }) {
                            Image(systemName: "arrow.left")
                        }
                        .frame(width: 75)
                        
                        Button(action: {
                            WelcomeWindowController.shared.close()
                        }) {
                            Text("doneLabel")
                        }
                        
                        if showWelcome {
                            Button(action: {
                                showWelcome = false
                                WelcomeWindowController.shared.close()
                            }) {
                                Text("dontShowAgainLabel")
                            }
                            .background(Color.red.opacity(0.2))
                            .cornerRadius(8)
                        }
                    }
                    .buttonStyle(LuminareCompactButtonStyle())
                    .frame(height: 35)
                    .padding(.top)
                }
            }
        }
        .padding(20)
        .background(
            VisualEffectView(material: .hudWindow, blendingMode: .behindWindow)
                .ignoresSafeArea(.all)
        )
        .frame(width: 400, height: 400)
        .overlay(RoundedRectangle(cornerRadius: 22).stroke(.tertiary, lineWidth: 1))
        .mask(RoundedRectangle(cornerRadius: 22))
    }
}

struct Slide {
    let titleKey: String
    let descriptionKey: String
    let view: AnyView
}

// -MARK: App Icon
struct AppIconView: View {
    var body: some View {
        Image(nsImage: NSApplication.shared.applicationIconImage)
            .resizable()
            .scaledToFit()
            .frame(width: 100, height: 100)
    }
}

// -MARK: Timer demo
struct TimerDemoView: View {
    var body: some View {
        Text("9:41")
            .font(.system(size: 36, design: .monospaced))
    }
}

// -MARK: Intervals demo
struct IntervalsDemoView: View {
    var body: some View {
        HStack {
            VStack {
                Image(systemName: "figure.seated.side.right")
                Text("sittingLabel")
            }
            .padding()
            .frame(width: 125)
            .background(.indigo.opacity(0.2))
            .cornerRadius(12)
            
            VStack {
                Image(systemName: "figure")
                Text("standingLabel")
            }
            .padding()
            .frame(width: 125)
            .background(.yellow.opacity(0.2))
            .cornerRadius(12)
        }
    }
}

// -MARK: Notifications select
struct NotificationsDemoView: View {
    @EnvironmentObject var timerManager: TimerManager
    @AppStorage("notificationType") var notificationType: NotificationType = .banner

    var body: some View {
        VStack {
            Text("chooseNotiStyle")
                .font(.title3)
            
            LuminareSection {
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
            }
            
            Text("canChangeLater")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .onAppear() {
            let HUDNoti = HUD(
                title: NSLocalizedString("HUD", comment: "HUD Notification style title"),
                description: NSLocalizedString("thisIsHUD", comment: "Description for HUD notification"),
                systemImage: "heart.fill",
                imageColor: .accentColor
            )
            HUDNoti.show(for: 3)
            
            let NotchNoti = DynamicNotchInfo(
                icon: Image(systemName: "heart.fill"),
                title: NSLocalizedString("Banner", comment: "Banner notification style title"),
                description: NSLocalizedString("thisIsBanner", comment: "Description for Banner notification"),
                iconColor: .accentColor,
                textColor: .primary,
                style: .floating
            )
            NotchNoti.show(for: 3)
        }
        .onChange(of: notificationType) { newValue in
            timerManager.notificationType = newValue
            var settedNoti = AdaptableNotificationType(
                style: notificationType,
                title: NSLocalizedString("Notification style set!", comment: "Title for notification style set notification"),
                description: NSLocalizedString("Notifications will now be in this style.", comment: "Description for notification style set notification"),
                image: "heart.fill",
                iconColor: .accentColor
            )
            settedNoti.show(for: 2)
        }
        .padding(8)
        .overlay(RoundedRectangle(cornerRadius: 16).stroke(.tertiary.opacity(0.5), lineWidth: 1))
    }
}

// -MARK: Misc
#Preview {
    WelcomeView()
}
