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
            .fontWeight(.regular)
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
            return "\(timerManager.currentInterval == .sitting ? "Sitting" : "Standing") - \(timeString(from: timerManager.remainingTime)) remaining"
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


// Updated ContentView with idle mode
struct ContentView: View {
    @StateObject private var timerManager = TimerManager()
    @AppStorage("sittingTime") private var sittingTime: Double = 30
    @AppStorage("standingTime") private var standingTime: Double = 10
    @State private var isFullScreen = false
    @State private var currentTime = Date()
    
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        ZStack {
            VisualEffectView(material: .sidebar, blendingMode: .behindWindow)
                .edgesIgnoringSafeArea(.all)
            
            if isFullScreen {
                IdleModeView(timerManager: timerManager, currentTime: currentTime)
            } else {
                NormalModeView(timerManager: timerManager, sittingTime: $sittingTime, standingTime: $standingTime)
            }
        }
//        .frame(width: isFullScreen ? nil : 450, height: isFullScreen ? nil : 400)
//        .background(VisualEffectView(material: .sidebar, blendingMode: .behindWindow))
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
                    Text(timerManager.currentInterval == .sitting ? "Sitting" : "Standing")
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
            
            // Clock at bottom left
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


// Normal mode layout (existing view)
struct NormalModeView: View {
    @ObservedObject var timerManager: TimerManager
    @Binding var sittingTime: Double
    @Binding var standingTime: Double
    
    var body: some View {
        VStack(spacing: 20) {
            // Title
            Text("Stand")
                .font(.largeTitle)
                .fontWeight(.medium)
            
            // Interval Display
            HStack(spacing: 15) {
                Image(systemName: timerManager.currentInterval == .sitting ? "figure.seated.side.left" : "figure.stand")
                    .font(.largeTitle)
                    .foregroundColor(timerManager.currentInterval == .sitting ? .indigo : .yellow)
                Text(timerManager.currentInterval == .sitting ? "Sitting" : "Standing")
                    .font(.title)
                    .foregroundColor(timerManager.currentInterval == .sitting ? .indigo : .yellow)
            }
            
            // Time Display
            Text(timeString(from: timerManager.remainingTime))
                .font(.system(size: 48, design: .monospaced))
                .fontWeight(.bold)
            
            // Interval Configuration
            HStack {
                VStack {
                    Text("Sitting Time")
                    Slider(value: $sittingTime, in: 5...60, step: 5)
                        .onChange(of: sittingTime) { newValue in
                            timerManager.updateIntervalTime(type: .sitting, time: newValue)
                        }
                        .frame(width: 150)
                    Text("\(Int(sittingTime)) min")
                }
                
                VStack {
                    Text("Standing Time")
                    Slider(value: $standingTime, in: 5...60, step: 5)
                        .onChange(of: standingTime) { newValue in
                            timerManager.updateIntervalTime(type: .standing, time: newValue)
                        }
                        .frame(width: 150)
                    Text("\(Int(standingTime)) min")
                }
            }
            .padding()
            
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
        .padding()
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

