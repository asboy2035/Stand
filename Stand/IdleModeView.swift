//
//  IdleModeView.swift
//  SitStandTimer
//
//  Created by ash on 1/18/25.
//

import SwiftUI
import Luminare

// -MARK: Idle mode
struct IdleModeView: View {
    @EnvironmentObject private var timerManager: TimerManager
    let currentTime: Date
    @State private var currentChallenge: Challenge = challenges.randomElement()!

    var body: some View {
        VStack {
            Spacer()
            VStack(spacing: 15) {
                ClockView(currentTime: currentTime)
                HStack(spacing: 15) {
                    Image(systemName: timerManager.currentInterval.systemImage)
                    .font(.largeTitle)
                    
                    Text(timerManager.currentInterval.localizedString)
                    .font(.title)
                }
                .foregroundStyle(timerManager.currentInterval.color)
            }
            Spacer()
            
            // Timer view
            VStack(spacing: 15) {
                // Time Display
                Text(timeString(from: timerManager.remainingTime))
                    .font(.system(size: 48, design: .monospaced))
                    .fontWeight(.medium)
                
                ControlButtons()
                    .environmentObject(timerManager)
            }
            
            ChallengeCard()
            .padding(.top, 25)
        }
        .preferredColorScheme(.dark)
        .padding(20)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.black)
        .edgesIgnoringSafeArea(.all)
    }
    
    private func timeString(from timeInterval: TimeInterval) -> String {
        let minutes = Int(timeInterval) / 60
        let seconds = Int(timeInterval) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}

// -MARK: Clock
struct ClockView: View {
    let currentTime: Date
    
    var body: some View {
        HStack(spacing: 15) {
            Text(NSLocalizedString("timePresenterPrefix", comment: "time declare label"))
                .font(.system(size: 56, weight: .light))
                .foregroundStyle(.secondary)
            
            Text(timeString(from: currentTime))
                .font(.system(size: 72, weight: .medium))
        }
    }
    
    private func timeString(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: date)
    }
}
