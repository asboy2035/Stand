//
//  Tab.swift
//  SitStandTimer
//
//  Created by ash on 3/14/25.
//

import Luminare
import SwiftUI

extension String: @retroactive Identifiable {
    public var id: String { self }
}

enum Tab: LuminareTabItem, CaseIterable {
    private var appVersion: String {
        if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
            return version
        }
        return "Unknown"
    }
    var id: String { title }
    
    case general
    case notifications
    
    case about
    case credits
    
    var title: String {
        switch self {
        case .general: .init(localized: "generalSettings")
        case .notifications: .init(localized: "notificationsSettings")
        case .about: .init(localized: "aboutLabel", defaultValue: "About Stand")
        case .credits: .init(localized: "creditsLabel", defaultValue: "Credits")
        }
    }
    
    var icon: Image {
        switch self {
        case .general: Image(systemName: "gear")
        case .notifications: Image(systemName: "bell.fill")
        case .about: Image(systemName: "info.circle")
        case .credits: Image(systemName: "shippingbox.fill")
        }
    }
    
    var showIndicator: Bool {
        switch self {
        default: false
        }
    }
    
    @ViewBuilder func view() -> some View {
        switch self {
        case .general: GeneralSettingsView()
        case .notifications: NotificationsSettingsView().environmentObject(TimerManager(headless: true))
        case .about: AboutContentView(appVersion: appVersion)
        case .credits: CreditsView()
        }
    }
    
    static let generalSection: [Tab] = [.general, .notifications]
    static let aboutSection: [Tab] = [.about, .credits]
}
