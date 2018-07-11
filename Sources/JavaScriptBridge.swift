//
//  JavaScriptBridge.swift
//  RRuleSwift
//
//  Created by Xin Hong on 16/3/28.
//  Copyright © 2016年 Teambition. All rights reserved.
//

import EventKit
import Foundation

internal struct JavaScriptBridge {

    internal static func rrulejs() -> String? {

        guard let libPath: String = Bundle(identifier: "Teambition.RRuleSwift-iOS")?.path(forResource: "rrule", ofType: "js") ??
            Bundle.main.path(forResource: "rrule", ofType: "js") else {
                return nil
        }

        do {
            return try String(contentsOfFile: libPath)
        } catch _ {
            return nil
        }
    }
}

internal extension RecurrenceFrequency {

    fileprivate func toJSONFrequency() -> String {
        switch self {
        case .secondly: return "RRule.SECONDLY"
        case .minutely: return "RRule.MINUTELY"
        case .hourly: return "RRule.HOURLY"
        case .daily: return "RRule.DAILY"
        case .weekly: return "RRule.WEEKLY"
        case .monthly: return "RRule.MONTHLY"
        case .yearly: return "RRule.YEARLY"
        }
    }
}

internal extension EKWeekday {

    fileprivate func toJSONSymbol() -> String {
        switch self {
        case .monday: return "RRule.MO"
        case .tuesday: return "RRule.TU"
        case .wednesday: return "RRule.WE"
        case .thursday: return "RRule.TH"
        case .friday: return "RRule.FR"
        case .saturday: return "RRule.SA"
        case .sunday: return "RRule.SU"
        }
    }
}

internal extension RecurrenceRule {

    internal func toJSONString(endless endlessRecurrenceCount: Int) -> String {

        var jsonString: String = "freq: \(frequency.toJSONFrequency()),"
        jsonString += "interval: \(max(1, interval)),"
        jsonString += "wkst: \(firstDayOfWeek.toJSONSymbol()),"
        jsonString += "dtstart: new Date('\(RRule.ISO8601DateFormatter.string(from: startDate))'),"

        if let endDate: Date = recurrenceEnd?.endDate {
            jsonString += "until: new Date('\(RRule.ISO8601DateFormatter.string(from: endDate))'),"
        } else if let count: Int = recurrenceEnd?.occurrenceCount {
            jsonString += "count: \(count),"
        } else {
            jsonString += "count: \(endlessRecurrenceCount),"
        }

        let bysetposStrings: [String] = bysetpos.compactMap { (setpo) -> String? in
            guard (-366...366 ~= setpo) && (setpo != 0) else {
                return nil
            }
            return String(setpo)
        }

        if !bysetposStrings.isEmpty {
            jsonString += "bysetpos: [\(bysetposStrings.joined(separator: ","))],"
        }

        let byyeardayStrings: [String] = byyearday.compactMap { (yearday) -> String? in
            guard (-366...366 ~= yearday) && (yearday != 0) else {
                return nil
            }
            return String(yearday)
        }

        if !byyeardayStrings.isEmpty {
            jsonString += "byyearday: [\(byyeardayStrings.joined(separator: ","))],"
        }

        let bymonthStrings: [String] = bymonth.compactMap { (month) -> String? in
            guard 1...12 ~= month else {
                return nil
            }
            return String(month)
        }

        if !bymonthStrings.isEmpty {
            jsonString += "bymonth: [\(bymonthStrings.joined(separator: ","))],"
        }

        let byweeknoStrings: [String] = byweekno.compactMap { (weekno) -> String? in
            guard (-53...53 ~= weekno) && (weekno != 0) else {
                return nil
            }
            return String(weekno)
        }

        if !byweeknoStrings.isEmpty {
            jsonString += "byweekno: [\(byweeknoStrings.joined(separator: ","))],"
        }

        let bymonthdayStrings: [String] = bymonthday.compactMap { (monthday) -> String? in
            guard (-31...31 ~= monthday) && (monthday != 0) else {
                return nil
            }
            return String(monthday)
        }

        if !bymonthdayStrings.isEmpty {
            jsonString += "bymonthday: [\(bymonthdayStrings.joined(separator: ","))],"
        }

        let byweekdayJSSymbols: [String] = byweekday.map({ (weekday) -> String in
            return weekday.toJSONSymbol()
        })

        if !byweekdayJSSymbols.isEmpty {
            jsonString += "byweekday: [\(byweekdayJSSymbols.joined(separator: ","))],"
        }

        let byhourStrings: [String] = byhour.map({ (hour) -> String in
            return String(hour)
        })

        if !byhourStrings.isEmpty {
            jsonString += "byhour: [\(byhourStrings.joined(separator: ","))],"
        }

        let byminuteStrings: [String] = byminute.map({ (minute) -> String in
            return String(minute)
        })

        if !byminuteStrings.isEmpty {
            jsonString += "byminute: [\(byminuteStrings.joined(separator: ","))],"
        }

        let bysecondStrings: [String] = bysecond.map({ (second) -> String in
            return String(second)
        })

        if !bysecondStrings.isEmpty {
            jsonString += "bysecond: [\(bysecondStrings.joined(separator: ","))]"
        }

        if String(jsonString.suffix(from: jsonString.index(jsonString.endIndex, offsetBy: -1))) == "," {
            jsonString.remove(at: jsonString.index(jsonString.endIndex, offsetBy: -1))
        }

        return jsonString
    }
}
