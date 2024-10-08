//
//  File.swift
//  mew-wallet-db
//
//  Created by Mikhail Nikanorov on 9/27/24.
//

import Foundation
import SwiftProtobuf

public struct PurchaseInfoV5Wrapper: MDBXWrapperObject {
  var _chain: MDBXChain
  var _wrapped: _PurchaseInfoV5Wrapper
  public weak var database: (any WalletDB)?

  public init(jsonString: String, chain: MDBXChain) throws {
    var options = JSONDecodingOptions()
    options.ignoreUnknownFields = true
    self._chain = chain
    self._wrapped = try _PurchaseInfoV5Wrapper(jsonString: jsonString, options: options)
  }

  public init(jsonData: Data, chain: MDBXChain) throws {
    self._chain = chain
    var options = JSONDecodingOptions()
    options.ignoreUnknownFields = true
    self._wrapped = try _PurchaseInfoV5Wrapper(jsonUTF8Data: jsonData, options: options)
  }
}

// MARK: - PurchaseInfoV5Wrapper + Properties

extension PurchaseInfoV5Wrapper {

  // MARK: - Properties

  public var providers: [PurchaseProvider] {
    self.chains.flatMap { chain in
      self._wrapped.providers.enumerated().map { element in
        var provider = element.element.wrapped(chain)
        provider.order = UInt16(clamping: element.offset)
        return provider
      }
    }
  }

  public var assets: [PurchaseToken] {
    self._wrapped.assets.flatMap { element in
      let chain = MDBXChain(rawValue: element.chain)
      return element.assets.enumerated().map { element in
        var token = element.element.wrapped(chain)
        token.order = UInt16(clamping: element.offset)
        return token
      }
    }
  }

  public var metas: [TokenMeta] {
    self._wrapped.assets.flatMap { element in
      let chain = MDBXChain(rawValue: element.chain)
      let metas: [TokenMeta] = element.assets.compactMap { element in
        guard element.hasMarketData else { return nil }
        return element.marketData.wrapped(chain)
      }
      return metas
    }
  }
  
  var chains: [MDBXChain] {
    self._wrapped.assets
      .filter({ !$0.assets.isEmpty })
      .map({ MDBXChain(rawValue: $0.chain) })
  }
}

// MARK: - PurchaseInfoV5Wrapper + ProtoWrappedMessage

extension _PurchaseInfoV5Wrapper: ProtoWrappedMessage {
  func wrapped(_ chain: MDBXChain) -> PurchaseInfoV5Wrapper {
    return PurchaseInfoV5Wrapper(self, chain: chain)
  }
}

// MARK: - PurchaseInfoV5Wrapper + ProtoWrapper

extension PurchaseInfoV5Wrapper: ProtoWrapper {
  init(_ wrapped: _PurchaseInfoV5Wrapper, chain: MDBXChain) {
    self._chain = chain
    self._wrapped = wrapped
  }
}
