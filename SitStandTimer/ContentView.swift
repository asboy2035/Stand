//
//  ContentView.swift
//  SitStandTimer
//
//  Created by ash on 12/10/24.
//

import SwiftUI
import DynamicNotchKit

struct LargeClockView: View {
    let currentTime: Date
    
    var body: some View {
        Text(timeString(from: currentTime))
            .font(.system(size: 96, design: .monospaced))
            .fontWeight(.light)
    }
    
    private func timeString(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss"
        return formatter.string(from: date)
    }
}

// Status text for idle mode
struct IdleStatusText: View {
    @ObservedObject var timerManager: TimerManager
    @State private var currentTime = Date()
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    private var statusText: String {
        if timerManager.isRunning {
            return "\(timerManager.currentInterval == .sitting ? "\(NSLocalizedString("sittingLabel", comment: "sitting"))" : "\(NSLocalizedString("standingLabel", comment: "standing"))") - \(timeString(from: timerManager.remainingTime)) \(NSLocalizedString("remainingLabel", comment: "remaining time"))"
        } else {
            return "Timer Paused"
        }
    }
    
    var body: some View {
        Text(statusText)
            .font(.title2)
            .foregroundColor(.gray)
            .padding(.top, 20)
            .onReceive(timer) { input in
                currentTime = input
            }
    }
    
    private func timeString(from timeInterval: TimeInterval) -> String {
        let minutes = Int(timeInterval) / 60
        let seconds = Int(timeInterval) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}


struct ContentView: View {
    @StateObject private var timerManager = TimerManager()
    @AppStorage("sittingTime") private var sittingTime: Double = 30
    @AppStorage("standingTime") private var standingTime: Double = 10
    @State private var isFullScreen = false
    @State private var currentTime = Date()
    
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        HStack {
            if isFullScreen {
                IdleModeView(timerManager: timerManager, currentTime: currentTime)
            } else {
                NormalModeView(timerManager: timerManager, sittingTime: $sittingTime, standingTime: $standingTime)
            }
        }
        .onReceive(timer) { input in
            currentTime = input
        }
        .onReceive(NotificationCenter.default.publisher(for: NSWindow.willEnterFullScreenNotification)) { _ in
            isFullScreen = true
        }
        .onReceive(NotificationCenter.default.publisher(for: NSWindow.willExitFullScreenNotification)) { _ in
            isFullScreen = false
        }
    }
}

struct VisualEffectView: NSViewRepresentable {
    let material: NSVisualEffectView.Material
    let blendingMode: NSVisualEffectView.BlendingMode
    
    func makeNSView(context: Context) -> NSVisualEffectView {
        let visualEffectView = NSVisualEffectView()
        visualEffectView.material = material
        visualEffectView.blendingMode = blendingMode
        visualEffectView.state = .active
        return visualEffectView
    }
    
    func updateNSView(_ visualEffectView: NSVisualEffectView, context: Context) {
        visualEffectView.material = material
        visualEffectView.blendingMode = blendingMode
    }
}

#Preview {
    ContentView()
}

