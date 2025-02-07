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
                contentRect: NSRect(x: 0, y: 0, width: 400, height: 500),
                styleMask: [.titled, .closable, .miniaturizable],
                backing: .buffered,
                defer: false
            )
            
            window.center()
            window.contentViewController = hostingController
            window.isReleasedWhenClosed = false
            window.titlebarAppearsTransparent = true
            window.styleMask.insert(.fullSizeContentView)

            self.window = window
        }

        window?.makeKeyAndOrderFront(nil)
    }
}

struct WelcomeView: View {
    @AppStorage("showWelcome") var showWelcome: Bool = true

    var body: some View {
        VStack {
            Image(nsImage: NSApplication.shared.applicationIconImage)
                .resizable()
                .scaledToFit()
                .frame(width: 100, height: 100)

            VStack (spacing: 2) {
                Text("welcomeTitle")
                    .font(.title)
                Text("\(NSLocalizedString("appName", comment:"app name")) \(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "0.0.0")")
                    .foregroundStyle(.secondary)
                
                Text("welcomeContent")
                    .multilineTextAlignment(.center)
                    .padding(.vertical)
            }
            
            LaunchAtLogin.Toggle("\(NSLocalizedString("launchAtLoginLabel", comment: "Launch at login label"))")
            HStack {
                Button(action: {
                    WelcomeWindowController.shared.close()
                }) {
                    Text("doneLabel")
                        .padding(5)
                }
                .buttonStyle(LuminareCompactButtonStyle())
                .frame(width: 100)
                
                if showWelcome {
                    Button(action: {
                        showWelcome = false
                        WelcomeWindowController.shared.close()
                    }) {
                        Text("dontShowAgainLabel")
                            .padding(5)
                    }
                    .buttonStyle(LuminareDestructiveButtonStyle())
                    .cornerRadius(8)
                }
            }
            .frame(height: 35)
            .padding(.top)
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
        .frame(width: 350, height: 400)
        .padding(20)
        .background(VisualEffectView(material: .sidebar, blendingMode: .behindWindow).edgesIgnoringSafeArea(.all))
    }
}

#Preview {
    WelcomeView()
}
