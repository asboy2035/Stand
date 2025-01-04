//
//  TimerManager.swift
//  SitStandTimer
//
//  Recreated by ash on 1/4/25.
//

import Foundation
import DynamicNotchKit
import SwiftUI
import AppKit

enum IntervalType {
    case sitting
    case standing
}

class TimerManager: ObservableObject {
    @Published var currentInterval: IntervalType = .sitting
    @Published var remainingTime: TimeInterval = 0
    @Published var isRunning: Bool = false
    
    private var timer: Timer?
    private var sittingTime: TimeInterval = 30 * 60  // 30 minutes in seconds
    private var standingTime: TimeInterval = 10 * 60  // 10 minutes in seconds
    
    // Initialize the pauseNotch as a property
    private lazy var pauseNotch: DynamicNotchInfo = {
        DynamicNotchInfo(
            icon: Image(systemName: "pause.circle.fill"),
            title: "Timer paused",
            description: "Remember to press play!"
        )
    }()
    
    // System sound for interval changes
    private let switchSound = NSSound(named: "Funk")
    
    func initializeWithStoredTimes(sitting: Double, standing: Double) {
        sittingTime = sitting * 60
        standingTime = standing * 60
        remainingTime = sittingTime
    }
    
    func updateIntervalTime(type: IntervalType, time: Double) {
        let timeInSeconds = time * 60
        switch type {
        case .sitting:
            sittingTime = timeInSeconds
            if currentInterval == .sitting && !isRunning {
                remainingTime = timeInSeconds
            }
        case .standing:
            standingTime = timeInSeconds
            if currentInterval == .standing && !isRunning {
                remainingTime = timeInSeconds
            }
        }
    }
    
    func resumeTimer() {
        guard !isRunning else { return }
        
        pauseNotch.hide()
        isRunning = true
        
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            
            if self.remainingTime > 0 {
                self.remainingTime -= 1
            } else {
                self.switchInterval()
            }
        }
    }
    
    func pauseTimer() {
        isRunning = false
        timer?.invalidate()
        timer = nil
        
        // Show the pause notification without a duration
        pauseNotch.show()
    }
    
    func resetTimer() {
        pauseTimer()
        currentInterval = .sitting
        remainingTime = sittingTime
    }
    
    func switchInterval() {
        isRunning = false
        timer?.invalidate()
        timer = nil

        currentInterval = currentInterval == .sitting ? .standing : .sitting
        remainingTime = currentInterval == .sitting ? sittingTime : standingTime
        
        // Play the switch sound
        switchSound?.play()
        
        // Show dynamic notch notification
        let notch = DynamicNotchInfo(
            icon: Image(systemName: currentInterval == .sitting ? "figure.seated.side.left" : "figure.stand"),
            title: "Time to \(currentInterval == .sitting ? "Sit" : "Stand")!",
            description: "Switch your position to \(currentInterval == .sitting ? "sitting" : "standing")"
        )
        notch.show(for: 3)
        
        resumeTimer()
        pauseNotch.hide()
    }
}
