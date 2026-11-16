//
//  AppTimeManager.swift
//  MOD
//
//  Created by Rajpal singh on 16/11/26.
//

import Foundation
import UIKit
import SwiftUI
import Combine

// MARK: - Global US TimeZone & Date Manager

final class AppTimeManager: ObservableObject {
    static let shared = AppTimeManager()
    
    // Explicit Combine / SwiftUI ObservableObject conformance
    let objectWillChange = ObservableObjectPublisher()
    
    @Published var currentDate: Date = Date()
    
    // MARK: - Active Device TimeZone
    
    /// Detects device local timezone anywhere in the world (USA, UK, Australia, Canada, etc.).
    /// Returns the device's actual timezone so local times and locations stay accurate.
    var currentDeviceTimeZone: TimeZone {
        return TimeZone.current
    }
    
    /// Verifies if a timezone is located in the United States
    func isUSATimeZone(_ tz: TimeZone = TimeZone.current) -> Bool {
        let usPrefixes = ["America/", "US/"]
        let usAbbrevs = ["PST", "PDT", "MST", "MDT", "CST", "CDT", "EST", "EDT", "AKST", "AKDT", "HST", "HDT"]
        let isPrefix = usPrefixes.contains { tz.identifier.hasPrefix($0) }
        let isAbbrev = usAbbrevs.contains(tz.abbreviation() ?? "")
        return isPrefix || isAbbrev
    }
    
    /// Verifies if a timezone is located in the United Kingdom
    func isUKTimeZone(_ tz: TimeZone = TimeZone.current) -> Bool {
        tz.identifier.contains("London") || tz.identifier.contains("Europe/Belfast") || tz.identifier.contains("GB")
    }
    
    /// Verifies if a timezone is located in Australia
    func isAustraliaTimeZone(_ tz: TimeZone = TimeZone.current) -> Bool {
        tz.identifier.hasPrefix("Australia/") || tz.identifier.contains("Sydney") || tz.identifier.contains("Melbourne")
    }
    
    /// Returns the localized timezone for any store location (USA, UK, Australia, etc.)
    func timeZone(forStore storeName: String) -> TimeZone {
        let lower = storeName.lowercased()
        
        // United Kingdom Stores
        if lower.contains("london") || lower.contains("uk") || lower.contains("united kingdom") || lower.contains("manchester") || lower.contains("soho") {
            return TimeZone(identifier: "Europe/London") ?? currentDeviceTimeZone
        }
        
        // Australia Stores
        if lower.contains("sydney") || lower.contains("nsw") {
            return TimeZone(identifier: "Australia/Sydney") ?? currentDeviceTimeZone
        } else if lower.contains("melbourne") || lower.contains("victoria") {
            return TimeZone(identifier: "Australia/Melbourne") ?? currentDeviceTimeZone
        } else if lower.contains("brisbane") || lower.contains("queensland") {
            return TimeZone(identifier: "Australia/Brisbane") ?? currentDeviceTimeZone
        } else if lower.contains("perth") {
            return TimeZone(identifier: "Australia/Perth") ?? currentDeviceTimeZone
        } else if lower.contains("australia") {
            return TimeZone(identifier: "Australia/Sydney") ?? currentDeviceTimeZone
        }
        
        // USA Stores
        if lower.contains("austin") || lower.contains("texas") || lower.contains("south congress") {
            return TimeZone(identifier: "America/Chicago") ?? currentDeviceTimeZone
        } else if lower.contains("new york") || lower.contains("union square") {
            return TimeZone(identifier: "America/New_York") ?? currentDeviceTimeZone
        } else if lower.contains("denver") || lower.contains("colorado") {
            return TimeZone(identifier: "America/Denver") ?? currentDeviceTimeZone
        } else {
            // Seattle / West Coast / default store timezone
            return TimeZone(identifier: "America/Los_Angeles") ?? currentDeviceTimeZone
        }
    }
    
    /// Clean Timezone Abbreviation (USA: PST/CST/EST, UK: GMT/BST, Australia: AEST/AEDT, etc.)
    func abbreviation(for tz: TimeZone? = nil) -> String {
        let target = tz ?? currentDeviceTimeZone
        let id = target.identifier
        let isDST = target.isDaylightSavingTime()
        
        // UK
        if id.contains("London") || id.contains("GB") {
            return isDST ? "BST" : "GMT"
        }
        
        // Australia
        if id.contains("Sydney") || id.contains("Melbourne") || id.contains("Canberra") || id.contains("Hobart") {
            return isDST ? "AEDT" : "AEST"
        } else if id.contains("Brisbane") {
            return "AEST"
        } else if id.contains("Adelaide") || id.contains("Darwin") {
            return isDST ? "ACDT" : "ACST"
        } else if id.contains("Perth") {
            return "AWST"
        }
        
        // USA
        if id.contains("Los_Angeles") || id.contains("Pacific") || id.contains("Seattle") {
            return isDST ? "PDT" : "PST"
        } else if id.contains("Denver") || id.contains("Mountain") || id.contains("Phoenix") {
            return isDST ? "MDT" : "MST"
        } else if id.contains("Chicago") || id.contains("Central") || id.contains("Austin") {
            return isDST ? "CDT" : "CST"
        } else if id.contains("New_York") || id.contains("Eastern") {
            return isDST ? "EDT" : "EST"
        } else if id.contains("Anchorage") || id.contains("Alaska") {
            return isDST ? "AKDT" : "AKST"
        } else if id.contains("Honolulu") || id.contains("Hawaii") {
            return "HST"
        }
        return target.abbreviation() ?? "PST"
    }
    
    /// Formatted uppercase header string (e.g. "AMERICA/LOS ANGELES")
    func headerName(for tz: TimeZone? = nil) -> String {
        let target = tz ?? currentDeviceTimeZone
        return target.identifier.replacingOccurrences(of: "_", with: " ").uppercased()
    }
    
    /// Current time formatted in the US timezone (e.g. "11:48 PM PST")
    func currentFormattedTime(for tz: TimeZone? = nil) -> String {
        let target = tz ?? currentDeviceTimeZone
        let formatter = DateFormatter()
        formatter.timeZone = target
        formatter.locale = Locale(identifier: "en_US")
        formatter.dateFormat = "h:mm a"
        let timeStr = formatter.string(from: Date())
        let abbrev = abbreviation(for: target)
        return "\(timeStr) \(abbrev)"
    }
    
    /// Formatted store hours string with live time in the store's timezone
    func storeHoursLiveString(storeName: String, openTime: String, closeTime: String) -> String {
        let tz = timeZone(forStore: storeName)
        let liveTime = currentFormattedTime(for: tz)
        return "\(openTime) - \(closeTime) store time · now \(liveTime)"
    }
    
    /// Generates dynamic schedule dates starting from Today in the active timezone
    func generateScheduleDates(count: Int = 4, for tz: TimeZone? = nil) -> [OrderScheduleDateItem] {
        let target = tz ?? currentDeviceTimeZone
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = target
        let now = Date()
        var items: [OrderScheduleDateItem] = []
        
        for i in 0..<count {
            guard let date = calendar.date(byAdding: .day, value: i, to: now) else { continue }
            let title: String
            if i == 0 {
                title = "Today"
            } else if i == 1 {
                title = "Tomorrow"
            } else {
                let formatter = DateFormatter()
                formatter.timeZone = target
                formatter.locale = Locale(identifier: "en_US")
                formatter.dateFormat = "EEE M/d"
                title = formatter.string(from: date)
            }
            items.append(OrderScheduleDateItem(id: i, title: title, subtitle: "58 times"))
        }
        return items
    }
    
    /// Formats scheduled Date & Time for display in HomeView
    func formatScheduledWhen(dateTitle: String, slotStartTime: String, slotEndTime: String? = nil) -> String {
        if let end = slotEndTime, !end.isEmpty {
            return "\(dateTitle), \(slotStartTime) - \(end)"
        } else {
            return "\(dateTitle), \(slotStartTime)"
        }
    }
}

// MARK: - Global Convenience Helpers

enum AppTime {
    static var timeZone: TimeZone {
        AppTimeManager.shared.currentDeviceTimeZone
    }
    
    static var timeZoneAbbreviation: String {
        AppTimeManager.shared.abbreviation()
    }
    
    static func nowFormatted(for tz: TimeZone? = nil) -> String {
        AppTimeManager.shared.currentFormattedTime(for: tz)
    }
    
    static func scheduleDates(for tz: TimeZone? = nil) -> [OrderScheduleDateItem] {
        AppTimeManager.shared.generateScheduleDates(for: tz)
    }
    
    static func scheduleString(dateTitle: String, slotStartTime: String, slotEndTime: String? = nil) -> String {
        AppTimeManager.shared.formatScheduledWhen(dateTitle: dateTitle, slotStartTime: slotStartTime, slotEndTime: slotEndTime)
    }
}
