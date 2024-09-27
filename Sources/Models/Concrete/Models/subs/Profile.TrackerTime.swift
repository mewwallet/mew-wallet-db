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
    
    public weak var database: (any WalletDB)?
    var _chain: MDBXChain
    var _wrapped: _Profile._Settings._PortfolioTracker._TrackerTime
    var _type: `Type` = .unknown
  }
}

// MARK: - Profile.TrackerTime + Properties

extension Profile.TrackerTime {
  
  // MARK: - Properties
  
  public var timestamp: DateComponents {
    /// Get current timestamp
    let timestamp = _wrapped.timestamp
    
    /// Prepare locale
    let locale = Locale(identifier: "en_US_POSIX")
    
    /// Prepare calendar with fixed timezone
    var calendar = Calendar(identifier: .iso8601)
    calendar.timeZone = .current
    calendar.locale = locale
    
    /// Fallback date components
    let fallback = DateComponents(calendar: calendar,
                                  timeZone: .current,
                                  year: 2022,
                                  month: 8,
                                  day: 1,
                                  hour: 8,
                                  minute: 0)
    
    /// Based on different type we might need day or might not
    
    var components: DateComponents
    
    switch _type {
    case .weekly where timestamp.count >= 7:
      /// Parse string,
      /// f.e. `3T11:30+04:00`
      
      /// Manually parse string ignoring timezone
      let dayString = timestamp.prefix(1)
      let hourString = timestamp.dropFirst(2).prefix(2)
      let minuteString = timestamp.dropFirst(5).prefix(2)
      
      guard let day = Int(dayString),
            let hour = Int(hourString),
            var minute = Int(minuteString) else {
        components = fallback
        break
      }
      /// We can support only 15 minutes step
      if minute % 15 != 0 {
        minute = (minute / 15) * 15
      }
      components = DateComponents(calendar: calendar,
                                  timeZone: .current,
                                  year: 2022,
                                  month: 8,
                                  day: day,
                                  hour: hour,
                                  minute: minute)
      
    case .daily where timestamp.count >= 5:
      /// Parse string,
      /// f.e. `08:30+04:00`
      
      /// Manually parse string ignoring timezone
      let hourString = timestamp.prefix(2)
      let minuteString = timestamp.dropFirst(3).prefix(2)
      
      guard let hour = Int(hourString),
            var minute = Int(minuteString) else {
        components = fallback
        break
      }
      /// We can support only 15 minutes step
      if minute % 15 != 0 {
        minute = (minute / 15) * 15
      }
      components = DateComponents(calendar: calendar,
                                  timeZone: .current,
                                  year: 2022,
                                  month: 8,
                                  day: 1,
                                  hour: hour,
                                  minute: minute)
    default:
      components = fallback
    }
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
