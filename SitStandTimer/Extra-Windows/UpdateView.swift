//
//  UpdateView.swift
//  SitStandTimer
//
//  Created by ash on 1/22/25.
//

import SwiftUI
import Luminare
import MarkdownUI

struct UpdateView: View {
    @State private var updateTag: String = ""
    @State private var updateBody: String = ""
    @State private var updateURL: String = ""

    var body: some View {
        VStack {
            Image(nsImage: NSApplication.shared.applicationIconImage)
                .resizable()
                .scaledToFit()
                .frame(width: 75, height: 75)

            if !updateTag.isEmpty {
                Text("\(NSLocalizedString("updateAvailableTitle", comment: "")): \(updateTag)!")
                    .font(.title)
                    .padding(.bottom, 5)
            }

            if !updateBody.isEmpty {
                ScrollView {
                    LuminareSection("infoTitle") {
                        Markdown(updateBody)
                            .padding()
                    }
                }
            }

            VStack {
                HStack {
                    if !updateURL.isEmpty {
                        Button(action: {
                            if let url = URL(string: updateURL) {
                                NSWorkspace.shared.open(url)
                            }
                        }) {
                            Label("GitHub", systemImage: "link")
                                .padding(5)
                        }
                    } else {
                        Text("loadingUpdate")
                    }
                    
                    Button(action: {
                        if let url = URL(string: "macappstore://") {
                            NSWorkspace.shared.open(url)
                        }
                    }) {
                        Label("App Store", systemImage: "applelogo")
                    }
                }
                .frame(height: 35)
                
                Text("updateAvailableContent")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .buttonStyle(LuminareCompactButtonStyle())
        }
        .padding(20)
        .frame(width: 400, height: 400)
        .background(VisualEffectView(material: .sidebar, blendingMode: .behindWindow).edgesIgnoringSafeArea(.all))
        .navigationTitle("updateAvailableTitle")
        .onAppear {
            self.getUpdateData()
        }
    }

    private func getUpdateData() {
        guard let url = URL(string: "https://api.github.com/repos/asboy2035/Stand/releases/latest") else {
            print("Invalid URL")
            return
        }

        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else {
                print("Error fetching data from GitHub: \(error?.localizedDescription ?? "Unknown error")")
                return
            }

            if let updateData = try? JSONDecoder().decode(GitHubReleaseData.self, from: data) {
                DispatchQueue.main.async {
                    self.updateTag = updateData.tag_name
                    self.updateBody = updateData.body
                    self.updateURL = updateData.html_url
                }
            } else {
                print("Failed to decode update data")
            }
        }

        task.resume()
    }
}

class UpdateWindowController: NSObject {
    private var window: NSWindow?

    static let shared = UpdateWindowController()
    
    private override init() {
        super.init()
    }

    func showUpdateView() {
        if window == nil {
            let updateView = UpdateView()
            let hostingController = NSHostingController(rootView: updateView)

            let window = NSWindow(
                contentRect: NSRect(x: 0, y: 0, width: 300, height: 300),
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

#Preview {
    UpdateView()
}

struct GitHubReleaseData: Codable {
    var tag_name: String
    var body: String
    var html_url: String
}
