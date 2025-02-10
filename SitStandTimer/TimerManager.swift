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
import LaunchAtLogin

enum IntervalType {
    case sitting
    case standing
}

class TimerManager: ObservableObject {
    @Published var currentInterval: IntervalType = .sitting
    @Published var remainingTime: TimeInterval = 0
    @Published var isRunning: Bool = false
    @Published var isPauseNotchVisible: Bool = false
    @Published var isPaused: Bool = false
    @Published var selectedSound: String = "Funk" {
        didSet {
            UserDefaults.standard.set(selectedSound, forKey: "selectedAlertSound")
        }
    }
    @Published var timeHistory: TimeHistory
    
    private var timer: Timer?
    private var historyTimer: Timer?
    private var sittingTime: TimeInterval = 30 * 60
    private var standingTime: TimeInterval = 10 * 60
    private var lastHistoryUpdateTime: Date = Date()
    private var startTime: Date?
    
    private lazy var pauseNotch: DynamicNotchInfo = {
        DynamicNotchInfo(
            icon: Image(systemName: "pause.circle.fill"),
            title: NSLocalizedString("timerPausedTitle", comment: "timer paused title"),
            description: NSLocalizedString("timerPausedContent", comment: "timer paused content")
        )
    }()
    
    init() {
        self.timeHistory = TimeHistory.load()
        
        selectedSound = UserDefaults.standard.string(forKey: "selectedAlertSound") ?? "Funk"
        currentInterval = UserDefaults.standard.bool(forKey: "isStanding") ? .standing : .sitting
        remainingTime = UserDefaults.standard.double(forKey: "remainingTime")
        
        if remainingTime == 0 {
            remainingTime = 30 * 60
        }
        
        if LaunchAtLogin.isEnabled {
            if UserDefaults.standard.bool(forKey: "startTimerAtLaunch") {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
                    self?.resumeTimer()
                }
            }
            
            if UserDefaults.standard.bool(forKey: "showWidgetAtLaunch") {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
                    if self?.floatingWindowController == nil {
                        self?.toggleFloatingWindow()
                    }
                }
            }
        }
    }
    
    private var floatingWindowController: NSWindowController? {
        willSet { floatingWindowController?.close() }
    }

    func toggleFloatingWindow() {
        if floatingWindowController == nil {
            let contentView = FloatingWindowView()
                .environmentObject(self)
            let hostingController = NSHostingController(rootView: contentView)
            let floatingWindow = FloatingWindow(contentView: hostingController.view)
            
            floatingWindowController = NSWindowController(window: floatingWindow)
            floatingWindowController?.showWindow(self)
        } else {
            floatingWindowController?.close()
            floatingWindowController = nil
        }
    }
    
    private func updateAppIcon() {
        let iconName = currentInterval == .sitting ? "SittingIcon" : "StandingIcon"
        if let icon = NSImage(named: iconName) {
            NSApplication.shared.applicationIconImage = icon
        }
    }
    
    private func saveState() {
        UserDefaults.standard.set(currentInterval == .standing, forKey: "isStanding")
        UserDefaults.standard.set(remainingTime, forKey: "remainingTime")
        UserDefaults.standard.set(isRunning, forKey: "isRunning")
    }
    
    private var switchSound: NSSound? {
        return NSSound(named: selectedSound)
    }
    
    func hidePauseNotch() {
        pauseNotch.hide()
        isPauseNotchVisible = false
    }
    
    func showPauseNotch() {
        pauseNotch.show()
        isPauseNotchVisible = true
    }
    
    func initializeWithStoredTimes(sitting: Double, standing: Double) {
        sittingTime = round(sitting) * 60
        standingTime = round(standing) * 60
        remainingTime = sittingTime
    }

    func updateIntervalTime(type: IntervalType, time: Double) {
        let timeInSeconds = round(time) * 60 // Ensure it's an exact multiple of 60
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
    
    private func updateTimeHistory() {
        guard isRunning else { return }
        
        let now = Date()
        let elapsedMinutes = Int(now.timeIntervalSince(lastHistoryUpdateTime) / 60)
        
        if elapsedMinutes > 0 {
            if currentInterval == .sitting {
                timeHistory.sittingMinutes += elapsedMinutes
            } else {
                timeHistory.standingMinutes += elapsedMinutes
            }
            timeHistory.save()
            lastHistoryUpdateTime = now
        }
    }
    
    private func setupHistoryTracker() {
        historyTimer?.invalidate()
        historyTimer = Timer.scheduledTimer(withTimeInterval: 60, repeats: true) { [weak self] _ in
            self?.updateTimeHistory()
        }
    }
    
    private var targetEndTime: Date?

    func resumeTimer() {
        updateAppIcon()
        saveState()
        guard !isRunning else { return }

        hidePauseNotch()
        isRunning = true
        isPaused = false
        lastHistoryUpdateTime = Date()

        startTime = Date()
        targetEndTime = Date().addingTimeInterval(remainingTime) // Set the exact end time

        setupHistoryTracker()

        timer?.invalidate() // Clear any previous timer
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.updateRemainingTime()
        }
    }

    private func updateRemainingTime() {
        guard let targetEndTime else { return }

        let newRemainingTime = targetEndTime.timeIntervalSinceNow
        let roundedTime = ceil(newRemainingTime) // Ensure it only decrements whole seconds

        if roundedTime != remainingTime {
            remainingTime = max(roundedTime, 0) // Prevent negative values
        }

        if remainingTime <= 0 {
            switchInterval()
        }
    }
    
    func pauseTimer() {
        quietPauseTimer()
        showPauseNotch()
    }
    
    func quietPauseTimer() {
        isRunning = false
        isPaused = true
        timer?.invalidate()
        timer = nil
        historyTimer?.invalidate()
        historyTimer = nil
        saveState()
    }
    
    func resetTimer() {
        saveState()
        quietPauseTimer()
        hidePauseNotch()
        isPaused = false
        currentInterval = .sitting
        remainingTime = sittingTime
        
        if let icon = NSImage(named: "AppIcon") {
            NSApplication.shared.applicationIconImage = icon
        }
    }
    
    func playSound() {
        switchSound?.play()
    }
    
    func switchInterval() {
        quietPauseTimer()
        currentInterval = currentInterval == .sitting ? .standing : .sitting
        remainingTime = currentInterval == .sitting ? sittingTime : standingTime
        updateAppIcon()
        switchSound?.play()
        
        let notch = DynamicNotchInfo(
            icon: Image(systemName: currentInterval == .sitting ? "figure.seated.side.left" : "figure.stand"),
            title: NSLocalizedString("timeToLabel", comment: "time to") + " " + (currentInterval == .sitting ? NSLocalizedString("sitLabel", comment: "sit") : NSLocalizedString("standLabel", comment: "stand")),
            description: NSLocalizedString("switchItUpContent", comment: "switch it up!")
        )
        notch.show(for: 3)
        
        resumeTimer()
        hidePauseNotch()
    }
}
