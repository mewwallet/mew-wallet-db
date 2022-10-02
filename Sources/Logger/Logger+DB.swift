//
//  File.swift
//  
//
//  Created by Mikhail Nikanorov on 3/3/22.
//

import Foundation
import mew_wallet_ios_extensions
import os

extension Logger {
  fileprivate static let _debug = false
  
  enum Service: String {
    case lifecycle                = "db.lifecycle"
    case table                    = "db.table"
    case write                    = "db.write"
    case read                     = "db.read"
  }
  
  static func `for`(_ service: Logger.Service) -> Logger {
    return Logger(subsystem: "com.myetherwallet.mew-wallet-db", category: service.rawValue)
  }
  
  // MARK: - Logger + Convenient
  
  // swiftlint:disable line_length opening_brace
  static func trace(_ service: Logger.Service, _ error: Error)        { Logger.for(service).trace(error: error) }
  static func debug(_ service: Logger.Service, _ error: Error)        { _debug ? Logger.for(service).debug(error: error) : () }
  static func info(_ service: Logger.Service, _ error: Error)         { Logger.for(service).info(error: error) }
  static func notice(_ service: Logger.Service, _ error: Error)       { Logger.for(service).notice(error: error) }
  static func warning(_ service: Logger.Service, _ error: Error)      { Logger.for(service).warning(error: error) }
  static func error(_ service: Logger.Service, _ error: Error)        { Logger.for(service).error(error: error) }
  static func critical(_ service: Logger.Service, _ error: Error)     { Logger.for(service).critical(error: error) }
  
  static func trace(_ service: Logger.Service, _ message: String)     { Logger.for(service).trace(message: message) }
  static func debug(_ service: Logger.Service, _ message: String)     { _debug ? Logger.for(service).debug(message: message) : () }
  static func info(_ service: Logger.Service, _ message: String)      { Logger.for(service).info(message: message) }
  static func notice(_ service: Logger.Service, _ message: String)    { Logger.for(service).notice(message: message) }
  static func warning(_ service: Logger.Service, _ message: String)   { Logger.for(service).warning(message: message) }
  static func error(_ service: Logger.Service, _ message: String)     { Logger.for(service).error(message: message) }
  static func critical(_ service: Logger.Service, _ message: String)  { Logger.for(service).critical(message: message) }
  
  static func trace(service: Logger.Service, file: String = #fileID, line: Int = #line, function: String = #function, _ error: Error)         { Logger.for(service).trace(file: file, line: line, function: function, message: error.localizedDescription) }
  static func debug(service: Logger.Service, file: String = #fileID, line: Int = #line, function: String = #function, _ error: Error)         { _debug ? Logger.for(service).debug(file: file, line: line, function: function, message: error.localizedDescription) : () }
  static func info(service: Logger.Service, file: String = #fileID, line: Int = #line, function: String = #function, _ error: Error)          { Logger.for(service).info(file: file, line: line, function: function, message: error.localizedDescription) }
  static func notice(service: Logger.Service, file: String = #fileID, line: Int = #line, function: String = #function, _ error: Error)        { Logger.for(service).notice(file: file, line: line, function: function, message: error.localizedDescription) }
  static func warning(service: Logger.Service, file: String = #fileID, line: Int = #line, function: String = #function, _ error: Error)       { Logger.for(service).warning(file: file, line: line, function: function, message: error.localizedDescription) }
  static func error(service: Logger.Service, file: String = #fileID, line: Int = #line, function: String = #function, _ error: Error)         { Logger.for(service).error(file: file, line: line, function: function, message: error.localizedDescription) }
  static func critical(service: Logger.Service, file: String = #fileID, line: Int = #line, function: String = #function, _ error: Error)      { Logger.for(service).critical(file: file, line: line, function: function, message: error.localizedDescription) }
  
  static func trace(service: Logger.Service, file: String = #fileID, line: Int = #line, function: String = #function, _ message: String)      { Logger.for(service).trace(file: file, line: line, function: function, message: message) }
  static func debug(service: Logger.Service, file: String = #fileID, line: Int = #line, function: String = #function, _ message: String)      { _debug ? Logger.for(service).debug(file: file, line: line, function: function, message: message) : () }
  static func info(service: Logger.Service, file: String = #fileID, line: Int = #line, function: String = #function, _ message: String)       { Logger.for(service).info(file: file, line: line, function: function, message: message) }
  static func notice(service: Logger.Service, file: String = #fileID, line: Int = #line, function: String = #function, _ message: String)     { Logger.for(service).notice(file: file, line: line, function: function, message: message) }
  static func warning(service: Logger.Service, file: String = #fileID, line: Int = #line, function: String = #function, _ message: String)    { Logger.for(service).warning(file: file, line: line, function: function, message: message) }
  static func error(service: Logger.Service, file: String = #fileID, line: Int = #line, function: String = #function, _ message: String)      { Logger.for(service).error(file: file, line: line, function: function, message: message) }
  static func critical(service: Logger.Service, file: String = #fileID, line: Int = #line, function: String = #function, _ message: String)   { Logger.for(service).critical(file: file, line: line, function: function, message: message) }
  // swiftlint:enable line_length opening_brace
}
