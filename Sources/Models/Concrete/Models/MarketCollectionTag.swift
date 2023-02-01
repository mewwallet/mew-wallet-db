//
//  File.swift
//  
//
//  Created by macbook on 1.02.2023.
//

import Foundation

public struct MarketCollectionTag: Equatable {
  public weak var database: WalletDB? = MEWwalletDBImpl.shared
  var _wrapped: _MarketCollectionTag
  var _chain: MDBXChain

  // MARK: - Lifecycle
  
  public init(
    chain: String,
    localizationKey: String?,
    title: String?,
    database: WalletDB? = nil
  ) {
    self.database = database ?? MEWwalletDBImpl.shared
    self._chain = .init(rawValue: chain)
    
    self._wrapped = .with {
      $0.chain = chain
      if let localizationKey {
        $0.localizationKey = localizationKey
      }
      if let title {
        $0.title = title
      }
    }
  }
}

// MARK: - MarketMoversItem + Equitable

public extension MarketCollectionTag {
  static func ==(lhs: MarketCollectionTag, rhs: MarketCollectionTag) -> Bool {
    return lhs._chain == rhs._chain &&
           lhs._wrapped == rhs._wrapped
  }
}
