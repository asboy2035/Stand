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
            title: "\(NSLocalizedString("timerPausedTitle", comment: "timer paused title"))",
            description: "\(NSLocalizedString("timerPausedContent", comment: "timer paused content"))"
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
        quietPauseTimer()
        // Show the pause notification indefinitely
        pauseNotch.show()
    }
    
    func quietPauseTimer() { // pause without notification
        isRunning = false
        timer?.invalidate()
        timer = nil
    }
    
    func resetTimer() {
        quietPauseTimer()
        currentInterval = .sitting
        remainingTime = sittingTime
    }
    
    func switchInterval() {
        quietPauseTimer()
        currentInterval = currentInterval == .sitting ? .standing : .sitting
        remainingTime = currentInterval == .sitting ? sittingTime : standingTime
        
        // Play the switch sound
        switchSound?.play()
        
        // Show dynamic notch notification
        let notch = DynamicNotchInfo(
            icon: Image(systemName: currentInterval == .sitting ? "figure.seated.side.left" : "figure.stand"),
            title: "\(NSLocalizedString("timeToLabel", comment: "time to")) \(currentInterval == .sitting ? "\(NSLocalizedString("sitLabel", comment: "sit"))" : "\(NSLocalizedString("standLabel", comment: "stand"))")",
            description: "\(NSLocalizedString("switchItUpContent", comment: "switch it up!"))"
        )
        notch.show(for: 3)
        
        resumeTimer()
        pauseNotch.hide()
    }
}
