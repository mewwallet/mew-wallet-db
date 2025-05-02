//
//  File.swift
//  
//
//  Created by Mikhail Nikanorov on 3/5/22.
//

import Foundation
import SwiftProtobuf
import mdbx_ios

public struct DexItem {
  private var _restoredAlternateKey: OrderedDexItemKey?
  public weak var database: (any WalletDB)? = MEWwalletDBImpl.shared
  var _wrapped: _DexItem
  var _chain: MDBXChain
  public var order: UInt16?
  public var chain: MDBXChain { _chain }
  
  // MARK: - Private Properties
  
  private let _meta: MDBXPointer<TokenMetaKey, TokenMeta> = .init(.tokenMeta)
  private var _contract_address: String?
  
  // MARK: - Lifecycle
  
  public init(tokenMeta: TokenMeta) {
    self._chain = tokenMeta._chain
    self._contract_address = tokenMeta.contract_address.rawValue
    
    self.database = tokenMeta.database
    self._wrapped = .with {
      $0.contractAddress = tokenMeta.contract_address.rawValue
      $0.name = tokenMeta.name
      $0.symbol = tokenMeta.symbol
    }
  }
  
  public init(chain: MDBXChain, contractAddress: String, name: String, symbol: String, order: UInt16?, crosschain: Bool, database: (any WalletDB)? = nil) {
    self.database = database ?? MEWwalletDBImpl.shared
    self._chain = chain
    self._contract_address = contractAddress
    self.order = order
    self._wrapped = .with {
      $0.contractAddress = contractAddress
      $0.name = name
      $0.symbol = symbol
      $0.crosschain = crosschain
    }
  }
  
  // MARK: - Private
  
  mutating private func tryRestoreAlternateKey(_ key: Data?) {
    guard let key = key else { return }
    if let alternateKey = OrderedDexItemKey(data: key) {
      _restoredAlternateKey = alternateKey
      order = alternateKey.order
    }
  }
}

// MARK: - DexItem + Properties

extension DexItem {
  // MARK: - Relations
  
  public var meta: TokenMeta {
    get throws {
      let key = TokenMetaKey(chain: _chain, contractAddress: self.contract_address)
      return try _meta.getData(key: key, policy: .cacheOrLoad, chain: _chain, database: self.database)
    }
  }
  
  // MARK: - Properties
  
  public var contract_address: Address { Address(rawValue: self._contract_address ?? self._wrapped.contractAddress) }
  
  public var name: String {
    guard self._wrapped.name.isEmpty else {
      return self._wrapped.name
    }
    return (try? self.meta.name) ?? ""
  }
  
  public var symbol: String {
    guard self._wrapped.symbol.isEmpty else {
      return self._wrapped.symbol
    }
    return (try? self.meta.symbol) ?? ""
  }
  
  public var isCrossChain: Bool {
    self._wrapped.crosschain
  }
}

// MARK: - DexItem + MDBXObject

extension DexItem: MDBXObject {
  public var serialized: Data {
    get throws {
      return try self._wrapped.serializedData()
    }
  }
  
  public var key: any MDBXKey {
    return TokenMetaKey(chain: _chain, contractAddress: contract_address)
  }
  
  public var alternateKey: (any MDBXKey)? {
    guard let order = order else { return nil }
    return OrderedDexItemKey(chain: _chain, order: order, contractAddress: contract_address)
  }
  
  public init(serializedData data: Data, chain: MDBXChain, key: Data?) throws {
    self._chain = chain
    self._wrapped = try _DexItem(serializedBytes: data)
    self.tryRestoreAlternateKey(key)
  }
  
  public init(jsonData: Data, chain: MDBXChain, key: Data?) throws {
    var options = JSONDecodingOptions()
    options.ignoreUnknownFields = true
    self._chain = chain
    self._wrapped = try _DexItem(jsonUTF8Data: jsonData, options: options)
    self.tryRestoreAlternateKey(key)
  }
  
  public init(jsonString: String, chain: MDBXChain, key: Data?) throws {
    var options = JSONDecodingOptions()
    options.ignoreUnknownFields = true
    self._chain = chain
    self._wrapped = try _DexItem(jsonString: jsonString, options: options)
    self.tryRestoreAlternateKey(key)
  }
  
  public static func array(fromJSONString string: String, chain: MDBXChain) throws -> [Self] {
    var options = JSONDecodingOptions()
    options.ignoreUnknownFields = true
    let objects = try _DexItem.array(fromJSONString: string, options: options)
    return objects.lazy.map({ $0.wrapped(chain) })
  }
  
  public static func array(fromJSONData data: Data, chain: MDBXChain) throws -> [Self] {
    var options = JSONDecodingOptions()
    options.ignoreUnknownFields = true
    let objects = try _DexItem.array(fromJSONUTF8Data: data, options: options)
    return objects.lazy.map({ $0.wrapped(chain) })
  }
  
  mutating public func merge(with object: any MDBXObject) {
    let other = object as! DexItem
    
    self._wrapped.contractAddress       = other._wrapped.contractAddress
    self._wrapped.name                  = other._wrapped.name
    self._wrapped.symbol                = other._wrapped.symbol
  }
}

// MARK: - _DexItem + ProtoWrappedMessage

extension _DexItem: ProtoWrappedMessage {
  func wrapped(_ chain: MDBXChain) -> DexItem {
    return DexItem(self, chain: chain)
  }
}

// MARK: - DexItem + Equitable

extension DexItem: Equatable {
  public static func ==(lhs: DexItem, rhs: DexItem) -> Bool {
    return lhs._wrapped == rhs._wrapped
  }
}

// MARK: - DexItem + ProtoWrapper

extension DexItem: ProtoWrapper {
  init(_ wrapped: _DexItem, chain: MDBXChain) {
    self._chain = chain
    self._wrapped = wrapped
  }
}

// MARK: - DexItem + Identifiable

extension DexItem: Identifiable {
  /// The stable identity of the entity associated with this instance.
  public var id: String { self._wrapped.contractAddress }
}

// MARK: - DexItem + Sendable

extension DexItem: Sendable {}
