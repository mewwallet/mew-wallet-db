//
//  File.swift
//  
//
//  Created by Mikhail Nikanorov on 11/17/22.
//

import Foundation

extension DateComponents {
  /// Specific method for `TrackerTime`
  /// Since weekday is unstable and there's no convenient methods to parse them - we're using `day` as `weekday`
  /// 08/2022 has 1-7 Monday-Sunday, which is good enough
  /// - Parameter includeDay: include or hardcode day (useful for daily and weekly tracker)
  /// - Returns: prepared tuple of `DateComponents` and `DateFormatter` for components
  func trackerTime(includeDay: Bool) -> (DateComponents, DateFormatter) {
    let locale = Locale(identifier: "en_US_POSIX")
    /// We have to use 'fixed timezone', otherwise formatter will lose DST
    let currentTimeZone: TimeZone = .current
    let timeZone = TimeZone(secondsFromGMT: currentTimeZone.secondsFromGMT())!
    
    var calendar = Calendar(identifier: .iso8601)
    calendar.timeZone = timeZone
    calendar.locale = locale

    let formatter = DateFormatter()
    formatter.locale = locale
    formatter.calendar = calendar
    formatter.timeZone = timeZone
    if includeDay {
      formatter.dateFormat = "d'T'HH:mmZ"
    } else {
      formatter.dateFormat = "HH:mmZ"
    }
    
    var components = self
    // Month starts on Monday (iso-8601 == 1)
    components.calendar = calendar
    components.year = 2022
    components.month = 8
    if !includeDay {
      components.day = 1
    }
    components.timeZone = timeZone
    return (components, formatter)
  }
}
