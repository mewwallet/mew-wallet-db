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
  public weak var database: (any WalletDB)?
  var _wrapped: _TokenMeta
  var _chain: MDBXChain
  
  // MARK: - Private Properties
  
  private let _dexItem: MDBXPointer<DexItemKey, DexItem> = .init(.dex)
  private let _token: MDBXPointer<TokenKey, Token> = .init(.token)
  
  // MARK: - LifeCycle
   
  public init(chain: MDBXChain,
              contractAddress: Address,
              name: String = "No Token Name",
              symbol: String = "MNKY",
              decimals: Int32 = 0, // FIXME: optional decimals?
              icon: String? = nil,
              price: String? = nil,
              database: (any WalletDB)? = nil) {
    self.database = database ?? MEWwalletDBImpl.shared
    self._wrapped = .with {
      $0.contractAddress = contractAddress.rawValue
      $0.name = name
      $0.symbol = symbol
      if let icon {
        $0.icon = icon
      }
      if let price {
        $0.price = price
      }
      $0.decimals = decimals
    }
    self._chain = chain
  }
}

// MARK: - TokenMeta + Properties

extension TokenMeta {
  // MARK: - Relations
  
  public var dexItem: DexItem {
    get throws {
      let key = DexItemKey(chain: _chain, contractAddress: self.contract_address)
      return try _dexItem.getData(key: key, policy: .cacheOrLoad, chain: _chain, database: self.database)
    }
  }
  
  public func token(of account: Address) throws -> Token {
    let key = TokenKey(chain: _chain, address: account, contractAddress: contract_address)
    return try _token.getData(key: key, policy: .ignoreCache, chain: _chain, database: self.database)
  }
  
  // MARK: - Properties
  
  public var chain: MDBXChain { _chain }
  public var contract_address: Address { Address(rawValue: self._wrapped.contractAddress) }
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
  
  public var isPrimary: Bool         { self.contract_address.isPrimary }
  public var isStarkChain: Bool      { self.contract_address.isStarkChain }
  public var isRenBTC: Bool          { self.contract_address.isRenBTC }
  public var isSkale: Bool           { self.contract_address.isSkale }
  public var isStEth: Bool           { self.contract_address.isStEth }
  public var isWrappedBitcoin: Bool  { self.contract_address.isWrappedBitcoin }
}

// MARK: - TokenMeta + MDBXObject

extension TokenMeta: MDBXObject {
  public var serialized: Data {
    get throws {
      return try self._wrapped.serializedData()
    }
  }
  
  public var key: any MDBXKey {
    return TokenMetaKey(chain: _chain, contractAddress: self.contract_address)
  }
  
  public var alternateKey: (any MDBXKey)? { return nil }
  
  public init(serializedData data: Data, chain: MDBXChain, key: Data?) throws {
    self._chain = chain
    self._wrapped = try _TokenMeta(serializedBytes: data)
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
  
  public static func array(fromJSONData data: Data, chain: MDBXChain) throws -> [Self] {
    var options = JSONDecodingOptions()
    options.ignoreUnknownFields = true
    let objects = try _TokenMeta.array(fromJSONUTF8Data: data, options: options)
    return objects.lazy.map({ $0.wrapped(chain) })
  }
  
  mutating public func merge(with object: any MDBXObject) {
    let other = object as! TokenMeta
    
    self._wrapped.contractAddress       = other._wrapped.contractAddress
    self._wrapped.name                  = other._wrapped.name
    self._wrapped.symbol                = other._wrapped.symbol
    if other._wrapped.hasDecimals {
      self._wrapped.decimals            = other._wrapped.decimals
    }
    if other._wrapped.hasIcon {
      self._wrapped.icon                = other._wrapped.icon
    }
    if other._wrapped.hasPrice {
      self._wrapped.price               = other._wrapped.price
    }
    if other._wrapped.hasMarketCap {
      self._wrapped.marketCap           = other._wrapped.marketCap
    }
    if !other._wrapped.sparkline.isEmpty {
      self._wrapped.sparkline           = other._wrapped.sparkline
    }
    if other._wrapped.hasVolume24H {
      self._wrapped.volume24H           = other._wrapped.volume24H
    }
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
    return lhs._chain == rhs._chain &&
           lhs._wrapped == rhs._wrapped
  }
}

// MARK: - TokenMeta + ProtoWrapper

extension TokenMeta: ProtoWrapper {
  init(_ wrapped: _TokenMeta, chain: MDBXChain) {
    self._chain = chain
    self._wrapped = wrapped
  }
}

// MARK: - TokenMeta + Static

extension TokenMeta {
  public static func primary(chain: MDBXChain) -> TokenMeta {
    return TokenMeta(chain: chain, contractAddress: chain.primary, name: chain.name, symbol: chain.symbol, decimals: chain.decimals)
  }
}
