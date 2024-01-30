//
//  File.swift
//  
//
//  Created by Mikhail Nikanorov on 9/13/23.
//

import Foundation

public struct EnergyNFTTransfer: MDBXBackedObject, Equatable {
  public weak var database: WalletDB?
  var _chain: MDBXChain
  var _wrapped: _EnergyNFTTransfer
  
  public init(tokenId: Int,
              hash: String,
              address: Address,
              timestamp: Date,
              database: WalletDB? = nil) {
    self.database = database ?? MEWwalletDBImpl.shared
    self._chain = .eth
    self._wrapped = .with {
      $0.tokenID = String(tokenId)
      $0.hash = hash
      $0.address = address.rawValue
      $0.timestamp = .init(date: timestamp)
    }
  }
}

// MARK: - EnergyNFTTransfer + Properties

extension EnergyNFTTransfer {
  
  // MARK: - Properties
  
  public var tokenID: Int { Int(_wrapped.tokenID, radix: 10) ?? 0 }
  public var hash: String { _wrapped.hash }
  public var address: Address { .unknown(_wrapped.address) }
  public var timestamp: Date? { _wrapped.hasTimestamp ? _wrapped.timestamp.date : nil }
}

// MARK: - EnergyNFTTransfer + Equatable

extension EnergyNFTTransfer {
  public static func == (lhs: EnergyNFTTransfer, rhs: EnergyNFTTransfer) -> Bool {
    lhs._wrapped == rhs._wrapped
  }
}

// MARK: - EnergyNFTTransfer + ProtoWrappedMessage

extension _EnergyNFTTransfer: ProtoWrappedMessage {
  func wrapped(_ chain: MDBXChain) -> EnergyNFTTransfer {
    return EnergyNFTTransfer(self, chain: chain)
  }
}

// MARK: - EnergyNFTTransfer + ProtoWrapper

extension EnergyNFTTransfer: ProtoWrapper {
  init(_ wrapped: _EnergyNFTTransfer, chain: MDBXChain) {
    self._chain = chain
    self._wrapped = wrapped
  }
}
