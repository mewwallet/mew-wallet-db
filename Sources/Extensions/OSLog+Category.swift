//
//  File.swift
//  
//
//  Created by Mikhail Nikanorov on 3/3/22.
//

import Foundation
import OSLog

extension OSLog {
  enum Service: String {
    case lifecycle  = "lifecycle"
    case table      = "table"
    case write      = "write"
    case read       = "read"
  }
  
  static func info(_ service: Service) -> OSLog {
#if DEBUG
    return OSLog(subsystem: "com.myetherwallet.mew-wallet-db", category: service.rawValue)
#else
    return .disabled
#endif
  }
  
  static func error(_ service: Service) -> OSLog {
    return OSLog(subsystem: "com.myetherwallet.mew-wallet-db", category: service.rawValue)
  }
}
