//
//  File.swift
//  mew-wallet-db
//
//  Created by Mikhail Nikanorov on 9/27/24.
//

import Foundation

extension PurchaseProvider {
  public struct ISO: MDBXBackedObject {
    public weak var database: (any WalletDB)?
    var _chain: MDBXChain
    var _wrapped: _PurchaseProvider._ISO
  }
}

// MARK: - PurchaseProvider.ISO + Properties

extension PurchaseProvider.ISO {

  // MARK: - Properties

  public var buy: Bool { _wrapped.allowed.buy }
  public var sell: Bool { _wrapped.allowed.sell }

}

// MARK: - _PurchaseProvider._ISO + ProtoWrappedMessage

extension _PurchaseProvider._ISO: ProtoWrappedMessage {
  func wrapped(_ chain: MDBXChain) -> PurchaseProvider.ISO {
    return PurchaseProvider.ISO(self, chain: chain)
  }
}

// MARK: - PurchaseProvider.ISO + ProtoWrapper

extension PurchaseProvider.ISO: ProtoWrapper {
  init(_ wrapped: _PurchaseProvider._ISO, chain: MDBXChain) {
    self._chain = chain
    self._wrapped = wrapped
  }
}
