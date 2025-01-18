//
//  IdleModeView.swift
//  SitStandTimer
//
//  Created by ash on 1/18/25.
//

import SwiftUI

// Idle mode layout
struct IdleModeView: View {
    @ObservedObject var timerManager: TimerManager
    let currentTime: Date
    @Environment(\.colorScheme) var colorScheme // Get the current color scheme

    var body: some View {
        VStack {
            Spacer()
            VStack {
                LargeClockView(currentTime: currentTime)
                Text(" ")
                HStack(spacing: 15) {
                    Image(systemName: timerManager.currentInterval == .sitting ? "figure.seated.side.left" : "figure.stand")
                        .font(.largeTitle)
                        .foregroundColor(timerManager.currentInterval == .sitting ? .indigo : .yellow)
                    Text(timerManager.currentInterval == .sitting ? "sittingLabel" : "standingLabel")
                        .font(.title)
                        .foregroundColor(timerManager.currentInterval == .sitting ? .indigo : .yellow)
                }
            }
            Spacer()
            
            // Timer controls in the middle
            VStack(spacing: 20) {
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
                            .frame(width: 20, height: 35)
                    }
                    
                    Button(action: {
                        timerManager.switchInterval()
                    }) {
                        Image(systemName: "repeat")
                            .frame(width: 10, height: 25)
                    }
                }
            }
        }
        .padding(20)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(colorScheme == .dark ? Color.black : Color.white) // Set background color based on color scheme
        .edgesIgnoringSafeArea(.all) // Make the background fill the screen
    }
    
    private func timeString(from timeInterval: TimeInterval) -> String {
        let minutes = Int(timeInterval) / 60
        let seconds = Int(timeInterval) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}

struct LargeClockView: View {
    let currentTime: Date
    
    var body: some View {
        HStack(spacing: 15) {
            Text(NSLocalizedString("timePresenterPrefix", comment: "time declare label"))
                .font(.system(size: 56))
                .fontWeight(.light)
                .foregroundStyle(.foreground.opacity(0.8))
            
            Text(timeString(from: currentTime))
                .font(.system(size: 72))
                .fontWeight(.medium)
        }
    }
    
    private func timeString(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
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

#Preview {
    IdleModeView(timerManager: .init(), currentTime: .init())
}
