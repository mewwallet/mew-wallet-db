//
//  File.swift
//  
//
//  Created by macbook on 1.02.2023.
//

import Foundation
import SwiftProtobuf

public struct MarketTopItem: Equatable {
  public weak var database: WalletDB? = MEWwalletDBImpl.shared
  var _wrapped: _MarketTopItem

  // MARK: - Lifecycle
  
  public init(
    contractAddress: String?,
    period: String?,
    price: Decimal?,
    priceChange: Decimal?,
    timestamp: Date?,
    database: WalletDB? = nil
  ) {
    self.database = database ?? MEWwalletDBImpl.shared
    
    self._wrapped = .with {
      if let address = contractAddress {
        $0.contractAddress = address
      }
      if let period = period {
        $0.period = period
      }
      if let price = price {
        $0.price = price.hexString
      }
      if let priceChange = priceChange {
        $0.priceChange = priceChange.hexString
      }
      if let timestamp = timestamp {
        $0.timestamp = .init(date: timestamp)
      }
    }
  }
}

// MARK: - MarketTopItem + Equitable

public extension MarketTopItem {
  static func ==(lhs: MarketTopItem, rhs: MarketTopItem) -> Bool {
    return lhs._wrapped == rhs._wrapped
  }
}
