//
//  File.swift
//  
//
//  Created by Mikhail Nikanorov on 9/29/22.
//

import Foundation
import SwiftProtobuf
 
public struct SwapListV4Wrapper: MDBXWrapperObject {
  var _chain: MDBXChain
  var _wrapped: _SwapListV4Wrapper
  public weak var database: WalletDB?
  
  public init(jsonString: String, chain: MDBXChain) throws {
    var options = JSONDecodingOptions()
    options.ignoreUnknownFields = true
    self._chain = chain
    self._wrapped = try _SwapListV4Wrapper(jsonString: jsonString, options: options)
  }
  
  public init(jsonData: Data, chain: MDBXChain) throws {
    self._chain = chain
    var options = JSONDecodingOptions()
    options.ignoreUnknownFields = true
    self._wrapped = try _SwapListV4Wrapper(jsonUTF8Data: jsonData, options: options)
  }
}

// MARK: - SwapListV4Wrapper + Properties

extension SwapListV4Wrapper {
  
  // MARK: - Properties
  
  public var tokens: [TokenMeta] {
    self._wrapped.tokens.map({ $0.wrapped(_chain) })
  }

  public var tokens_dexItems: [DexItem] {
    self._wrapped.tokens.enumerated().map { (offset, token) in
      let dex = _DexItem.with {
        $0.contractAddress = token.contractAddress
      }
      var dexItem = DexItem(dex, chain: _chain)
      dexItem.order = UInt16(clamping: offset)
      return dexItem
    }
  }
  
  public var featured_dexItems: [DexItem] {
    self._wrapped.featured.enumerated().map { (offset, token) in
      let dex = _DexItem.with {
        $0.contractAddress = token.contractAddress
      }
      var dexItem = DexItem(dex, chain: _chain)
      dexItem.order = UInt16(clamping: offset)
      return dexItem
    }
  }
}

// MARK: - SwapListV4Wrapper + ProtoWrappedMessage

extension _SwapListV4Wrapper: ProtoWrappedMessage {
  func wrapped(_ chain: MDBXChain) -> SwapListV4Wrapper {
    return SwapListV4Wrapper(self, chain: chain)
  }
}

// MARK: - SwapListV4Wrapper + ProtoWrapper

extension SwapListV4Wrapper: ProtoWrapper {
  init(_ wrapped: _SwapListV4Wrapper, chain: MDBXChain) {
    self._chain = chain
    self._wrapped = wrapped
  }
}
