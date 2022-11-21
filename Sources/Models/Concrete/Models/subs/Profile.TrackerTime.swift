//
//  File.swift
//  
//
//  Created by Mikhail Nikanorov on 11/17/22.
//

import Foundation

extension Profile {
  public struct TrackerTime: MDBXBackedObject {
    enum `Type` {
      case unknown
      case daily
      case weekly
    }
    
    public weak var database: WalletDB?
    var _chain: MDBXChain
    var _wrapped: _Profile._Settings._PortfolioTracker._TrackerTime
    var _type: `Type` = .unknown
  }
}

// MARK: - Profile.TrackerTime + Properties

extension Profile.TrackerTime {
  
  // MARK: - Properties
  
  public var timestamp: DateComponents {
    let locale = Locale(identifier: "en_US_POSIX")
    let timeZone: TimeZone = .current
    
    var calendar = Calendar(identifier: .iso8601)
    calendar.timeZone = timeZone
    calendar.locale = locale

    let formatter = DateFormatter()
    formatter.locale = locale
    formatter.calendar = calendar
    formatter.timeZone = timeZone
    formatter.dateFormat = "yyyy-MM-d'T'HH:mmZ"
    
    var timestamp = _wrapped.timestamp
    switch _type {
    case .weekly:
      timestamp = "2022-08-" + timestamp
    case .daily:
      timestamp = "2022-08-1T" + timestamp
    case .unknown:
      return DateComponents(calendar: calendar,
                            timeZone: timeZone,
                            year: 2022,
                            month: 8,
                            day: 1,
                            hour: 12,
                            minute: 0)
    }
    
    guard let dateFrom = formatter.date(from: timestamp) else {
      return DateComponents(calendar: calendar,
                            timeZone: timeZone,
                            year: 2022,
                            month: 8,
                            day: 1,
                            hour: 12,
                            minute: 0)
    }
    
    var components = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: dateFrom)
    components.timeZone = .current
    components.calendar = calendar
    
    return components
  }
  
  public var isEnabled: Bool {
    return _wrapped.enabled
  }
}

// MARK: - _Profile._Settings._PortfolioTracker._TrackerTime + ProtoWrappedMessage

extension _Profile._Settings._PortfolioTracker._TrackerTime: ProtoWrappedMessage {
  func wrapped(_ chain: MDBXChain) -> Profile.TrackerTime {
    return Profile.TrackerTime(self, chain: chain)
  }
}

// MARK: - Profile.PortfolioTracker + ProtoWrapper

extension Profile.TrackerTime: ProtoWrapper {
  init(_ wrapped: _Profile._Settings._PortfolioTracker._TrackerTime, chain: MDBXChain) {
    self._chain = chain
    self._wrapped = wrapped
  }
}
