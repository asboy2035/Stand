//
//  FloatingWindow.swift
//  SitStandTimer
//
//  Created by ash on 1/23/25.
//


import SwiftUI
import AppKit
import Luminare

class FloatingWindow: NSPanel {
    init(contentView: NSView) {
        super.init(
            contentRect: NSRect(x: 200, y: 250, width: 150, height: 150),
            styleMask: [ .closable, .utilityWindow, .nonactivatingPanel ],
            backing: .buffered,
            defer: false
        )

        self.isOpaque = false
        self.backgroundColor = .clear
        self.isMovableByWindowBackground = true
        self.level = .floating
        self.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
        self.contentView = contentView
        self.isReleasedWhenClosed = false
        self.title = "\(NSLocalizedString("appName", comment: "App name in widget title"))"
    }
}

struct FloatingWindowView: View {
    @EnvironmentObject var timerManager: TimerManager
    
    var body: some View {
        VStack {
            HStack {
                Button(action: { timerManager.toggleFloatingWindow() }) {
                    Image(systemName: "xmark.circle.fill")
                }
                Spacer()
                VStack {
                    RoundedRectangle(cornerRadius: 4)
                        .frame(width: 20, height: 3)
                        .foregroundStyle(.tertiary)
                }
                Spacer()
                
                Button(action: { NSApplication.shared.terminate(nil) }) {
                    Image(systemName: "power.circle.fill")
                }
            }
            .padding(.horizontal, 10)
            .padding(.bottom, 6)
            .foregroundStyle(.tertiary)
            .buttonStyle(.borderless)
            
            VStack(spacing: 10) {
                VStack(spacing: 2) {
                    Text(timerManager.currentInterval.localizedString)
                        .font(.system(size: 14))
                        .foregroundStyle(.secondary)
                    
                    Text(timerManager.remainingTimeString)
                        .font(.system(size: 32, weight: .light, design: .monospaced))
                }
                .padding(.bottom, 8)
                
                ControlButtons(showTooltips: false)
                    .environmentObject(timerManager)
            }
            .padding(.bottom, 8)
        }
        .frame(width: 150, height: 150)
        .background(timerManager.currentInterval.color.opacity(0.2))
        .background(
            VisualEffectView(
                material: .hudWindow,
                blendingMode: .behindWindow
            ).ignoresSafeArea()
        )
        .overlay(RoundedRectangle(cornerRadius: 18).stroke(.tertiary, lineWidth: 1))
        .mask(RoundedRectangle(cornerRadius: 18))
    }
}

private extension TimerManager {
    var remainingTimeString: String {
        let minutes = Int(remainingTime) / 60
        let seconds = Int(remainingTime) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}
