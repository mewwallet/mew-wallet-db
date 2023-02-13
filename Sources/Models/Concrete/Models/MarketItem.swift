//
//  File.swift
//  
//
//  Created by macbook on 1.02.2023.
//

import Foundation

import Foundation
import SwiftProtobuf

public struct MarketItem: Equatable {
  public weak var database: WalletDB? = MEWwalletDBImpl.shared
  var _wrapped: _MarketItem
  
  var marketCap: Decimal {
    Decimal(hex: _wrapped.marketCap)
  }

  // MARK: - Lifecycle
  
  public init(
    circulatingSupply: Decimal?,
    contractAddress: String?,
    marketCap: Decimal?,
    totalSupply: Decimal?,
    volume24h: Decimal?,
    database: WalletDB? = nil
  ) {
    self.database = database ?? MEWwalletDBImpl.shared
    
    self._wrapped = .with {
      if let circulatingSupply {
        $0.circulatingSupply = circulatingSupply.hexString
      }
      if let contractAddress {
        $0.contractAddress = contractAddress
      }
      
      if let marketCap {
        $0.marketCap = marketCap.hexString
      }
      if let totalSupply {
        $0.totalSupply = totalSupply.hexString
      }
      if let volume24h {
        $0.volume24H = volume24h.hexString
      }
    }
  }
  
  init(database: WalletDB? = nil, _wrapped: _MarketItem) {
    self._wrapped = _wrapped
  }
}

// MARK: - MarketMoversItem + Equitable

public extension MarketItem {
  static func ==(lhs: MarketItem, rhs: MarketItem) -> Bool {
    return lhs._wrapped == rhs._wrapped
  }
}
