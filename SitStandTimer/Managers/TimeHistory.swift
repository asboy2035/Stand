//
//  TimeHistory.swift
//  SitStandTimer
//
//  Created by ash on 2/2/25.
//

import Foundation

struct TimeHistory: Codable {
    var sittingMinutes: Int
    var standingMinutes: Int
    
    static func load() -> TimeHistory {
        if let data = UserDefaults.standard.data(forKey: "timeHistory"),
           let history = try? JSONDecoder().decode(TimeHistory.self, from: data) {
            return history
        }
        return TimeHistory(sittingMinutes: 0, standingMinutes: 0)
    }
    
    func save() {
        if let encoded = try? JSONEncoder().encode(self) {
            UserDefaults.standard.set(encoded, forKey: "timeHistory")
        }
    }
}
