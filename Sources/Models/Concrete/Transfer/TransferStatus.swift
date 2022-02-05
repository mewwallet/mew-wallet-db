//
//  File.swift
//  
//
//  Created by Nail Galiaskarov on 7/1/21.
//

import Foundation

enum TransferStatusRaw: String {
  case unknown
  case pending
  case success
  case fail
  
  func status() -> TransferStatus {
    switch self {
    case .pending:
      return .pending
    case .success:
      return .success
    case .fail:
      return .failed
    case .unknown:
      return .unknown
    }
  }
}

enum TransferStatus: Int16 {
  case unknown = -1
  case pending
  case success
  case failed
  
  var stringValue: String {
    switch self {
    case .unknown:
      return TransferStatusRaw.unknown.rawValue
    case .pending:
      return TransferStatusRaw.pending.rawValue
    case .success:
      return TransferStatusRaw.success.rawValue
    case .failed:
      return TransferStatusRaw.fail.rawValue
    }
  }
}
