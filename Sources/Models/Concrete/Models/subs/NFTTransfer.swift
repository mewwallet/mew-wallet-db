//
//  File.swift
//  
//
//  Created by Mikhail Nikanorov on 9/27/22.
//

import Foundation

public struct NFTTransfer: MDBXBackedObject, Equatable {
  public weak var database: (any WalletDB)?
  var _chain: MDBXChain
  var _wrapped: _NFTTransfer
}

// MARK: - NFTTransfer + Properties

extension NFTTransfer {
  
  // MARK: - Properties
  
  public var id: String? { self._wrapped.id }
  public var name: String? { self._wrapped.name }
  public var symbol: String? { self._wrapped.symbol }
  var image: String? { self._wrapped.image }
  
  public var url: URL? {
    guard let image = image else { return nil }
    return URL(string: image)
  }
}

// MARK: - NFTTransfer + Equatable

extension NFTTransfer {
  public static func == (lhs: NFTTransfer, rhs: NFTTransfer) -> Bool {
    lhs._wrapped == rhs._wrapped
  }
}

// MARK: - NFTTransfer + ProtoWrappedMessage

extension _NFTTransfer: ProtoWrappedMessage {
  func wrapped(_ chain: MDBXChain) -> NFTTransfer {
    return NFTTransfer(self, chain: chain)
  }
}

// MARK: - NFTTransfer + ProtoWrapper

extension NFTTransfer: ProtoWrapper {
  init(_ wrapped: _NFTTransfer, chain: MDBXChain) {
    self._chain = chain
    self._wrapped = wrapped
  }
}
