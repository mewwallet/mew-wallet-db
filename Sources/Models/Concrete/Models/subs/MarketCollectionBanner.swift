//
//  File.swift
//  
//
//  Created by macbook on 13.02.2023.
//

import Foundation

public struct MarketCollectionBanner: MDBXBackedObject {
  public weak var database: WalletDB?
  var _wrapped: _MarketCollectionBanner
}

extension MarketCollectionBanner {
  
  // MARK: - MarketCollectionBanner
  
  public var small: String { self._wrapped.small }
  public var big: String { self._wrapped.big }
}

// MARK: - MarketCollectionTitle + Equatable

extension MarketCollectionBanner {
  public static func == (lhs: MarketCollectionBanner, rhs: MarketCollectionBanner) -> Bool {
    lhs._wrapped == rhs._wrapped
  }
}
