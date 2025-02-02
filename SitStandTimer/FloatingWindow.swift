//
//  FloatingWindow.swift
//  SitStandTimer
//
//  Created by ash on 1/23/25.
//


import SwiftUI
import AppKit

class FloatingWindow: NSPanel {
    init(contentView: NSView) {
        super.init(
            contentRect: NSRect(x: 200, y: 250, width: 150, height: 150),
            styleMask: [.titled, .closable, .utilityWindow, .nonactivatingPanel],
            backing: .buffered,
            defer: false
        )
        
        self.titleVisibility = .hidden
        self.titlebarAppearsTransparent = true
        self.styleMask.remove(.titled)
        self.isOpaque = false
        self.backgroundColor = .clear
        self.isMovableByWindowBackground = true
        self.isFloatingPanel = true
        self.level = .floating
        self.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
        self.contentView = contentView
        self.isReleasedWhenClosed = false
    }
}

struct FloatingWindowView: View {
    @EnvironmentObject var timerManager: TimerManager
    
    var body: some View {
        VStack(spacing: 10) {
            Text(timerManager.currentInterval == .sitting ? "sittingLabel" : "standingLabel")
                .font(.system(size: 18))
                .foregroundColor(timerManager.currentInterval == .sitting ? .indigo : .yellow)
            
            Text(timerManager.remainingTimeString)
                .font(.system(size: 32, weight: .light, design: .monospaced))
            
            HStack(spacing: 10) {
                Button(action: {
                    timerManager.resetTimer()
                }) {
                    Image(systemName: "arrow.clockwise")
                }
                
                Button(action: {
                    timerManager.isRunning ? timerManager.quietPauseTimer() : timerManager.resumeTimer()
                }) {
                    Image(systemName: timerManager.isRunning ? "pause.fill" : "play.fill")
                        .padding(.vertical, 5)
                }
                
                Button(action: {
                    timerManager.switchInterval()
                }) {
                    Image(systemName: "repeat")
                }
            }
        }
        .padding(20)
        .background(VisualEffectView(material: .hudWindow, blendingMode: .behindWindow).edgesIgnoringSafeArea(.all))
        .mask(RoundedRectangle(cornerRadius: 20))
    }
}

private extension TimerManager {
    var remainingTimeString: String {
        let minutes = Int(remainingTime) / 60
        let seconds = Int(remainingTime) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}
