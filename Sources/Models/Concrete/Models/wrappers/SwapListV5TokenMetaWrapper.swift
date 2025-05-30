//
//  File.swift
//  mew-wallet-db
//
//  Created by Mikhail Nikanorov on 1/13/25.
//

import Foundation
import SwiftProtobuf
 
public struct SwapListV5TokenMetaWrapper: MDBXWrapperObject {
  var _chain: MDBXChain
  var _wrapped: _SwapListV5TokenMetaWrapper
  public weak var database: (any WalletDB)?
  
  public init(jsonString: String, chain: MDBXChain) throws {
    var options = JSONDecodingOptions()
    options.ignoreUnknownFields = true
    self._chain = chain
    self._wrapped = try _SwapListV5TokenMetaWrapper(jsonString: jsonString, options: options)
    if self._wrapped.d.isEmpty {
      self._wrapped.d = [Int32](repeating: 18, count: self._wrapped.c.count)
    }
    if self._wrapped.cc.isEmpty {
      self._wrapped.cc = [Int32](repeating: 0, count: self._wrapped.c.count)
    }
  }
  
  public init(jsonData: Data, chain: MDBXChain) throws {
    self._chain = chain
    var options = JSONDecodingOptions()
    options.ignoreUnknownFields = true
    self._wrapped = try _SwapListV5TokenMetaWrapper(jsonUTF8Data: jsonData, options: options)
    if self._wrapped.d.isEmpty {
      self._wrapped.d = [Int32](repeating: 18, count: self._wrapped.c.count)
    }
    if self._wrapped.cc.isEmpty {
      self._wrapped.cc = [Int32](repeating: 0, count: self._wrapped.c.count)
    }
  }
}

// MARK: - SwapListV5TokenMetaWrapper + Properties

extension SwapListV5TokenMetaWrapper {
  
  // MARK: - Properties
  
  public var tokens: [TokenMeta] {
    return self._wrapped.c.enumerated().map { (index, chain) in
      return TokenMeta(
        chain: MDBXChain(rawValue: chain),
        contractAddress: Address(self._wrapped.ca[index]),
        name: self._wrapped.n,
        symbol: self._wrapped.s,
        decimals: self._wrapped.d[index],
        icon: self._wrapped.i,
        price: self._wrapped.p,
        database: database
      )
    }
  }

  public var tokens_dexItems: [DexItem] {
    return zip(self._wrapped.c, self._wrapped.cc)
      .enumerated()
      .map { (index, zipObject) in
        let (chain, crosschain) = zipObject
        return DexItem(
          chain: MDBXChain(rawValue: chain),
          contractAddress: self._wrapped.ca[index],
          name: self._wrapped.n,
          symbol: self._wrapped.s,
          order: nil,
          crosschain: crosschain == 1,
          database: database
        )
      }
  }
  
  public var featured_dexItems: [DexItem] {
    guard !self._wrapped.f.isEmpty else { return [] }
    return zip(self._wrapped.c, self._wrapped.cc)
      .enumerated()
      .compactMap { (index, zipObject) -> DexItem? in
        let (chain, crosschain) = zipObject
        let featuredIndex = self._wrapped.f[index]
        guard featuredIndex != -1 else { return nil }
        return DexItem(
          chain: MDBXChain(rawValue: chain),
          contractAddress: self._wrapped.ca[index],
          name: self._wrapped.n,
          symbol: self._wrapped.s,
          order: UInt16(clamping: featuredIndex),
          crosschain: crosschain == 1,
          database: database
        )
      }
  }
  
  public var crosschain_dexItems: [DexItem] {
    guard !self._wrapped.cc.isEmpty else { return [] }
    return zip(self._wrapped.c, self._wrapped.cc)
      .enumerated()
      .compactMap { (index, zipObject) -> DexItem? in
        let (chain, crosschain) = zipObject
        guard crosschain != 0 else { return nil }
        return DexItem(
          chain: MDBXChain(rawValue: chain),
          contractAddress: self._wrapped.ca[index],
          name: self._wrapped.n,
          symbol: self._wrapped.s,
          order: nil,
          crosschain: true,
          database: database)
      }
  }
}

// MARK: - SwapListV5TokenMetaWrapper + ProtoWrappedMessage

extension _SwapListV5TokenMetaWrapper: ProtoWrappedMessage {
  func wrapped(_ chain: MDBXChain) -> SwapListV5TokenMetaWrapper {
    return SwapListV5TokenMetaWrapper(self, chain: chain)
  }
}

// MARK: - SwapListV5TokenMetaWrapper + ProtoWrapper

extension SwapListV5TokenMetaWrapper: ProtoWrapper {
  init(_ wrapped: _SwapListV5TokenMetaWrapper, chain: MDBXChain) {
    self._chain = chain
    self._wrapped = wrapped
    if self._wrapped.d.isEmpty {
      self._wrapped.d = [Int32](repeating: 18, count: self._wrapped.c.count)
    }
  }
}

extension SwapListV5TokenMetaWrapper {
  public static func array(fromJSONString: String) throws -> [Self] {
    return try _SwapListV5TokenMetaWrapper.array(fromJSONString: fromJSONString).map({ $0.wrapped(.evm) })
  }
  
  public static func array(fromJSONUTF8Data: Data) throws -> [Self] {
    return try _SwapListV5TokenMetaWrapper.array(fromJSONUTF8Data: fromJSONUTF8Data).map({ $0.wrapped(.evm) })
  }
}

public struct SwapListV5Wrapper: Sendable {
  public let tokens: [TokenMeta]
  public let tokens_dexItems: [DexItem]
  public let featured_dexItems: [DexItem]
  public let crossChain_dexItems: [DexItem]
  
  public init(fromJSONString: String) throws {
    let items = try _SwapListV5TokenMetaWrapper.array(fromJSONString: fromJSONString).map({ $0.wrapped(.evm) })
    self.tokens = items.tokens
    self.tokens_dexItems = items.tokens_dexItems
    self.featured_dexItems = items.featured_dexItems
    self.crossChain_dexItems = items.crosschain_dexItems
  }
  
  public init(fromJSONUTF8Data: Data) throws {
    let items = try _SwapListV5TokenMetaWrapper.array(fromJSONUTF8Data: fromJSONUTF8Data).map({ $0.wrapped(.evm) })
    self.tokens = items.tokens
    self.tokens_dexItems = items.tokens_dexItems
    self.featured_dexItems = items.featured_dexItems
    self.crossChain_dexItems = items.crosschain_dexItems
  }
}

public extension Array where Element == SwapListV5TokenMetaWrapper {
  var tokens: [TokenMeta] {
    return self.flatMap { $0.tokens }
  }
  
  var tokens_dexItems: [DexItem] {
    var order: UInt16 = 0
    return self
      .flatMap {
        $0.tokens_dexItems
          .map { item in
            var item = item
            item.order = order
            order &+= 1
            return item
          }
      }
  }
  
  var featured_dexItems: [DexItem] {
    return self.flatMap {
      $0.featured_dexItems
    }
  }
  
  var crosschain_dexItems: [DexItem] {
    var order: UInt16 = 0
    return self
      .flatMap {
        $0.crosschain_dexItems
          .map { item in
            var item = item
            item.order = order
            order &+= 1
            return item
          }
      }
  }
}
