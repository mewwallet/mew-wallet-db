//
//  File.swift
//  
//
//  Created by Mikhail Nikanorov on 7/5/22.
//

import Foundation
import os.signpost

extension OSLog {
  enum Service: String {
    case table      = "table"
    case write      = "write"
    case read       = "read"
  }

  static func signpost(_ service: Service) -> OSLog {
#if DEBUG
    return OSLog(subsystem: "com.myetherwallet.mew-wallet-db", category: service.rawValue)
#else
    return .disabled
#endif
  }
}
