//
//  AppDelegate.swift
//  SitStandTimer
//
//  Created by ash on 1/20/25.
//

import Foundation
import Cocoa
import SwiftUICore

class AppDelegate: NSObject, NSApplicationDelegate {
    @ObservedObject var timerManager = TimerManager()
    func handle(_ url: URL) {
        switch url.host {
        case "reset":
            timerManager.resetTimer()
        case "toggle":
            if timerManager.isRunning {
                timerManager.pauseTimer()
            } else {
                timerManager.resumeTimer()
            }
        case "skip":
            timerManager.switchInterval()
        default:
            break
        }
    }
}
