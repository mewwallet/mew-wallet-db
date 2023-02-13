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
  
  var price: Decimal {
    return Decimal(hex: _wrapped.price)
  }

  // MARK: - Lifecycle
  
  public init(
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
    
    self._wrapped = .with {
      if let circulatingSupply {
        $0.circulatingSupply = circulatingSupply.hexString
      }
      if let contractAddress {
        $0.contractAddress = contractAddress
      }
      $0.description_p = .with { object in
        object.localizationKey = descriptionLocalizationKey ?? ""
        object.text = descriptionText ?? ""
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
  
  init(
    database: WalletDB? = nil,
    _wrapped: _MarketTokenMeta
  ) {
    self.database = database ?? MEWwalletDBImpl.shared
    self._wrapped = _wrapped
  }
}

extension MarketTokenMeta {
  var tags: [MarketCollectionTag] {
    self._wrapped.tags.map {
      MarketCollectionTag(database: database, _wrapped: $0)
    }
  }
  
  var description: MarketCollectionTitle {
    return .init(
      database: database,
      _wrapped: _wrapped.description_p
    )
  }
}

// MARK: - MarketTopItem + Equitable

public extension MarketTokenMeta {
  static func ==(lhs: MarketTokenMeta, rhs: MarketTokenMeta) -> Bool {
    return lhs._wrapped == rhs._wrapped
  }
}
