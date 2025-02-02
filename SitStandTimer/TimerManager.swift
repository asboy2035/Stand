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
    private var sittingTime: TimeInterval = 30 * 60  // 30 minutes in seconds
    private var standingTime: TimeInterval = 10 * 60  // 10 minutes in seconds
    private var lastHistoryUpdateTime: Date = Date()
    
    // Initialize the pauseNotch as a property
    private lazy var pauseNotch: DynamicNotchInfo = {
        DynamicNotchInfo(
            icon: Image(systemName: "pause.circle.fill"),
            title: "\(NSLocalizedString("timerPausedTitle", comment: "timer paused title"))",
            description: "\(NSLocalizedString("timerPausedContent", comment: "timer paused content"))"
        )
    }()
    
    init() {
        self.timeHistory = TimeHistory.load()

        // Load settings with default values
        selectedSound = UserDefaults.standard.string(forKey: "selectedAlertSound") ?? "Funk"
        
        // Load shared state with safe defaults
        currentInterval = UserDefaults.shared.bool(forKey: "isStanding") ? .standing : .sitting
        remainingTime = UserDefaults.shared.double(forKey: "remainingTime")
        isRunning = false  // Always start paused for safety
        
        // Initialize with defaults if not set
        if remainingTime == 0 {
            remainingTime = 30 * 60  // Default to 30 minutes
        }
        
        // Handle automation settings
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
        UserDefaults.shared.set(currentInterval == .standing, forKey: "isStanding")
        UserDefaults.shared.set(remainingTime, forKey: "remainingTime")
        UserDefaults.shared.set(isRunning, forKey: "isRunning")
    }
    
    // System sound for interval changes
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
    
    func resumeTimer() {
        updateAppIcon()
        saveState()
        guard !isRunning else { return }
        
        hidePauseNotch()
        isRunning = true
        isPaused = false
        lastHistoryUpdateTime = Date()
        setupHistoryTracker()
        
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
        showPauseNotch()
    }
    
    func quietPauseTimer() { // pause without notification
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
        
        // Change app icon based on the current interval
        updateAppIcon()
        
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
        hidePauseNotch()
    }
}
