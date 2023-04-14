//
//  File.swift
//  
//
//  Created by macbook on 13.02.2023.
//

import Foundation

public struct MarketCollectionAction: MDBXBackedObject {
  public weak var database: WalletDB?
  var _wrapped: _MarketCollectionAction
}

extension MarketCollectionAction {
  
  // MARK: - MarketCollectionBanner
  
  public var text: String { self._wrapped.text }
  public var localizationKey: String { self._wrapped.localizationKey }
  public var url: URL? {
    guard _wrapped.hasURL else { return nil }
    return URL(string: _wrapped.url)
  }
}

// MARK: - MarketCollectionTitle + Equatable

extension MarketCollectionAction {
  public static func == (lhs: MarketCollectionAction, rhs: MarketCollectionAction) -> Bool {
    lhs._wrapped == rhs._wrapped
  }
}
