//
//  AboutWindow.swift
//  SitStandTimer
//
//  Created by ash on 1/18/25.
//

import SwiftUI

class AboutWindowController: NSObject {
    private var window: NSWindow?

    static let shared = AboutWindowController()
    
    private override init() {
        super.init()
    }

    func showAboutView() {
        if window == nil {
            let aboutView = AboutView()
            let hostingController = NSHostingController(rootView: aboutView)

            let window = NSWindow(
                contentRect: NSRect(x: 0, y: 0, width: 300, height: 200),
                styleMask: [.titled, .closable, .miniaturizable],
                backing: .buffered,
                defer: false
            )
            
            window.center()
            window.contentViewController = hostingController
            window.isReleasedWhenClosed = false

            self.window = window
        }

        window?.makeKeyAndOrderFront(nil)
    }
}

struct AboutView: View {
    private var appVersion: String {
        if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
            return version
        }
        return "Unknown"
    }
    
    @State private var isLatestVersion: Bool = true
    @State private var showUpdateAlert: Bool = false
    @State private var releaseUrl: String? = "https://github.com/asboy2035/Stand/releases/latest"

    var body: some View {
        VStack {
            Image(nsImage: NSApplication.shared.applicationIconImage)
                .resizable()
                .scaledToFit()
                .frame(width: 50, height: 50)

            HStack(spacing: 5) {
                Text("appName")
                    .font(.title)
                Text(appVersion)
                    .foregroundStyle(.foreground.opacity(0.8))
            }
            Spacer()
            
            Text("thanksText")
            Text("madeWithLove")
        }
        .navigationTitle("aboutMenuLabel")
        .toolbar {
            ToolbarItem(placement: .automatic) {
                Button(action: {
                    WelcomeWindowController.shared.showWelcomeView()
                }) {
                    Label("welcome", systemImage: "figure.wave")
                }
            }

            ToolbarItem(placement: .automatic) {
                Button(action: {
                    if let url = URL(string: "https://github.com/asboy2035/Stand") {
                        NSWorkspace.shared.open(url)
                    }
                }) {
                    Label("websiteLabel", systemImage: "globe")
                }
            }
            
            ToolbarItem(placement: .automatic) {
                Button(action: {
                    checkForUpdates()
                }) {
                    Label("updateLabel", systemImage: "arrow.triangle.2.circlepath")
                }
            }
        }
        .padding(30)
        .frame(width: 400, height: 250)
        .alert(isPresented: $showUpdateAlert) {
            Alert(
                title: Text("updateAvailableTitle"),
                message: Text("updateAvailableContent"),
                primaryButton: .default(Text("updateAvailableVisitButton")) {
                    if let url = releaseUrl, let releasePageURL = URL(string: url) {
                        NSWorkspace.shared.open(releasePageURL)
                    }
                },
                secondaryButton: .default(Text("updateAvailableDismissButton"))
            )
        }
        .onAppear {
            checkForUpdates() // Automatically check when the view appears
        }
        .background(VisualEffectView(material: .sidebar, blendingMode: .behindWindow).edgesIgnoringSafeArea(.all))
    }
    
    private func checkForUpdates() {
        guard let url = URL(string: "https://api.github.com/repos/asboy2035/Stand/releases/latest") else {
            print("Invalid URL")
            return
        }

        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else {
                print("Error fetching data from GitHub: \(error?.localizedDescription ?? "Unknown error")")
                return
            }

            if let releaseData = try? JSONDecoder().decode(GitHubRelease.self, from: data) {
                let latestVersion = releaseData.tag_name
                DispatchQueue.main.async {
                    // Compare the latest version from GitHub with the app's version
                    if latestVersion > appVersion {
                        isLatestVersion = false
                        showUpdateAlert = true
                    }
                }
            }
        }

        task.resume()
    }
}

struct GitHubRelease: Codable {
    var tag_name: String
}

#Preview {
    AboutView()
}
