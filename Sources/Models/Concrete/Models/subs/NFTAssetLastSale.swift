//
//  File.swift
//  
//
//  Created by Mikhail Nikanorov on 7/7/22.
//

import Foundation
import mew_wallet_ios_extensions

public struct NFTAssetLastSale: MDBXBackedObject, Equatable {
  public weak var database: WalletDB?
  var _chain: MDBXChain
  var _wrapped: _NFTAssetLastSale
  
//  @SubProperty<_TokenMeta, TokenMeta> var _meta: _TokenMeta?
  
  var _metaKey: TokenMetaKey? { TokenMetaKey(data: _wrapped.metaKey) }
  let _meta: MDBXPointer<TokenMetaKey, TokenMeta> = .init(.tokenMeta)
}

// MARK: - NFTAssetLastSale + Properties

extension NFTAssetLastSale {
  
  // MARK: - Relations
  
  public var meta: TokenMeta {
    get throws {
      guard let key = _metaKey else { throw MEWwalletDBError.internalError }
      return try _meta.getData(key: key, policy: .cacheOrLoad, database: self.database)
    }
  }
  
  // MARK: - Properties

  public var rawPrice: Decimal { Decimal(wrapped: _wrapped.price, hex: true) ?? .zero }
  public var price: Decimal {
    guard let exponent = try? -self.meta.decimals else {
      return rawPrice
    }
    let decimals = Decimal(sign: .plus, exponent: exponent, significand: Decimal(1))
    return rawPrice * decimals
  }
}

// MARK: - NFTAssetLastSale + Equitable

public extension NFTAssetLastSale {
  static func ==(lhs: NFTAssetLastSale, rhs: NFTAssetLastSale) -> Bool {
    return lhs._wrapped == rhs._wrapped
  }
}

// MARK: - NFTAssetLastSale + ProtoSubWrappedMessage

extension _NFTAssetLastSale: ProtoWrappedMessage {
  func wrapped(_ chain: MDBXChain) -> NFTAssetLastSale {
    return NFTAssetLastSale(self, chain: chain)
  }
}

// MARK: - NFTAssetLastSale + ProtoWrapper

extension NFTAssetLastSale: ProtoWrapper {
  init(_ wrapped: _NFTAssetLastSale, chain: MDBXChain) {
    _chain = chain
    _wrapped = wrapped
    if _wrapped.hasToken {
      let token = _wrapped.token.wrapped(chain)
      _wrapped.metaKey = token.key.key
      _meta.updateData(token)
      _wrapped.clearToken()
    }
  }
}
