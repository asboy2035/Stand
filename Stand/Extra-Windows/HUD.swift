//
//  HUD.swift
//  SitStandTimer
//
//  Created by ash on 3/3/25.
//

import SwiftUI

class HUD {
    let title: String
    let description: String
    let systemImage: String
    let imageColor: Color
    
    init(title: String, description: String, systemImage: String, imageColor: Color = .primary) {
        self.title = title
        self.description = description
        self.systemImage = systemImage
        self.imageColor = imageColor
    }
    
    func show(for duration: Int? = nil) {
        HUDController.shared.show(hud: self, delayBeforeHide: duration)
    }
    
    func hide() {
        HUDController.shared.hide()
    }
}

class HUDController: NSObject {
    private var window: NSWindow?
    static let shared = HUDController()
    private override init() { super.init() }
    
    func show(hud: HUD, delayBeforeHide: Int? = nil) {
        if window == nil {
            let hudView = HUDView(hud: hud)
            let hostingController = NSHostingController(rootView: hudView)
            
            let window = NSWindow(
                contentRect: NSRect(x: 0, y: 0, width: 200, height: 200),
                styleMask: [ .closable, .utilityWindow, .nonactivatingPanel ],
                backing: .buffered,
                defer: false
            )
            
            window.backgroundColor = .clear
            window.level = .floating
            window.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
            window.center()
            window.contentViewController = hostingController
            window.isReleasedWhenClosed = false
            self.window = window
        }
        
        window?.makeKeyAndOrderFront(nil)
        
        if let delay = delayBeforeHide {
            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(delay)) {
                self.hide()
            }
        }
    }
    
    func hide() {
        window?.close()
        window = nil
    }
}

struct HUDView: View {
    let hud: HUD
    @State private var isVisible: Bool = false  // Track visibility
    
    var body: some View {
        VStack {
            Image(systemName: hud.systemImage)
                .resizable()
                .scaledToFit()
                .frame(width: 75, height: 75)
                .padding()
                .foregroundStyle(hud.imageColor)
            
            Text(hud.title)
                .font(.title3)
            
            Text(hud.description)
                .foregroundStyle(.secondary)
        }
        .multilineTextAlignment(.center)
        .frame(width: 200, height: 200)
        .background(
            VisualEffectView(
                material: .hudWindow,
                blendingMode: .behindWindow
            )
            .ignoresSafeArea()
        )
        .overlay(RoundedRectangle(cornerRadius: 16).stroke(.tertiary, lineWidth: 1))
        .mask(RoundedRectangle(cornerRadius: 16))
        .opacity(isVisible ? 1 : 0)
        .onAppear {
            withAnimation(.easeIn(duration: 0.1)) {
                isVisible = true  // Fade in
            }
        }
    }
}
