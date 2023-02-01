//
//  File.swift
//  
//
//  Created by macbook on 1.02.2023.
//

import Foundation

public struct MarketCollectionFilter: Equatable {
  public weak var database: WalletDB? = MEWwalletDBImpl.shared
  var _wrapped: _MarketCollectionFilter
  var _chain: MDBXChain

  // MARK: - Lifecycle
  
  public init(
    chain: String,
    localizationKey: String?,
    rank: Int32,
    text: String?,
    database: WalletDB? = nil
  ) {
    self.database = database ?? MEWwalletDBImpl.shared
    self._chain = .init(rawValue: chain)
    
    self._wrapped = .with {
      $0.chain = chain
      if let localizationKey {
        $0.localizationKey = localizationKey
      }
      $0.rank = rank
      if let text {
        $0.text = text
      }
    }
  }
}

// MARK: - MarketCollectionFilter + Equitable

public extension MarketCollectionFilter {
  static func ==(lhs: MarketCollectionFilter, rhs: MarketCollectionFilter) -> Bool {
    return lhs._chain == rhs._chain &&
           lhs._wrapped == rhs._wrapped
  }
}
