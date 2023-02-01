//
//  File.swift
//  
//
//  Created by macbook on 1.02.2023.
//

import Foundation
import SwiftProtobuf

public struct MarketMoversItem: Equatable {
  public weak var database: WalletDB? = MEWwalletDBImpl.shared
  var _wrapped: _MarketMoversItem
  var _chain: MDBXChain

  // MARK: - Lifecycle
  
  public init(
    chain: String,
    contractAddress: String?,
    icon: String?,
    iconPng: String?,
    name: String?,
    price: Decimal?,
    priceChange: Decimal?,
    symbol: String?,
    timestamp: Date?,
    type: Int64,
    database: WalletDB? = nil
  ) {
    self.database = database ?? MEWwalletDBImpl.shared
    self._chain = .init(rawValue: chain)
    
    self._wrapped = .with {
      $0.chain = chain
      if let contractAddress {
        $0.contractAddress = contractAddress
      }
      if let icon {
        $0.icon = icon
      }
      if let iconPng {
        $0.iconPng = iconPng
      }
      if let name {
        $0.name = name
      }
      if let priceChange {
        $0.priceChange = priceChange.hexString
      }
      if let symbol {
        $0.symbol = symbol
      }
      if let timestamp {
        $0.timestamp = .init(date: timestamp)
      }
      $0.type = type
    }
  }
}

// MARK: - MarketMoversItem + Equitable

public extension MarketMoversItem {
  static func ==(lhs: MarketMoversItem, rhs: MarketMoversItem) -> Bool {
    return lhs._chain == rhs._chain &&
           lhs._wrapped == rhs._wrapped
  }
}
