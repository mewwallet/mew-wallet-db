//
//  File.swift
//  
//
//  Created by macbook on 1.02.2023.
//

import Foundation
import SwiftProtobuf

public struct MarketMoversItem: Equatable {
  public weak var database: WalletDB? = MEWwalletDBImpl.shared
  var _wrapped: _MarketMoversItem

  // MARK: - Lifecycle
  
  public init(
    contractAddress: String?,
    database: WalletDB? = nil
  ) {
    self.database = database ?? MEWwalletDBImpl.shared
    
    self._wrapped = .with {
      if let contractAddress {
        $0.contractAddress = contractAddress
      }
    }
  }
}

// MARK: - MarketMoversItem + Equitable

public extension MarketMoversItem {
  static func ==(lhs: MarketMoversItem, rhs: MarketMoversItem) -> Bool {
    return lhs._wrapped == rhs._wrapped
  }
}
