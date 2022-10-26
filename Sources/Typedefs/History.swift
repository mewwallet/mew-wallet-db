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
      case .pending:    self = .pending
      case .success:    self = .success
      case .failed:     self = .failed
      }
    }
    
    init(_ purchase: HistoryPurchase.Status) {
      switch purchase {
      case .complete:   self = .success
      case .completed:  self = .success
      case .processing: self = .pending
      case .waiting:    self = .pending
      case .failed:     self = .failed
      }
    }
    
    var isFinal: Bool {
      return self != .pending
    }
  }
  
  public enum Item {
    case swap(HistorySwap)
    case purchase(HistoryPurchase)
    
    public var status: Status {
      switch self {
      case .swap(let swap):           return swap.status
      case .purchase(let purchase):   return purchase.status
      }
    }
    
    public var timestamp: Date {
      switch self {
      case .swap(let swap):           return swap.timestamp
      case .purchase(let purchase):   return purchase.timestamp
      }
    }
  }
}

// MARK: - History.Item + Comparable

extension History.Item: Comparable {
  /// First group - 'Pending'
  /// Second group - other
  /// Inside the group - by timestamp
  public static func < (lhs: Self, rhs: Self) -> Bool {
    // If equal statuses
    if lhs.status.isFinal == rhs.status.isFinal {
      return lhs.timestamp > rhs.timestamp
    }
    
    return lhs.status == .pending
  }
}

// MARK: - HistoryPurchase + Identifiable

extension History.Item: Identifiable {
  /// The stable identity of the entity associated with this instance.
  public var id: String {
    switch self {
    case .swap(let historySwap):            return historySwap.id
    case .purchase(let historyPurchase):    return historyPurchase.id
    }
  }
}
