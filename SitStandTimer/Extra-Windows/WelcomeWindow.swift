//
//  WelcomeWindow.swift
//  SitStandTimer
//
//  Created by ash on 1/19/25.
//

import SwiftUI
import Combine
import LaunchAtLogin
import Luminare

class WelcomeWindowController: NSObject {
    private var window: NSWindow?

    static let shared = WelcomeWindowController()
    
    private override init() {
        super.init()
    }
    
    func close() {
        window?.close()
    }

    func showWelcomeView() {
        if window == nil {
            let welcomeView = WelcomeView()
            let hostingController = NSHostingController(rootView: welcomeView)

            let window = NSWindow(
                contentRect: NSRect(x: 0, y: 0, width: 400, height: 350),
                styleMask: [.titled, .fullSizeContentView],
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

struct WelcomeView: View {
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
            if currentSlideIndex < slides.count {
                // Slideshow content
                VStack {
                    slides[currentSlideIndex].view
                        .frame(height: 100)
                        .padding(.bottom)
                    
                    Text(NSLocalizedString(slides[currentSlideIndex].titleKey, tableName: "WelcomeLocalizations", comment: "Slide description"))
                        .font(.title)
                    
                    Text(NSLocalizedString(slides[currentSlideIndex].descriptionKey, tableName: "WelcomeLocalizations", comment: "Slide description"))
                        .foregroundStyle(.secondary)
                    Spacer()
                    
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
                        .frame(width: 100)
                        
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
                            .buttonStyle(LuminareDestructiveButtonStyle())
                            .cornerRadius(8)
                        }
                    }
                    .buttonStyle(LuminareCompactButtonStyle())
                    .frame(height: 35)
                    .padding(.top)
                }
            }
        }
        .navigationTitle("welcome")
        .toolbar {
            ToolbarItem(placement: .automatic) {
                Button(action: {
                    AboutWindowController.shared.showAboutView()
                }) {
                    Label("aboutMenuLabel", systemImage: "info.circle")
                }
            }
        }
        .padding(20)
        .background(VisualEffectView(material: .sidebar, blendingMode: .behindWindow).ignoresSafeArea(.all))
        .frame(width: 400, height: 350)
    }
}

struct Slide {
    let titleKey: String
    let descriptionKey: String
    let view: AnyView
}

struct AppIconView: View {
    var body: some View {
        Image(nsImage: NSApplication.shared.applicationIconImage)
            .resizable()
            .scaledToFit()
            .frame(width: 100, height: 100)
    }
}

struct TimerDemoView: View {
    var body: some View {
        Text("9:41")
            .font(.system(size: 36, design: .monospaced))
    }
}

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

struct NotificationsDemoView: View {
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "figure.stand")
                .imageScale(.large)
            
            VStack(alignment: .leading) {
                Text(NSLocalizedString("timeToLabel", comment: "time to") + " " + NSLocalizedString("standLabel", comment: "stand"))
                Text("switchItUpContent")
                    .foregroundStyle(.secondary)
            }
        }
        .padding()
        .background(VisualEffectView(material: .headerView, blendingMode: .behindWindow))
        .overlay(RoundedRectangle(cornerRadius: 18).stroke(.tertiary.opacity(0.5), lineWidth: 1))
        .cornerRadius(18)
    }
}

#Preview {
    WelcomeView()
}
