//
//  File.swift
//  
//
//  Created by Mikhail Nikanorov on 11/17/22.
//

import Foundation

extension DateComponents {
  func trackerTime(includeDay: Bool) -> (DateComponents, DateFormatter) {
    let locale = Locale(identifier: "en_US_POSIX")
    let timeZone: TimeZone = .current
    
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
