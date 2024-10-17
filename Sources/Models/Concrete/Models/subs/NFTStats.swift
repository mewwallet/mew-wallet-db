//
//  File.swift
//  
//
//  Created by Mikhail Nikanorov on 7/7/22.
//

import Foundation

public struct NFTStats: MDBXBackedObject, Equatable {
  public weak var database: (any WalletDB)?
  var _chain: MDBXChain
  var _wrapped: _NFTStats
}

// MARK: - NFTStats + Properties

extension NFTStats {
  
  // MARK: - Properties
  
  var count: String { self._wrapped.count }
  var owners: String { self._wrapped.owners }
}

// MARK: - NFTStats + Equatable

extension NFTStats {
  public static func == (lhs: NFTStats, rhs: NFTStats) -> Bool {
    lhs._wrapped == rhs._wrapped
  }
}

// MARK: - NFTStats + ProtoWrappedMessage

extension _NFTStats: ProtoWrappedMessage {
  func wrapped(_ chain: MDBXChain) -> NFTStats {
    return NFTStats(self, chain: chain)
  }
}

// MARK: - NFTStats + ProtoWrapper

extension NFTStats: ProtoWrapper {
  init(_ wrapped: _NFTStats, chain: MDBXChain) {
    self._chain = chain
    self._wrapped = wrapped
  }
}
