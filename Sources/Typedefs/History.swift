//
//  File.swift
//  
//
//  Created by Mikhail Nikanorov on 10/4/22.
//

import Foundation

public struct History {
  public enum Status {
    case pending
    case success
    case failed
    
    init(_ swap: HistorySwap.Status) {
      switch swap {
      case .pending: self = .pending
      case .success: self = .success
      case .failed: self = .failed
      }
    }
  }
}
