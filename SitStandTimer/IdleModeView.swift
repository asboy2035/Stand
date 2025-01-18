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

