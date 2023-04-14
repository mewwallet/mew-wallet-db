//
//  File.swift
//  
//
//  Created by macbook on 13.02.2023.
//

import Foundation

public struct MarketCollectionTag: MDBXBackedObject {
  public weak var database: WalletDB?
  var _wrapped: _MarketCollectionTag
}

extension MarketCollectionTag {
  
  // MARK: - MarketCollectionTag
  
  public var title: String { self._wrapped.title }
  public var localizationKey: String { self._wrapped.localizationKey }
}

// MARK: - MarketCollectionTitle + Equatable

extension MarketCollectionTag {
  public static func == (lhs: MarketCollectionTag, rhs: MarketCollectionTag) -> Bool {
    lhs._wrapped == rhs._wrapped
  }
}
