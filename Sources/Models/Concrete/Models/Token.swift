//
//  File.swift
//  
//
//  Created by Mikhail Nikanorov on 3/21/22.
//

import Foundation
import SwiftProtobuf
import mdbx_ios

public struct Token: Equatable {
  public enum Error: LocalizedError {
    case badValue
  }

  public weak var database: WalletDB?
  var _wrapped: _Token
  var _chain: MDBXChain

  // MARK: - Private Properties
  
  private let _metaKey: TokenMetaKey
  private let _meta: MDBXPointer<TokenMetaKey, TokenMeta> = .init(.tokenMeta)
  private let _account: MDBXPointer<AccountKey, Account> = .init(.account)
  private let _dexItem: MDBXPointer<DexItemKey, DexItem> = .init(.dex)
  
  // MARK: - LifeCycle
    
  public init(chain: MDBXChain, address: Address, contractAddress: Address, rawAmount: String? = nil, database: WalletDB? = nil) {
    self.database = database ?? MEWwalletDBImpl.shared
    self._wrapped = .with {
      $0.contractAddress = contractAddress.rawValue
      $0.address = address.rawValue
      if let rawAmount {
        $0.amount = rawAmount
      }
    }
    self._chain = chain
    
    /// Replace primary contract address to `eth`/`0xeee...eee` for zksync only
    if chain.isZKSync, contractAddress.isPrimary  {
      self._metaKey = TokenMetaKey(chain: .eth, contractAddress: ._primary)
    } else {
      self._metaKey = TokenMetaKey(chain: chain, contractAddress: contractAddress)
    }
  }
}

// MARK: - Token + Properties

extension Token {
  // MARK: - Relations
  
  public var meta: TokenMeta {
    get throws {
      return try _meta.getData(key: self._metaKey, policy: .cacheOrLoad(chain: _chain), database: self.database)
    }
  }
  
  public var account: Account? {
    get throws {
      let key = AccountKey(address: .unknown(_wrapped.address))
      return try _account.getData(key: key, policy: .ignoreCache(chain: .universal), database: self.database)
    }
  }
  
  public var dexItem: DexItem {
    get throws {
      let key = DexItemKey(chain: _chain, contractAddress: self.contract_address)
      return try _dexItem.getData(key: key, policy: .cacheOrLoad(chain: _chain), database: self.database)
    }
  }
  
  // MARK: - Properties
  
  public var contract_address: Address { Address(rawValue: self._wrapped.contractAddress) }
  public var address: Address { Address(rawValue: self._wrapped.address) }
  public var amount: Decimal { Decimal(wrapped: self._wrapped.amount, hex: true) ?? .zero }
  public var lockedAmount: Decimal { Decimal(wrapped: self._wrapped.lockedAmount, hex: true) ?? .zero }
  
  public func isHidden(locked: Bool) -> Bool {
    guard let account = try? account else { return false }
    return account.tokenHiddenKeys.contains(where: {
      $0.locked == locked && $0.contractAddress == _wrapped.contractAddress
    })
  }
  
  public var isPrimary: Bool         { self.contract_address.isPrimary }
  public var isStarkChain: Bool      { self.contract_address.isStarkChain }
  public var isRenBTC: Bool          { self.contract_address.isRenBTC }
  public var isSkale: Bool           { self.contract_address.isSkale }
  public var isStEth: Bool           { self.contract_address.isStEth }
  public var isWrappedBitcoin: Bool  { self.contract_address.isWrappedBitcoin }
  public var isZK2Buidl: Bool        { self.contract_address.isZK2Buidl }
  
  // MARK: - Methods
  
  /// Toggles hidden flag of Token
  /// - Returns: Updated Account that needs to be send back to DB
  public func toggleHidden(locked: Bool) -> Account? {
    guard var account = try? account, let key = self.key as? TokenKey else { return nil }
    account.toggleTokenIsHidden(key, locked: locked)
    return account
  }
  
  /// Updates amount of Token
  public mutating func update(amount: String) throws {
    guard amount.isHex() else { throw Error.badValue }
    _wrapped.amount = amount
  }
}

// MARK: - Token + MDBXObject

extension Token: MDBXObject {
  public var serialized: Data {
    get throws {
      return try self._wrapped.serializedData()
    }
  }
  
  public var key: MDBXKey {
    return TokenKey(chain: _chain, address: self.address, contractAddress: self.contract_address)
  }
  
  public var alternateKey: MDBXKey? { return nil }
  
  public init(serializedData data: Data, chain: MDBXChain, key: Data?) throws {
    self._chain = chain
    self._wrapped = try _Token(serializedData: data)
    let address = Address(self._wrapped.contractAddress)
    /// Replace primary contract address to `eth`/`0xeee...eee` for zksync only
    if chain.isZKSync, address.isPrimary  {
      self._metaKey = TokenMetaKey(chain: .eth, contractAddress: ._primary)
    } else {
      self._metaKey = TokenMetaKey(chain: chain, contractAddress: address)
    }
  }
  
  public init(jsonData: Data, chain: MDBXChain, key: Data?) throws {
    var options = JSONDecodingOptions()
    options.ignoreUnknownFields = true
    self._chain = chain
    self._wrapped = try _Token(jsonUTF8Data: jsonData, options: options)
    let address = Address(self._wrapped.contractAddress)
    /// Replace primary contract address to `eth`/`0xeee...eee` for zksync only
    if chain.isZKSync, address.isPrimary  {
      self._metaKey = TokenMetaKey(chain: .eth, contractAddress: ._primary)
    } else {
      self._metaKey = TokenMetaKey(chain: chain, contractAddress: address)
    }
  }
  
  public init(jsonString: String, chain: MDBXChain, key: Data?) throws {
    var options = JSONDecodingOptions()
    options.ignoreUnknownFields = true
    self._chain = chain
    self._wrapped = try _Token(jsonString: jsonString, options: options)
    let address = Address(self._wrapped.contractAddress)
    /// Replace primary contract address to `eth`/`0xeee...eee` for zksync only
    if chain.isZKSync, address.isPrimary  {
      self._metaKey = TokenMetaKey(chain: .eth, contractAddress: ._primary)
    } else {
      self._metaKey = TokenMetaKey(chain: chain, contractAddress: address)
    }
  }
  
  public static func array(fromJSONString string: String, chain: MDBXChain) throws -> [Self] {
    var options = JSONDecodingOptions()
    options.ignoreUnknownFields = true
    let objects = try _Token.array(fromJSONString: string, options: options)
    return objects.lazy.map({ $0.wrapped(chain) })
  }
  
  public static func array(fromJSONData data: Data, chain: MDBXChain) throws -> [Self] {
    var options = JSONDecodingOptions()
    options.ignoreUnknownFields = true
    let objects = try _Token.array(fromJSONUTF8Data: data, options: options)
    return objects.lazy.map({ $0.wrapped(chain) })
  }
  
  mutating public func merge(with object: MDBXObject) {
    let other = object as! Token

    self._wrapped.address               = other._wrapped.address
    self._wrapped.contractAddress       = other._wrapped.contractAddress
    self._wrapped.amount                = other._wrapped.amount
    self._wrapped.lockedAmount          = other._wrapped.lockedAmount
  }
}

// MARK: - _Token + ProtoWrappedMessage

extension _Token: ProtoWrappedMessage {
  func wrapped(_ chain: MDBXChain) -> Token {
    return Token(self, chain: chain)
  }
}

// MARK: - Token + ProtoWrapper

extension Token: ProtoWrapper {
  init(_ wrapped: _Token, chain: MDBXChain) {
    self._chain = chain
    self._wrapped = wrapped
    let address = Address(rawValue: self._wrapped.contractAddress)
    /// Replace primary contract address to `eth`/`0xeee...eee` for zksync only
    if chain.isZKSync, address.isPrimary  {
      self._metaKey = TokenMetaKey(chain: .eth, contractAddress: ._primary)
    } else {
      self._metaKey = TokenMetaKey(chain: chain, contractAddress: address)
    }
  }
}

// MARK: - Token + Equitable

public extension Token {
  static func ==(lhs: Token, rhs: Token) -> Bool {
    return lhs._chain == rhs._chain &&
           lhs._wrapped == rhs._wrapped
  }
}

// MARK: - Token + Identifiable

extension Token: Identifiable {
  /// The stable identity of the entity associated with this instance.
  public var id: String { self._wrapped.address + self._wrapped.contractAddress }
}

// MARK: - Token + Hashable

extension Token: Hashable {
  public func hash(into hasher: inout Hasher) {
    hasher.combine(self.address.rawValue)
    hasher.combine(self.contract_address.rawValue)
  }
}

// MARK: - Token + Comparable

extension Token: Comparable {
  public static func < (lhs: Token, rhs: Token) -> Bool {
    var compare = Token.compareByPrimary(lhs, rhs)
    guard compare == .orderedSame else {
      return compare == .orderedDescending
    }
    compare = Token.compareByName(lhs, rhs)
    guard compare == .orderedSame else {
      return compare == .orderedAscending
    }
    return lhs == rhs
  }
  
  static func compareByPrimary(_ lhs: Token, _ rhs: Token) -> ComparisonResult {
    switch (lhs.contract_address.isPrimary, rhs.contract_address.isPrimary) {
    case (true, true), (false, false):
      return .orderedSame
    case (true, false):
      return .orderedDescending
    case (false, true):
      return .orderedAscending
    }
  }
  
  static func compareByName(_ lhs: Token, _ rhs: Token) -> ComparisonResult {
    switch (try? lhs.meta.name, try? rhs.meta.name) {
    case (.some, .none):
      return .orderedDescending
    case (.none, .some):
      return .orderedAscending
    case (.none, .none):
      return .orderedSame
    case (.some(let lhsName), .some(let rhsName)):
      return lhsName.lowercased().compare(rhsName.lowercased())
    }
  }
}

// MARK: - Token + Sendable

extension Token: Sendable {}
