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

// Idle mode layout
struct IdleModeView: View {
    @ObservedObject var timerManager: TimerManager
    let currentTime: Date
    
    var body: some View {
        VStack {
            // Status text at top
            IdleStatusText(timerManager: timerManager)
            Spacer()
            
            // Timer controls in middle
            VStack(spacing: 20) {
                // Interval Display
                HStack(spacing: 15) {
                    Image(systemName: timerManager.currentInterval == .sitting ? "figure.seated.side.left" : "figure.stand")
                        .font(.largeTitle)
                        .foregroundColor(timerManager.currentInterval == .sitting ? .indigo : .yellow)
                    Text(timerManager.currentInterval == .sitting ? "sittingLabel" : "standingLabel")
                        .font(.title)
                        .foregroundColor(timerManager.currentInterval == .sitting ? .indigo : .yellow)
                }
                
                // Time Display
                Text(timeString(from: timerManager.remainingTime))
                    .font(.system(size: 48, design: .monospaced))
                    .fontWeight(.bold)
                
                // Control Buttons
                HStack(spacing: 15) {
                    Button(action: {
                        timerManager.resetTimer()
                    }) {
                        Image(systemName: "arrow.clockwise")
                            .foregroundColor(.white)
                            .frame(width: 10, height: 25)
                    }
                    
                    Button(action: {
                        if timerManager.isRunning {
                            timerManager.pauseTimer()
                        } else {
                            timerManager.resumeTimer()
                        }
                    }) {
                        Image(systemName: timerManager.isRunning ? "pause.fill" : "play.fill")
                            .foregroundColor(.white)
                            .frame(width: 20, height: 35)
                    }
                    
                    Button(action: {
                        timerManager.switchInterval()
                    }) {
                        Image(systemName: "repeat")
                            .foregroundColor(.white)
                            .frame(width: 10, height: 25)
                    }
                }
            }
            
            Spacer()
            HStack {
                LargeClockView(currentTime: currentTime)
                Spacer()
            }
            .padding(.bottom, 40)
            .padding(.leading, 40)
        }
        .padding()
    }
    
    private func timeString(from timeInterval: TimeInterval) -> String {
        let minutes = Int(timeInterval) / 60
        let seconds = Int(timeInterval) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}


struct NormalModeView: View {
    @ObservedObject var timerManager: TimerManager
    @Binding var sittingTime: Double
    @Binding var standingTime: Double
    @State var sideBarIsPresented: Bool = false
    
    var body: some View {
        HStack {
            if sideBarIsPresented {
                VStack(spacing: 20) {
                    // Title
                    Text("appName")
                        .font(.largeTitle)
                        .fontWeight(.medium)
                        .padding(.bottom, 20)
                    
                    VStack {
                        Text("sittingTimeLabel")
                        Slider(value: $sittingTime, in: 5...60, step: 5)
                            .onChange(of: sittingTime) { newValue in
                                timerManager.updateIntervalTime(type: .sitting, time: newValue)
                            }
                            .frame(width: 150)
                        HStack(spacing: 3) {
                            Text("\(Int(sittingTime))")
                                .font(.system(size: 12, weight: .bold))
                            Text("minutesAbbr")
                        }
                    }
                    
                    VStack {
                        Text("standingTimeLabel")
                        Slider(value: $standingTime, in: 5...60, step: 5)
                            .onChange(of: standingTime) { newValue in
                                timerManager.updateIntervalTime(type: .standing, time: newValue)
                            }
                            .frame(width: 150)
                        HStack(spacing: 3) {
                            Text("\(Int(standingTime))")
                                .font(.system(size: 12, weight: .bold))
                            Text("minutesAbbr")
                        }
                    }
                }
                .frame(minWidth: 250, idealWidth: 250, maxWidth: 250, minHeight: 250, idealHeight: 275, maxHeight: .infinity)
                .background(VisualEffectView(material: .sidebar, blendingMode: .behindWindow).edgesIgnoringSafeArea(.all))
                .frame(alignment: .top)
            }

            VStack(spacing: 20) {
                // Interval Display
                HStack(spacing: 15) {
                    Image(systemName: timerManager.currentInterval == .sitting ? "figure.seated.side.left" : "figure.stand")
                        .font(.largeTitle)
                        .foregroundColor(timerManager.currentInterval == .sitting ? .indigo : .yellow)
                    Text(timerManager.currentInterval == .sitting ? "sittingLabel" : "standingLabel")
                        .font(.title)
                        .foregroundColor(timerManager.currentInterval == .sitting ? .indigo : .yellow)
                }
                
                // Time Display
                Text(timeString(from: timerManager.remainingTime))
                    .font(.system(size: 48, design: .monospaced))
                    .fontWeight(.medium)
                                
                // Control Buttons
                HStack(spacing: 15) {
                    Button(action: {
                        timerManager.resetTimer()
                    }) {
                        Image(systemName: "arrow.clockwise")
                            .foregroundColor(.white)
                            .frame(width: 10, height: 25)
                    }
                    
                    Button(action: {
                        if timerManager.isRunning {
                            timerManager.pauseTimer()
                        } else {
                            timerManager.resumeTimer()
                        }
                    }) {
                        Image(systemName: timerManager.isRunning ? "pause.fill" : "play.fill")
                            .foregroundColor(.white)
                            .frame(width: 20, height: 35)
                    }
                    
                    Button(action: {
                        timerManager.switchInterval()
                    }) {
                        Image(systemName: "repeat")
                            .foregroundColor(.white)
                            .frame(width: 10, height: 25)
                    }
                }
            }
            .frame(minWidth: 400, idealWidth: nil, maxWidth: .infinity, minHeight: 350, idealHeight: nil, maxHeight: .infinity)
            .toolbar {
                ToolbarItemGroup(placement: .automatic) {
                    Button(action: { sideBarIsPresented.toggle() }) {
                        Label("Toggle Left Sidebar", systemImage: "sidebar.left")
                    }
                }
            }
        }
        .background(VisualEffectView(material: .headerView, blendingMode: .behindWindow).edgesIgnoringSafeArea(.all))
        .onAppear {
            timerManager.initializeWithStoredTimes(sitting: sittingTime, standing: standingTime)
        }
    }
    
    private func timeString(from timeInterval: TimeInterval) -> String {
        let minutes = Int(timeInterval) / 60
        let seconds = Int(timeInterval) % 60
        return String(format: "%02d:%02d", minutes, seconds)
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

