//
//  Iterators.swift
//  RRuleSwift
//
//  Created by Xin Hong on 16/3/29.
//  Copyright © 2016年 Teambition. All rights reserved.
//

import Foundation
import JavaScriptCore

public struct Iterator {

    public static let endlessRecurrenceCount: Int = 500

    internal static let rruleContext: JSContext? = {
        guard let rrulejs: String = JavaScriptBridge.rrulejs() else {
            return nil
        }
        let context: JSContext = JSContext()
        context.exceptionHandler = { context, exception in
            print("[RRuleSwift] rrule.js error: \(String(describing: exception))")
        }
        _ = context.evaluateScript(rrulejs)
        return context
    }()
}

public extension RecurrenceRule {

    public func allOccurrences(endless endlessRecurrenceCount: Int = Iterator.endlessRecurrenceCount) -> [Date] {

        if JavaScriptBridge.rrulejs() == nil { return [] }

        let ruleJSONString: String = toJSONString(endless: endlessRecurrenceCount)
        _ = Iterator.rruleContext?.evaluateScript("var rule = new RRule({ \(ruleJSONString) })")
        guard var occurrences: [Date] = Iterator.rruleContext?.evaluateScript("rule.all()").toArray() as? [Date] else {
            return []
        }

        if let rdates: [Date] = rdate?.dates {
            occurrences.append(contentsOf: rdates)
        }

        if let exdates: [Date] = exdate?.dates, let component: Calendar.Component = exdate?.component {
            for occurrence: Date in occurrences {
                for exdate: Date in exdates {
                    if calendar.isDate(occurrence, equalTo: exdate, toGranularity: component) {
                        let index: Int = occurrences.index(of: occurrence)!
                        occurrences.remove(at: index)
                        break
                    }
                }
            }
        }

        return occurrences.sorted { $0.isBeforeOrSame(with: $1) }
    }

    public func occurrences(between date: Date, and otherDate: Date, endless endlessRecurrenceCount: Int = Iterator.endlessRecurrenceCount) -> [Date] {

        if JavaScriptBridge.rrulejs() == nil { return [] }

        let beginDate: Date = date.isBeforeOrSame(with: otherDate) ? date : otherDate
        let untilDate: Date = otherDate.isAfterOrSame(with: date) ? otherDate : date
        let beginDateJSON: String = RRule.ISO8601DateFormatter.string(from: beginDate)
        let untilDateJSON: String = RRule.ISO8601DateFormatter.string(from: untilDate)

        let ruleJSONString: String = toJSONString(endless: endlessRecurrenceCount)
        _ = Iterator.rruleContext?.evaluateScript("var rule = new RRule({ \(ruleJSONString) })")
        guard var occurrences: [Date] = Iterator.rruleContext?.evaluateScript("rule.between(new Date('\(beginDateJSON)'), new Date('\(untilDateJSON)'))").toArray() as? [Date] else {
            return []
        }

        if let rdates: [Date] = rdate?.dates {
            occurrences.append(contentsOf: rdates)
        }

        if let exdates: [Date] = exdate?.dates, let component: Calendar.Component = exdate?.component {
            for occurrence: Date in occurrences {
                for exdate: Date in exdates {
                    if calendar.isDate(occurrence, equalTo: exdate, toGranularity: component) {
                        let index: Int = occurrences.index(of: occurrence)!
                        occurrences.remove(at: index)
                        break
                    }
                }
            }
        }

        return occurrences.sorted { $0.isBeforeOrSame(with: $1) }
    }
}
