//
//  ControlButtons.swift
//  SitStandTimer
//
//  Created by ash on 2/17/25.
//

import SwiftUI
import Luminare

struct ControlButtons: View {
    @EnvironmentObject var timerManager: TimerManager
    
    var body: some View {
        HStack(spacing: 16) {
            Button(action: {
                timerManager.resetTimer()
            }) {
                Image(systemName: "arrow.clockwise")
                    .frame(width: 10)
            }
            .frame(width: 20, height: 20)
            
            Button(action: {
                if timerManager.isRunning {
                    timerManager.pauseTimer()
                } else {
                    timerManager.resumeTimer()
                }
            }) {
                Image(systemName: timerManager.isRunning ? "pause.fill" : "play.fill")
            }
            .frame(width: 40, height: 40)
            
            Button(action: {
                timerManager.switchInterval()
            }) {
                Image(systemName: "repeat")
                    .frame(width: 10)
            }
            .frame(width: 20, height: 20)
        }
        .frame(width: 110, height: 20)
        .buttonStyle(LuminareCompactButtonStyle())
    }
}
