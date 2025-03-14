//
//  AboutWindow.swift
//  SitStandTimer
//
//  Created by ash on 1/18/25.
//

import SwiftUI
import Luminare

// -MARK: AboutWindowController
class AboutWindowController: NSObject {
    private var window: NSWindow?
    @EnvironmentObject private var timerManager: TimerManager

    static let shared = AboutWindowController()
    
    private override init() {
        super.init()
    }

    func showAboutView(timerManager: TimerManager) {
        if window == nil {
            let aboutView = AboutView()
                .environmentObject(timerManager)
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
}

class AboutViewModel: ObservableObject {
    @Published var currentTab: Tab = .about
    
    let aboutSection: [Tab] = Tab.aboutSection
}

// -MARK: AboutView
struct AboutView: View {
    @EnvironmentObject private var timerManager: TimerManager
    @ObservedObject var viewModel = AboutViewModel()
    
    private var appVersion: String {
        if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
            return version
        }
        return "Unknown"
    }
    
    var body: some View {
        LuminareDividedStack {
            VStack {
                LuminareSidebar {
                    LuminareSidebarSection("aboutLabel", selection: $viewModel.currentTab, items: viewModel.aboutSection)
                }
                .padding(.top, 56)
            }
            .ignoresSafeArea()
            .frame(width: 200, height: 400, alignment: .top)
            
            LuminarePane {
                HStack {
                    viewModel.currentTab.iconView()
                    
                    Text(viewModel.currentTab.title)
                        .font(.title2)
                    
                    Spacer()
                }
            } content: {
                viewModel.currentTab.view()
                    .padding()
                    .frame(width: 400, height: 400)
            }
            .frame(width: 400)
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
        .background(VisualEffectView(material: .menu, blendingMode: .behindWindow).edgesIgnoringSafeArea(.all))
    }
}

// -MARK: Credits
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
                            HStack {
                                VStack(alignment: .leading) {
                                    Text(dependency.name)
                                    Text(dependency.license)
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                                .padding(.horizontal, 12)
                                Spacer()
                            }
                        }
                        .frame(maxHeight: 45)
                        .buttonStyle(
                            LuminareCosmeticButtonStyle(
                                Image(systemName: dependency.systemImage)
                            )
                        )
                    }
                }
                Spacer()
            }
        }
    }
}

// -MARK: About Content
struct AboutContentView: View {
    @State private var isLatestVersion: Bool = true
    @EnvironmentObject private var timerManager: TimerManager
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
        .toolbar {
            ToolbarItem(placement: .automatic) {
                Button(action: {
                    WelcomeWindowController.shared.showWelcomeView(timerManager: timerManager)
                }) {
                    Label("welcome", systemImage: "figure.wave")
                }
            }
        }
    }
    
    private func checkForUpdates() {
        guard let url = URL(
            string: "https://api.github.com/repos/asboy2035/Stand/releases/latest"
        ) else {
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
                    UpdateWindowController.shared.showUpdateView()
                    // Always show update in debug builds
                #endif
                }
            }
        }

        task.resume()
    }
}


// -MARK: Misc
struct GitHubRelease: Codable {
    var tag_name: String
}

#Preview {
    AboutView(viewModel: .init())
}

