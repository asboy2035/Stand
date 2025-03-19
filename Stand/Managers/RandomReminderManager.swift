//
//  RandomReminderManager.swift
//  SitStandTimer
//
//  Created by ash on 3/19/25.
//

import Foundation
import DynamicNotchKit
import SwiftUI
import AppKit

class RandomReminderManager {
    private var timer: Timer?
    private weak var timerManager: TimerManager?
    
    init(timerManager: TimerManager) {
        self.timerManager = timerManager
        scheduleNextReminder()
    }
    
    private func scheduleNextReminder() {
        let randomInterval = TimeInterval(Int.random(in: 600...1800)) // 10-30 minutes
        timer?.invalidate()
        timer = Timer.scheduledTimer(timeInterval: randomInterval, target: self, selector: #selector(sendReminder), userInfo: nil, repeats: false)
    }
    
    @objc private func sendReminder() {
        guard let timerManager = timerManager else { return }
        let currentInterval = timerManager.currentInterval
        if !timerManager.isRunning { return }
        
        if !UserDefaults.standard.bool(forKey: "showOccasionalReminders") {
            scheduleNextReminder()
            return
        }
        
        var reminderNotification = AdaptableNotificationType(
            style: timerManager.notificationType,
            title: NSLocalizedString("Reminder", comment: "Reminder title"),
            description: NSLocalizedString("keepItUpLabel", comment: "Keep it up label"),
            image: currentInterval.systemImage,
            iconColor: currentInterval.color
        )
        reminderNotification.show(for: 3)
        
        scheduleNextReminder()
    }
}
