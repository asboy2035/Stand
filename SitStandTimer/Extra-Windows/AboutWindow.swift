//
//  AboutWindow.swift
//  SitStandTimer
//
//  Created by ash on 1/18/25.
//

import SwiftUI
import Luminare

class AboutWindowController: NSObject {
    private var window: NSWindow?
    @ObservedObject private var viewModel = AboutViewModel()

    static let shared = AboutWindowController()
    
    private override init() {
        super.init()
    }

    func showAboutView() {
        if window == nil {
            let aboutView = AboutView(viewModel: viewModel)
            let hostingController = NSHostingController(rootView: aboutView)

            let window = NSWindow(
                contentRect: NSRect(x: 0, y: 0, width: 600, height: 450),
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
    
    func showSupport() {
        viewModel.selectedView = "support"
        showAboutView()
    }
}

class AboutViewModel: ObservableObject {
    @Published var selectedView: String = "about"
}

struct AboutView: View {
    @ObservedObject var viewModel: AboutViewModel
    
    private var appVersion: String {
        if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
            return version
        }
        return "Unknown"
    }
    
    var body: some View {
        HStack(spacing: 0) {
            List {
                LuminareSection {
                    Button(action: { viewModel.selectedView = "" }) {
                        Label("aboutMenuLabel", systemImage: "info.circle")
                    }
                    Button(action: { viewModel.selectedView = "credits" }) {
                        Label("creditsLabel", systemImage: "shippingbox.fill")
                    }
                    Button(action: { viewModel.selectedView = "support" }) {
                        Label("supportMeLabel", systemImage: "person.crop.circle")
                    }
                }
                Spacer()
                Image(systemName: "heart.fill")
                    .imageScale(.large)
                    .foregroundStyle(.tertiary)
            }
            .buttonStyle(LuminareButtonStyle())
            .listStyle(.sidebar)
            .scrollContentBackground(.hidden)
            .frame(width: 200)
            
            Divider().ignoresSafeArea(.all)
            
            VStack {
                switch viewModel.selectedView {
                case "credits":
                    CreditsView()
                case "support":
                    SupportView()
                default:
                    AboutContentView(appVersion: appVersion)
                }
            }
            .layoutPriority(1)
            .padding()
            .frame(minWidth: 350, minHeight: 350)
        }
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
        .background(VisualEffectView(material: .sidebar, blendingMode: .behindWindow).edgesIgnoringSafeArea(.all))
    }
}

struct GitHubRelease: Codable {
    var tag_name: String
}

struct CreditsView: View {
    struct Dependency {
        let name: String
        let url: String
        let license: String
        let systemImage: String
    }

    let dependencies: [Dependency] = [
        Dependency(
            name: "SwiftUI",
            url: "https://developer.apple.com/xcode/swiftui/",
            license: "Apple License",
            systemImage: "swift"
        ),
        Dependency(
            name: "Luminare",
            url: "https://github.com/MrKai77/Luminare",
            license: "BSD 3-Clause License",
            systemImage: "macwindow.and.cursorarrow"
        ),
        Dependency(
            name: "DynamicNotchKit",
            url: "https://github.com/MrKai77/DynamicNotchKit",
            license: "MIT License",
            systemImage: "macbook.gen2"
        ),
        Dependency(
            name: "LaunchAtLogin",
            url: "https://github.com/sindresorhus/LaunchAtLogin-Modern",
            license: "MIT License",
            systemImage: "bolt.fill"
        ),
        Dependency(
            name: "MarkdownUI",
            url: "https://github.com/gonzalezreal/swift-markdown-ui",
            license: "MIT License",
            systemImage: "richtext.page"
        ),
        Dependency(
            name: "SettingsKit",
            url: "https://github.com/david-swift/SettingsKit-macOS",
            license: "MIT License",
            systemImage: "gear"
        )
    ]

    var body: some View {
        VStack {
            VStack {
                LuminareSection {
                    ForEach(dependencies, id: \.name) { dependency in
                        Button(action: {
                            if let url = URL(string: dependency.url) {
                                NSWorkspace.shared.open(url)
                            }
                        }) {
                            VStack {
                                Label(
                                    dependency.name,
                                    systemImage: dependency.systemImage.isEmpty ?
                                        "shippingbox.fill" :
                                        dependency.systemImage
                                )
                                Text(dependency.license)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                        .buttonStyle(LuminareButtonStyle())
                        .frame(height: 45)
                    }
                }
                Spacer()
            }
            .navigationTitle("creditsLabel")
        }
    }
}

struct SupportView: View {
    var body: some View {
        VStack {
            LuminareSection {
                Button(action: {
                    if let url = URL(string: "https://ko-fi.com/asboy2035") {
                        NSWorkspace.shared.open(url)
                    }
                }) {
                    Label("Ko-Fi", systemImage: "dollarsign")
                }
                .frame(height: 35)
                
                Button(action: {
                    if let url = URL(string: "https://throne.com/asboy2035") {
                        NSWorkspace.shared.open(url)
                    }
                }) {
                    Label("Throne", systemImage: "gift.fill")
                }
                .frame(height: 35)
            }
            .navigationTitle("supportMeLabel")
            .buttonStyle(LuminareButtonStyle())
            
            Spacer()
        }
    }
}

struct AboutContentView: View {
    @State private var isLatestVersion: Bool = true
    var appVersion: String

    var body: some View {
        VStack {
            Image(nsImage: NSApplication.shared.applicationIconImage)
                .resizable()
                .scaledToFit()
                .frame(width: 75, height: 75)
            
            Text("appName")
                .font(.title)
            Text(appVersion)
                .foregroundStyle(.secondary)
            
            Spacer()
            Button(action: {
                checkForUpdates()
            }) {
                Label(
                    isLatestVersion ? "noUpdatesLabel" : "updateLabel",
                    systemImage: "arrow.triangle.2.circlepath"
                )
            }
            .disabled(isLatestVersion)
            .buttonStyle(LuminareCompactButtonStyle())
            .frame(width: 150, height: 35)
            Text("thanksText")
            Text("madeWithLove")
        }
        .padding()
        .onAppear() {
            checkForUpdates()
        }
        .navigationTitle("aboutLabel")
        .toolbar {
            ToolbarItem(placement: .automatic) {
                Button(action: {
                    WelcomeWindowController.shared.showWelcomeView()
                }) {
                    Label("welcome", systemImage: "figure.wave")
                }
            }
        }
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
                        UpdateWindowController.shared.showUpdateView()
                    }
                #if DEBUG
                    UpdateWindowController.shared.showUpdateView() // Debug
                #endif
                }
            }
        }

        task.resume()
    }
}

#Preview {
    
}

