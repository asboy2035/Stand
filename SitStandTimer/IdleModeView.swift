//
//  IdleModeView.swift
//  SitStandTimer
//
//  Created by ash on 1/18/25.
//

import SwiftUI
import Luminare

// Idle mode layout
struct IdleModeView: View {
    @EnvironmentObject private var timerManager: TimerManager
    let currentTime: Date
    @Environment(\.colorScheme) var colorScheme // Get the current color scheme
    @State private var currentChallenge: Challenge = challenges.randomElement()!

    var body: some View {
        VStack {
            Spacer()
            VStack(spacing: 15) {
                LargeClockView(currentTime: currentTime)
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
            
            VStack(spacing: 15) {
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
                    .frame(height: 45)
                    
                    Button(action: {
                        timerManager.switchInterval()
                    }) {
                        Image(systemName: "repeat")
                            .frame(width: 10, height: 25)
                    }
                }
                .frame(width: 100, height: 35)
                .buttonStyle(LuminareCompactButtonStyle())
            }
            
            ChallengeCard()
            .padding(.top, 25)
        }
        .padding(20)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(colorScheme == .dark ? Color.black : Color.white) // Set background color based on color scheme)
        .edgesIgnoringSafeArea(.all)
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
                .foregroundStyle(.secondary)
            
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
