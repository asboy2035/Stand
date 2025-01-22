//
//  ChallengesWindow.swift
//  SitStandTimer
//
//  Created by ash on 1/21/25.
//

import SwiftUI

class ChallengesWindowController: NSObject {
    private var window: NSWindow?

    static let shared = ChallengesWindowController()
    
    private override init() {
        super.init()
    }

    func showAboutView() {
        if window == nil {
            let challengesView = ChallengesView()
            let hostingController = NSHostingController(rootView: challengesView)

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

import SwiftUI

struct ChallengesView: View {
    @State private var currentChallenge: Challenge = challenges.randomElement()!
    
    var body: some View {
        VStack {
            Image(nsImage: NSApplication.shared.applicationIconImage)
                .resizable()
                .scaledToFit()
                .frame(width: 50, height: 50)
            
            HStack(spacing: 5) {
                Text("challengesLabel")
                    .font(.title)
                Text("betaLabel")
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
            
            Text("yourChallengeLabel")
                .font(.headline)
            
            HStack() {
                Image(systemName: currentChallenge.symbol)
                    .imageScale(.large)
                    .padding(.horizontal, 6)
                
                VStack(alignment: .leading) {
                    Text(currentChallenge.title)
                        .font(.title2)
                    Text(currentChallenge.description)
                        .font(.body)
                }
                
                Button(action: {
                    currentChallenge = challenges.randomElement()!
                }) {
                    Image(systemName: "arrow.clockwise")
                        .frame(height: 25)
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(Color.primary.opacity(0.1))
            .mask(RoundedRectangle(cornerRadius: 13))
            .overlay(RoundedRectangle(cornerRadius: 13).stroke(Color.primary.opacity(0.2), lineWidth: 1))
        }
        .padding(30)
        .frame(width: 400, height: 300)
        .background(VisualEffectView(material: .sidebar, blendingMode: .behindWindow).edgesIgnoringSafeArea(.all))
        .navigationTitle("challengesLabel")
        .toolbar {
            ToolbarItem(placement: .automatic) {
                Button(action: {
                    AboutWindowController.shared.showAboutView()
                }) {
                    Label("aboutMenuLabel", systemImage: "info.circle")
                }
            }
        }
    }
}

#Preview {
    ChallengesView()
}
