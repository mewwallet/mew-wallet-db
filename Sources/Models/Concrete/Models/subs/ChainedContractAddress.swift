//
//  File.swift
//  
//
//  Created by Mikhail Nikanorov on 12/16/22.
//

import Foundation

extension HistoryPurchase {
  public struct ChainedContractAddress: MDBXBackedObject {
    public weak var database: (any WalletDB)?
    var _chain: MDBXChain
    var _wrapped: _ChainedContractAddress
  }
}

// MARK: - HistoryPurchase.ChainedContractAddress + Properties

extension HistoryPurchase.ChainedContractAddress {

  // MARK: - Properties
  
  public var chain: MDBXChain { MDBXChain(rawValue: _wrapped.chain) }
  public var address: Address { Address(_wrapped.contractAddress) }
}

// MARK: - _ChainedContractAddress + ProtoWrappedMessage

extension _ChainedContractAddress: ProtoWrappedMessage {
  func wrapped(_ chain: MDBXChain) -> HistoryPurchase.ChainedContractAddress {
    return HistoryPurchase.ChainedContractAddress(self, chain: .universal)
  }
}

// MARK: - HistoryPurchase.ChainedContractAddress + ProtoWrapper

extension HistoryPurchase.ChainedContractAddress: ProtoWrapper {
  init(_ wrapped: _ChainedContractAddress, chain: MDBXChain) {
    self._chain = .universal
    self._wrapped = wrapped
  }
}
