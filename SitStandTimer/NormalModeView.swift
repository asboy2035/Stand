//
//  NormalModeView.swift
//  SitStandTimer
//
//  Created by ash on 1/18/25.
//

import SwiftUI

struct NormalModeView: View {
    @ObservedObject var timerManager: TimerManager
    @Binding var sittingTime: Double
    @Binding var standingTime: Double
    
    var body: some View {
        NavigationSplitView {
            SidebarView(sittingTime: $sittingTime, standingTime: $standingTime, timerManager: timerManager)
                .frame(minWidth: 200, maxWidth: 250)
        } detail: {
            DetailView(timerManager: timerManager)
        }
        .onAppear {
            timerManager.initializeWithStoredTimes(sitting: sittingTime, standing: standingTime)
        }
    }
}

struct SidebarView: View {
    @Binding var sittingTime: Double
    @Binding var standingTime: Double
    @ObservedObject var timerManager: TimerManager
    
    var body: some View {
        List {
            Section(header: Text(NSLocalizedString("optionsLabel", comment: "Options header in sidebar"))) {
                VStack(alignment: .leading) {
                    Text(NSLocalizedString("sittingTimeLabel", comment: "Sitting time label"))
                    Slider(value: $sittingTime, in: 5...60, step: 5)
                        .onChange(of: sittingTime) { newValue in
                            timerManager.updateIntervalTime(type: .sitting, time: newValue)
                        }
                    Text("\(Int(sittingTime)) \(NSLocalizedString("minutesAbbr", comment: "Minutes abbreviation"))")
                }
                .padding(.bottom)
                
                VStack(alignment: .leading) {
                    Text(NSLocalizedString("standingTimeLabel", comment: "Standing time label"))
                    Slider(value: $standingTime, in: 5...60, step: 5)
                        .onChange(of: standingTime) { newValue in
                            timerManager.updateIntervalTime(type: .standing, time: newValue)
                        }
                    Text("\(Int(standingTime)) \(NSLocalizedString("minutesAbbr", comment: "Minutes abbreviation"))")
                }
            }
        }
    }
}

struct DetailView: View {
    @ObservedObject var timerManager: TimerManager
    
    var body: some View {
        VStack(spacing: 20) {
            HStack(spacing: 15) {
                Image(systemName: timerManager.currentInterval == .sitting ? "figure.seated.side.left" : "figure.stand")
                    .font(.largeTitle)
                    .foregroundColor(timerManager.currentInterval == .sitting ? .indigo : .yellow)
                Text(timerManager.currentInterval == .sitting ? "sittingLabel" : "standingLabel")
                    .font(.title)
                    .foregroundColor(timerManager.currentInterval == .sitting ? .indigo : .yellow)
            }

            Text(timeString(from: timerManager.remainingTime))
                .font(.system(size: 48, design: .monospaced))
            
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
        .navigationTitle(NSLocalizedString("appName", comment: "App name for main content title"))
        .frame(minWidth: 500, idealWidth: nil, maxWidth: .infinity, minHeight: 350, idealHeight: nil, maxHeight: .infinity)
        .background(VisualEffectView(material: .headerView, blendingMode: .behindWindow).edgesIgnoringSafeArea(.all))
    }
    
    private func timeString(from timeInterval: TimeInterval) -> String {
        let minutes = Int(timeInterval) / 60
        let seconds = Int(timeInterval) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}
