//
//  File.swift
//  
//
//  Created by macbook on 1.02.2023.
//

import Foundation
import SwiftProtobuf

public struct MarketTokenMeta: Equatable {
  public weak var database: WalletDB? = MEWwalletDBImpl.shared
  var _wrapped: _MarketTokenMeta
  var _chain: MDBXChain
  
  var price: Decimal {
    return Decimal(hex: _wrapped.price)
  }

  // MARK: - Lifecycle
  
  public init(
    chain: String,
    circulatingSupply: Decimal?,
    contractAddress: String?,
    descriptionLocalizationKey: String?,
    descriptionText: String?,
    entryTitle: String?,
    price: Decimal?,
    rank: Int32,
    timestamp: Date?,
    totalSupply: Decimal?,
    volume24h: Decimal?,
    website: URL?,
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
      if let descriptionLocalizationKey {
        $0.descriptionLocalizationKey = descriptionLocalizationKey
      }
      if let descriptionText {
        $0.descriptionText = descriptionText
      }
      if let entryTitle {
        $0.entryTitle = entryTitle
      }
      if let price {
        $0.price = price.hexString
      }
      $0.rank = rank
      if let timestamp {
        $0.timestamp = .init(date: timestamp)
      }
      if let totalSupply {
        $0.totalSupply = totalSupply.hexString
      }
      if let volume24h {
        $0.volume24H = volume24h.hexString
      }
      if let website {
        $0.website = website.absoluteString
      }
    }
  }
}

// MARK: - MarketTopItem + Equitable

public extension MarketTokenMeta {
  static func ==(lhs: MarketTokenMeta, rhs: MarketTokenMeta) -> Bool {
    return lhs._chain == rhs._chain &&
           lhs._wrapped == rhs._wrapped
  }
}
