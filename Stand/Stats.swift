//
//  Stats.swift
//  SitStandTimer
//
//  Created by ash on 3/22/25.
//

import SwiftUI
import Luminare

// -MARK: Stats
struct StatsView: View {
    @EnvironmentObject private var timerManager: TimerManager
    @Binding var showStats: Bool
    
    private func formatTime(minutes: Int) -> String {
        let hours = minutes / 60
        let remainingMinutes = minutes % 60
        return "\(hours)h \(remainingMinutes)m"
    }
    
    var body: some View {
        VStack {
            LuminareSection {
                VStack(spacing: 4) {
                    HStack {
                        Image(systemName: "clock.fill")
                            .frame(width: 20, height: 20)
                        Text(NSLocalizedString("totalLabel", comment: "Total label"))
                    }
                    .foregroundStyle(
                        LinearGradient(
                            gradient: Gradient(colors: [IntervalType.sitting.color, IntervalType.standing.color]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    Text(
                        formatTime(minutes:
                            timerManager.timeHistory.standingMinutes +
                            timerManager.timeHistory.sittingMinutes
                        )
                    )
                    .font(.system(.title, design: .monospaced))
                }
                
                StatsInfoCard(interval: .sitting, minutes: timerManager.timeHistory.sittingMinutes)
                StatsInfoCard(interval: .standing, minutes: timerManager.timeHistory.standingMinutes)
            }
            
            // Close button to dismiss the modal
            Button(action: {
                showStats = false
            }) {
                Label("closeLabel", systemImage: "xmark")
            }
            .buttonStyle(LuminareCompactButtonStyle())
        }
        .frame(minWidth: 150)
    }
}

struct StatsInfoCard: View {
    let interval: IntervalType
    @State var minutes: Int
    
    private func formatTime(minutes: Int) -> String {
        let hours = minutes / 60
        let remainingMinutes = minutes % 60
        return "\(hours)h \(remainingMinutes)m"
    }
    
    var body: some View {
        VStack(spacing: 4) {
            HStack {
                Image(systemName: interval.systemImage)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 20, height: 20)
                Text(interval.localizedString)
            }
            .foregroundStyle(interval.color)
            
            Text(formatTime(minutes: minutes))
                .font(.system(.title, design: .monospaced))
        }
    }
}
