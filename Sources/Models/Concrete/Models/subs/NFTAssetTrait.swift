//
//  File.swift
//  
//
//  Created by Mikhail Nikanorov on 7/7/22.
//

import Foundation
import mew_wallet_ios_extensions

public struct NFTAssetTrait: MDBXBackedObject, Equatable, Hashable {
  public weak var database: WalletDB?
  var _chain: MDBXChain
  var _wrapped: _NFTAssetTrait
}

// MARK: - NFTAssetTrait + Properties

extension NFTAssetTrait {
  
  // MARK: - Properties
  
  public var trait: String { _wrapped.trait }
  public var count: UInt64 { _wrapped.count }
  public var value: String { _wrapped.value }
  public var percentage: Decimal { Decimal(wrapped: _wrapped.percentage, hex: false) ?? .zero }
}

// MARK: - NFTStats + Hashable
extension NFTAssetTrait {
  public func hash(into hasher: inout Hasher) {
    hasher.combine(_wrapped)
  }
}
// MARK: - NFTStats + Equatable

extension NFTAssetTrait {
  public static func == (lhs: NFTAssetTrait, rhs: NFTAssetTrait) -> Bool {
    lhs._wrapped == rhs._wrapped
  }
}

// MARK: - NFTAssetTrait + ProtoSubWrappedMessage

extension _NFTAssetTrait: ProtoWrappedMessage {
  func wrapped(_ chain: MDBXChain) -> NFTAssetTrait {
    return NFTAssetTrait(self, chain: chain)
  }
}

// MARK: - NFTAssetTrait + ProtoSubWrapper

extension NFTAssetTrait: ProtoWrapper {
  init(_ wrapped: _NFTAssetTrait, chain: MDBXChain) {
    _chain = chain
    _wrapped = wrapped
  }
}
