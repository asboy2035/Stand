//
//  Widget.swift
//  Widget
//
//  Created by ash on 1/20/25.
//

import WidgetKit
import SwiftUI

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> SitStandWidgetEntry {
        SitStandWidgetEntry(date: Date(), isStanding: false, remainingTime: 1800, isRunning: true)
    }

    func getSnapshot(in context: Context, completion: @escaping (SitStandWidgetEntry) -> ()) {
        let entry = SitStandWidgetEntry(
            date: Date(),
            isStanding: UserDefaults.shared.bool(forKey: "isStanding"),
            remainingTime: UserDefaults.shared.double(forKey: "remainingTime"),
            isRunning: UserDefaults.shared.bool(forKey: "isRunning")
        )
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        var entries: [SitStandWidgetEntry] = []
        let currentDate = Date()
        
        // Update every minute
        for minuteOffset in 0 ..< 60 {
            let entryDate = Calendar.current.date(byAdding: .minute, value: minuteOffset, to: currentDate)!
            let entry = SitStandWidgetEntry(
                date: entryDate,
                isStanding: UserDefaults.shared.bool(forKey: "isStanding"),
                remainingTime: UserDefaults.shared.double(forKey: "remainingTime"),
                isRunning: UserDefaults.shared.bool(forKey: "isRunning")
            )
            entries.append(entry)
        }

        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }
}

struct SitStandWidgetEntry: TimelineEntry {
    let date: Date
    let isStanding: Bool
    let remainingTime: TimeInterval
    let isRunning: Bool
}
//
//struct WidgetEntryView : View {
//    var entry: Provider.Entry
//
//    var body: some View {
//        VStack {
//            Text("Time:")
//            Text(entry.date, style: .time)
//
//            Text("Favorite Emoji:")
//            Text(entry.configuration.favoriteEmoji)
//        }
//    }
//}

struct SitStandWidget: Widget {
    let kind: String = "SitStandWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            @Environment(\.widgetFamily) var family
            
            switch family {
            case .systemSmall:
                CompactSitStandWidgetView(entry: entry)
            case .systemMedium:
                ExpandedSitStandWidgetView(entry: entry)
            @unknown default:
                CompactSitStandWidgetView(entry: entry)
            }
        }
        .configurationDisplayName("Stand Widget")
        .description("Track your sitting and standing intervals")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

struct CompactSitStandWidgetView: View {
    var entry: Provider.Entry
    
    var body: some View {
        HStack {
            Image(systemName: entry.isStanding ? "figure.stand" : "figure.seated.side")
                .font(.title)
            if entry.isRunning {
                Text(timeString(from: entry.remainingTime))
                    .font(.caption)
                    .monospacedDigit()
            }
        }
        .padding()
        .containerBackground(.clear, for: .widget)
    }
    
    private func timeString(from timeInterval: TimeInterval) -> String {
        let minutes = Int(timeInterval) / 60
        let seconds = Int(timeInterval) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}

struct ExpandedSitStandWidgetView: View {
    var entry: Provider.Entry
    
    var body: some View {
        VStack(spacing: 12) {
            Text(entry.isStanding ? "Time to Stand" : "Time to Sit")
                .font(.headline)
            
            Image(systemName: entry.isStanding ? "figure.stand" : "figure.seated.side")
                .font(.system(size: 40))
            
            if entry.isRunning {
                Text(timeString(from: entry.remainingTime))
                    .font(.title2)
                    .monospacedDigit()
            }
            
            HStack(spacing: 16) {
                Button(action: {
                    // Reset action via URL scheme
                    if let url = URL(string: "sitstandtimer://reset") {
                        NSWorkspace.shared.open(url)
                    }
                }) {
                    Image(systemName: "arrow.counterclockwise")
                        .font(.title3)
                }
                
                Button(action: {
                    // Play/pause action via URL scheme
                    if let url = URL(string: "sitstandtimer://toggle") {
                        NSWorkspace.shared.open(url)
                    }
                }) {
                    Image(systemName: entry.isRunning ? "pause.fill" : "play.fill")
                        .font(.title3)
                }
                
                Button(action: {
                    // Skip action via URL scheme
                    if let url = URL(string: "sitstandtimer://skip") {
                        NSWorkspace.shared.open(url)
                    }
                }) {
                    Image(systemName: "forward.fill")
                        .font(.title3)
                }
            }
        }
        .containerBackground(.clear, for: .widget)
        .padding()
    }
    
    private func timeString(from timeInterval: TimeInterval) -> String {
        let minutes = Int(timeInterval) / 60
        let seconds = Int(timeInterval) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}
