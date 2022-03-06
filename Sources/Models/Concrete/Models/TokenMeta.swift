//
//  File.swift
//  
//
//  Created by Mikhail Nikanorov on 3/4/22.
//

import Foundation
import SwiftProtobuf
import mdbx_ios

public struct TokenMeta: Equatable {
  public weak var database: WalletDB?
  var _wrapped: _TokenMeta
  var _chain: MDBXChain
  
  // MARK: - Private Properties
  
  private let _dexItem: MDBXPointer<DexItemKey, DexItem> = .init(.dex)
}

// MARK: - TokenMeta + Properties

extension TokenMeta {
  // MARK: - Relations
  
  public var dexItem: DexItem {
    get throws {
      let key = DexItemKey(chain: _chain, contractAddress: self.contract_address)
      return try _dexItem.getData(key: key, policy: .cacheOrLoad, database: self.database)
    }
  }
  
  // MARK: - Properties
  
  public var contract_address: String { self._wrapped.contractAddress }
  public var name: String { self._wrapped.name }
  public var symbol: String { self._wrapped.symbol }
  public var decimals: Int { Int(self._wrapped.decimals) }
  public var icon: URL? {
    guard self._wrapped.hasIcon else { return nil }
    return URL(string: self._wrapped.icon)
  }
  public var price: Decimal? {
    guard self._wrapped.hasPrice else { return nil }
    return Decimal(wrapped: self._wrapped.price, hex: false)
  }
  public var market_cap: Decimal? {
    guard self._wrapped.hasMarketCap else { return nil }
    return Decimal(wrapped: self._wrapped.marketCap, hex: false)
  }
  public var sparkline: [Decimal] {
    self._wrapped.sparkline.compactMap { Decimal(wrapped: $0, hex: false) }
  }
  public var volume24h: Decimal? {
    guard self._wrapped.hasVolume24H else { return nil }
    return Decimal(wrapped: self._wrapped.volume24H, hex: false)
  }
}

// MARK: - TokenMeta + MDBXObject

extension TokenMeta: MDBXObject {
  public var serialized: Data {
    get throws {
      return try self._wrapped.serializedData()
    }
  }
  
  public var key: MDBXKey {
    return TokenMetaKey(chain: _chain, contractAddress: self.contract_address)
  }
  
  public var alternateKey: MDBXKey? { return nil }
  
  public init(serializedData data: Data, chain: MDBXChain, key: Data?) throws {
    self._chain = chain
    self._wrapped = try _TokenMeta(serializedData: data)
  }
  
  public init(jsonData: Data, chain: MDBXChain, key: Data?) throws {
    var options = JSONDecodingOptions()
    options.ignoreUnknownFields = true
    self._chain = chain
    self._wrapped = try _TokenMeta(jsonUTF8Data: jsonData, options: options)
  }
  
  public init(jsonString: String, chain: MDBXChain, key: Data?) throws {
    var options = JSONDecodingOptions()
    options.ignoreUnknownFields = true
    self._chain = chain
    self._wrapped = try _TokenMeta(jsonString: jsonString, options: options)
  }
  
  public static func array(fromJSONString string: String, chain: MDBXChain) throws -> [Self] {
    var options = JSONDecodingOptions()
    options.ignoreUnknownFields = true
    let objects = try _TokenMeta.array(fromJSONString: string, options: options)
    return objects.lazy.map({ $0.wrapped(chain) })
  }
}

// MARK: - _TokenMeta + ProtoWrappedMessage

extension _TokenMeta: ProtoWrappedMessage {
  func wrapped(_ chain: MDBXChain) -> TokenMeta {
    return TokenMeta(self, chain: chain)
  }
}

// MARK: - TokenMeta + Equitable

public extension TokenMeta {
  static func ==(lhs: TokenMeta, rhs: TokenMeta) -> Bool {
    return lhs._chain == rhs._chain
        && lhs._wrapped == rhs._wrapped
  }
}

// MARK: - TokenMeta + ProtoWrapper

extension TokenMeta: ProtoWrapper {
  init(_ wrapped: _TokenMeta, chain: MDBXChain) {
    self._chain = chain
    self._wrapped = wrapped
  }
}
