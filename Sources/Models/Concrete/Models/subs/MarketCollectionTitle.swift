//
//  File.swift
//  
//
//  Created by macbook on 13.02.2023.
//

import Foundation

public struct MarketCollectionTitle: MDBXBackedObject {
  public weak var database: WalletDB?
  var _wrapped: _MarketCollectionTitle
}

extension MarketCollectionTitle {
  
  // MARK: - MarketCollectionTitle
  
  public var text: String { self._wrapped.text }
  public var localizationKey: String { self._wrapped.localizationKey }
}

// MARK: - MarketCollectionTitle + Equatable

extension MarketCollectionTitle {
  public static func == (lhs: MarketCollectionTitle, rhs: MarketCollectionTitle) -> Bool {
    lhs._wrapped == rhs._wrapped
  }
}
