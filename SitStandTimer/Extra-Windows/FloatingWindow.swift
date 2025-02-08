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
    }
}

struct FloatingWindowView: View {
    @EnvironmentObject var timerManager: TimerManager
    
    var body: some View {
        ZStack {
            VStack { // Close/Quit actions
                HStack {
                    Button(action: { timerManager.toggleFloatingWindow() }) {
                        Image(systemName: "xmark.circle.fill")
                    }
                    Spacer()
                    
                    Button(action: { NSApplication.shared.terminate(nil) }) {
                        Image(systemName: "power.circle.fill")
                    }
                }
                .foregroundStyle(.tertiary)
                .padding(8)
                .buttonStyle(.borderless)
                Spacer()
            }
            
            VStack(spacing: 10) {
                VStack(spacing: 2) {
                    Text(timerManager.currentInterval == .sitting ? "sittingLabel" : "standingLabel")
                        .font(.system(size: 18))
                        .foregroundStyle(.secondary)
                    
                    Text(timerManager.remainingTimeString)
                        .font(.system(size: 32, weight: .light, design: .monospaced))
                }
                Spacer()
                
                // Control buttons
                HStack(spacing: 16) {
                    Button(action: {
                        timerManager.resetTimer()
                    }) {
                        Image(systemName: "arrow.clockwise")
                            .frame(width: 10)
                    }
                    .frame(width: 20, height: 20)
                    
                    Button(action: {
                        if timerManager.isRunning {
                            timerManager.pauseTimer()
                        } else {
                            timerManager.resumeTimer()
                        }
                    }) {
                        Image(systemName: timerManager.isRunning ? "pause.fill" : "play.fill")
                    }
                    .frame(width: 40, height: 40)
                    
                    Button(action: {
                        timerManager.switchInterval()
                    }) {
                        Image(systemName: "repeat")
                            .frame(width: 10)
                    }
                    .frame(width: 20, height: 20)
                }
                .frame(width: 110, height: 20)
                .buttonStyle(LuminareCompactButtonStyle())
            }
            .padding(20)
        }
        .frame(width: 150, height: 150)
        .background(VisualEffectView(material: .hudWindow, blendingMode: .behindWindow).edgesIgnoringSafeArea(.all))
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
