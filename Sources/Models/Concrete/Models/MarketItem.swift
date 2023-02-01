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
  var _chain: MDBXChain
  
  var marketCap: Decimal {
    Decimal(hex: _wrapped.marketCap)
  }

  // MARK: - Lifecycle
  
  public init(
    chain: String,
    circulatingSupply: Decimal?,
    contractAddress: String?,
    index: Int32,
    marketCap: Decimal?,
    totalSupply: Decimal?,
    volume24h: Decimal?,
    database: WalletDB? = nil
  ) {
    self.database = database ?? MEWwalletDBImpl.shared
    self._chain = .init(rawValue: chain)
    
    self._wrapped = .with {
      $0.chain = chain
      if let circulatingSupply {
        $0.circulatingSupply = circulatingSupply.hexString
      }
      if let contractAddress {
        $0.contractAddress = contractAddress
      }
      $0.index = index
      
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
}

// MARK: - MarketMoversItem + Equitable

public extension MarketItem {
  static func ==(lhs: MarketItem, rhs: MarketItem) -> Bool {
    return lhs._chain == rhs._chain &&
           lhs._wrapped == rhs._wrapped
  }
}
