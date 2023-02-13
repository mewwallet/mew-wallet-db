//
//  File.swift
//  
//
//  Created by macbook on 13.02.2023.
//

import Foundation

public struct MarketCollectionFilter: MDBXBackedObject {
  public weak var database: WalletDB?
  var _wrapped: _MarketCollectionFilter
}

extension MarketCollectionFilter {
  
  // MARK: - MarketCollectionFilter
  
  public var tags: [MarketCollectionTag] {
    self._wrapped.tags.map {
      MarketCollectionTag(database: database, _wrapped: $0)
    }
  }
  
  public var title: MarketCollectionTitle? {
    guard self._wrapped.hasTitle else {
      return nil
    }
    return .init(
      database: database,
      _wrapped: _wrapped.title
    )
  }
}

// MARK: - MarketCollectionTitle + Equatable

extension MarketCollectionFilter {
  public static func == (lhs: MarketCollectionFilter, rhs: MarketCollectionFilter) -> Bool {
    lhs._wrapped == rhs._wrapped
  }
}
