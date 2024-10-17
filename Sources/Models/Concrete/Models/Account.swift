//
//  File.swift
//  
//
//  Created by Mikhail Nikanorov on 6/7/22.
//

import Foundation
import SwiftProtobuf
import mdbx_ios
import mew_wallet_ios_extensions

public struct Account {
  @ContextStorage public var fiatAmount: Decimal?
  @ContextStorage public var usdFiatAmount: Decimal?
  
  public enum Source: Int {
    case unknown          = 0
    case recoveryPhrase   = 1
    case privateKey       = 2
    
    init(_ source: _Account._Source) {
      switch source {
      case .recoveryPhrase:                           self = .recoveryPhrase
      case .privateKey:                               self = .privateKey
      case .unknown, .walletConnect, .UNRECOGNIZED:   self = .unknown
      }
    }
  }
  
  public enum `Type`: Int {
    case `internal`       = 0
    case readOnly         = 1
    case external         = 2
    
    init(_ type: _Account._Type) {
      switch type {
      case .internal:       self = .internal
      case .readOnly:       self = .readOnly
      case .external:       self = .external
      case .UNRECOGNIZED:   self = .internal
      }
    }
  }
  
  public var database: (any WalletDB)? {
    get { MEWwalletDBImpl.shared }
    set {}
  }
  var _wrapped: _Account
  var _chain: MDBXChain
  
  // MARK: - Private properties
  
  private let _tokens: MDBXRelationship<TokenKey, Token> = .init(.token)
  private let _primary: MDBXPointer<TokenKey, Token> = .init(.token)
  private let _renBTC: MDBXPointer<TokenKey, Token> = .init(.token)
  private let _stETH: MDBXPointer<TokenKey, Token> = .init(.token)
  private let _skale: MDBXPointer<TokenKey, Token> = .init(.token)
  private let _zkSyncBuidl: MDBXPointer<TokenKey, Token> = .init(.token)
  private let _nft: MDBXRelationship<NFTAssetKey, NFTAsset> = .init(.nftAsset)
  private let _nftHidden: MDBXRelationship<NFTAssetKey, NFTAsset> = .init(.nftAsset)
  private let _nftFavorite: MDBXRelationship<NFTAssetKey, NFTAsset> = .init(.nftAsset)
  
  // MARK: - Lifecycle
  
  public init(address: Address) {
    self.init(order: 0,
              address: address,
              name: "",
              source: .unknown,
              type: .internal,
              derivationPath: nil,
              anonymizedId: nil,
              encryptionPublicKey: nil,
              withdrawalPublicKey: nil,
              isHidden: false)
  }
  
  public init(order: UInt32,
              address: Address,
              name: String,
              source: Source = .recoveryPhrase,
              type: `Type` = .`internal`,
              derivationPath: String?,
              anonymizedId: String?,
              encryptionPublicKey: String?,
              withdrawalPublicKey: String?,
              isHidden: Bool = false,
              database: (any WalletDB)? = nil) {
    self._chain = .universal
    self._wrapped = .with {
      $0.address = address.rawValue
      $0.groupID = 0
      $0.source = .init(rawValue: source.rawValue) ?? .unknown
      $0.type = .init(rawValue: type.rawValue) ?? .internal
      
      // Keys
      $0.keys = .with {
        if let derivationPath = derivationPath { $0.derivationPath = derivationPath }
        if let anonymizedId = anonymizedId { $0.anonymizedID = anonymizedId }
        if let encryptionPublicKey = encryptionPublicKey { $0.encryptionPublicKey = encryptionPublicKey }
        if let withdrawalPublicKey = withdrawalPublicKey { $0.withdrawalPublicKey = withdrawalPublicKey }
      }
      
      // User State
      $0.state = .with {
        $0.order = order
        $0.name = name
        $0.isHidden = isHidden
      }
    }
  }
}

// MARK: - Account + Properties

extension Account {
  // MARK: - Relations
  
  public func tokens(chain: MDBXChain, ignoreCache: Bool) throws -> [Token] {
    let range = TokenKey.range(chain: chain, address: address)
    return try _tokens.getRelationship(range, policy: ignoreCache ? .ignoreCache : .cacheOrLoad, order: .asc, chain: chain, database: self.database)
  }
  
  public func primary(chain: MDBXChain) -> Token {
    do {
      let key = TokenKey(chain: chain, address: .unknown(_wrapped.address), contractAddress: chain.primary)
      return try _primary.getData(key: key, policy: .ignoreCache, chain: chain, database: self.database)
    } catch {
      return Token(chain: chain, address: .unknown(_wrapped.address), contractAddress: chain.primary)
    }
  }
  
  public func renBTC(chain: MDBXChain) throws -> Token {
    let key = TokenKey(chain: chain, address: .unknown(_wrapped.address), contractAddress: .renBTC)
    return try _renBTC.getData(key: key, policy: .ignoreCache, chain: chain, database: self.database)
  }
  
  public func stETH(chain: MDBXChain) throws -> Token {
    let key = TokenKey(chain: chain, address: .unknown(_wrapped.address), contractAddress: .stEth)
    return try _stETH.getData(key: key, policy: .ignoreCache, chain: chain, database: self.database)
  }
  
  public func skale(chain: MDBXChain) throws -> Token {
    let key = TokenKey(chain: chain, address: .unknown(_wrapped.address), contractAddress: .skale)
    return try _skale.getData(key: key, policy: .ignoreCache, chain: chain, database: self.database)
  }
  
  public func zkSyncBuidl(chain: MDBXChain) throws -> Token {
    let key = TokenKey(chain: chain, address: .unknown(_wrapped.address), contractAddress: .buidl(for: chain))
    return try _zkSyncBuidl.getData(key: key, policy: .ignoreCache, chain: chain, database: self.database)
  }
  
  public func token(with contractAddress: Address, chain: MDBXChain) throws -> Token {
    guard let database else { throw MDBXError.notFound }
    let key = TokenKey(chain: chain, address: .unknown(_wrapped.address), contractAddress: contractAddress)
    return try database.read(key: key, table: .token)
  }
  
  /// List of all NFT
  public func nft(chain: MDBXChain, ignoreCache: Bool) throws -> [NFTAsset] {
    let range = NFTAssetKey.range(chain: chain, address: self.address, start: nil, end: nil)
    return try _nft.getRelationship(range, policy: ignoreCache ? .ignoreCache : .cacheOrLoad, order: .asc, chain: chain, database: self.database)
      .sorted(by: { asset1, asset2 in
        guard asset1.last_acquired_date == asset2.last_acquired_date else {
          return asset1.last_acquired_date > asset2.last_acquired_date
        }
        return asset1.token_id > asset2.token_id
      })
  }
  
  /// Stores list of favorite NFTs
  public func nftFavorite(chain: MDBXChain) throws -> [NFTAsset] {
    let keys = self.nftFavoriteKeys(chain: chain)
    return try _nftFavorite.getRelationship(keys, policy: .ignoreCache, chain: chain, database: self.database)
  }

  /// Stores list of favorite NFTs
  public func nftHidden(chain: MDBXChain) throws -> [NFTAsset] {
    let keys = self.nftHiddenKeys(chain: chain)
    return try _nftHidden.getRelationship(keys, policy: .ignoreCache, chain: chain, database: self.database)
  }
  
  // MARK: - Properties
  
  // MARK: Address
  
  /// Address of account
  public var address: Address { Address(rawValue: self._wrapped.address) }
  
  // MARK: Technical
  
  /// Source of account
  /// Might be from `recoveryPhrase` or from `privateKey`
  public var source: Source {
    set { self._wrapped.source = .init(rawValue: newValue.rawValue) ?? .UNRECOGNIZED(newValue.rawValue) }
    get { Source(self._wrapped.source) }
  }
  
  /// Type of account
  /// Might be generated internally, or from external source like WalletConnect, or readOnly
  public var type: `Type` {
    set { self._wrapped.type = .init(rawValue: newValue.rawValue) ?? .UNRECOGNIZED(newValue.rawValue) }
    get { Type(self._wrapped.type) }
  }
  
  // MARK: Keys
  
  /// Derivation path used for address
  /// Available only with internal source with generation from recoveryPhrase
  public var derivationPath: String? {
    set {
      if let newValue = newValue {
        self._wrapped.keys.derivationPath = newValue
      } else {
        self._wrapped.keys.clearDerivationPath()
      }
    }
    get {
      guard self._wrapped.keys.hasDerivationPath else { return nil }
      return self._wrapped.keys.derivationPath
    }
  }
  
  /// Last component of derivation path
  public var index: UInt32? {
    guard let derivationPath = derivationPath,
          let index = derivationPath.components(separatedBy: "/").last else { return nil }
    guard let uint64 = UInt64(index, radix: 10) else { return nil }
    return UInt32(clamping: uint64)
  }
  
  /// AnonymizedId
  /// Used for specific cases when we need to improve user's privacy
  public var anonymizedId: String? {
    set {
      if let newValue = newValue {
        self._wrapped.keys.anonymizedID = newValue
      } else {
        self._wrapped.keys.clearAnonymizedID()
      }
    }
    get {
      guard self._wrapped.keys.hasAnonymizedID else { return nil }
      return self._wrapped.keys.anonymizedID
    }
  }
  
  /// EncryptionPublicKey
  /// Represents eth_encryptionPublicKey
  public var encryptionPublicKey: String? {
    set {
      if let newValue = newValue {
        self._wrapped.keys.encryptionPublicKey = newValue
      } else {
        self._wrapped.keys.clearEncryptionPublicKey()
      }
    }
    get {
      guard self._wrapped.keys.hasEncryptionPublicKey else { return nil }
      return self._wrapped.keys.encryptionPublicKey
    }
  }
  
  /// WithdrawalPublicKey used for ETH2 staking
  public var withdrawalPublicKey: String? {
    set {
      if let newValue = newValue {
        self._wrapped.keys.withdrawalPublicKey = newValue
      } else {
        self._wrapped.keys.clearWithdrawalPublicKey()
      }
    }
    get {
      guard self._wrapped.keys.hasWithdrawalPublicKey else { return nil }
      return self._wrapped.keys.withdrawalPublicKey
    }
  }
  
  // MARK: UserState
  
  /// Order of account
  public var order: UInt32 {
    set { self._wrapped.state.order = newValue }
    get { self._wrapped.state.order }
  }
  
  /// Name of account
  public var name: String {
    set { self._wrapped.state.name = newValue }
    get { self._wrapped.state.name }
  }
  
  /// Represents is account was hidden
  public var isHidden: Bool {
    set { self._wrapped.state.isHidden = newValue }
    get { self._wrapped.state.isHidden }
  }
  
  /// Stores keys list of favorite NFTs
  public func nftFavoriteKeys(chain: MDBXChain) -> [NFTAssetKey] {
    self._wrapped.state.nftFavorite.sorted(by: { $0.timestamp.timeIntervalSince1970 < $1.timestamp.timeIntervalSince1970 })
                                   .compactMap { NFTAssetKey(data: Data(hex: $0.key)) }
                                   .filter { $0.chain == chain }
  }
  
  /// Stores keys list of hidden NFTs
  public func nftHiddenKeys(chain: MDBXChain) -> [NFTAssetKey] {
    self._wrapped.state.nftHidden.sorted(by: { $0.timestamp.timeIntervalSince1970 < $1.timestamp.timeIntervalSince1970 })
                                 .compactMap { NFTAssetKey(data: Data(hex: $0.key)) }
                                 .filter { $0.chain == chain }
  }
  
  /// Stores keys list of hidden Tokens
  internal var tokenHiddenKeys: [_Account._UserState._Token] {
    self._wrapped.state.tokenHidden.sorted(by: { $0.timestamp.timeIntervalSince1970 < $1.timestamp.timeIntervalSince1970 })
  }

  // MARK: - NFT hidden/favorites
  
  mutating public func addNFTToFavorites(_ key: NFTAssetKey) {
    guard !self._wrapped.state.nftFavorite.contains(where: { $0.key == key.key.hexString }) else { return }
    self._wrapped.state.nftFavorite.append(.with({
      $0.key = key.key.hexString
      $0.timestamp = .init(date: Date())
    }))
  }

  mutating public func addNFTToHidden(_ key: NFTAssetKey) {
    guard !self._wrapped.state.nftHidden.contains(where: { $0.key == key.key.hexString }) else { return }
    self._wrapped.state.nftHidden.append(.with({
      $0.key = key.key.hexString
      $0.timestamp = .init(date: Date())
    }))
  }

  mutating public func removeNFTFromFavorites(_ key: NFTAssetKey) {
    self._wrapped.state.nftFavorite.removeAll(where: { $0.key == key.key.hexString })
  }

  mutating public func removeNFTFromHidden(_ key: NFTAssetKey) {
    self._wrapped.state.nftHidden.removeAll(where: { $0.key == key.key.hexString })
  }
  
  mutating public func toggleNFTIsFavorite(_ key: NFTAssetKey) {
    if self._wrapped.state.nftFavorite.contains(where: { $0.key == key.key.hexString }) {
      self.removeNFTFromFavorites(key)
      // We have to remove from Hidden
    } else {
      self.addNFTToFavorites(key)
      // We have to add to hidden
    }
  }
  
  mutating public func toggleNFTIsHidden(_ key: NFTAssetKey) {
    if self._wrapped.state.nftHidden.contains(where: { $0.key == key.key.hexString }) {
      self.removeNFTFromHidden(key)
      // We have to remove from Hidden
    } else {
      self.addNFTToHidden(key)
      // We have to add to hidden
    }
  }
  
  // MARK: - Token hidden
  
  mutating public func addTokenToHidden(_ key: TokenKey, locked: Bool) {
    guard !self._wrapped.state.tokenHidden.contains(where: { $0.contractAddress == key.contractAddress.rawValue && $0.locked == locked }) else { return }
    self._wrapped.state.tokenHidden.append(.with({
      $0.contractAddress = key.contractAddress.rawValue
      $0.locked = locked
      $0.timestamp = .init(date: Date())
    }))
  }
  
  mutating public func removeTokenFromHidden(_ key: TokenKey, locked: Bool) {
    self._wrapped.state.tokenHidden.removeAll(where: { $0.contractAddress == key.contractAddress.rawValue && $0.locked == locked })
  }
  
  mutating public func toggleTokenIsHidden(_ key: TokenKey, locked: Bool) {
    if self._wrapped.state.tokenHidden.contains(where: { $0.contractAddress == key.contractAddress.rawValue && $0.locked == locked }) {
      self.removeTokenFromHidden(key, locked: locked)
      // We have to remove from Hidden
    } else {
      self.addTokenToHidden(key, locked: locked)
      // We have to add to hidden
    }
  }
}

// MARK: - Account + MDBXObject

extension Account: MDBXObject {
  public var serialized: Data {
    get throws {
      return try self._wrapped.serializedData()
    }
  }

  public var key: any MDBXKey {
    return AccountKey(address: address)
  }

  public var alternateKey: (any MDBXKey)? {
    return nil
  }

  public init(serializedData data: Data, chain: MDBXChain, key: Data?) throws {
    self._chain = .universal
    self._wrapped = try _Account(serializedBytes: data)
  }

  public init(jsonData: Data, chain: MDBXChain, key: Data?) throws {
    var options = JSONDecodingOptions()
    options.ignoreUnknownFields = true
    self._chain = .universal
    self._wrapped = try _Account(jsonUTF8Data: jsonData, options: options)
  }

  public init(jsonString: String, chain: MDBXChain, key: Data?) throws {
    var options = JSONDecodingOptions()
    options.ignoreUnknownFields = true
    self._chain = .universal
    self._wrapped = try _Account(jsonString: jsonString, options: options)
  }

  public static func array(fromJSONString string: String, chain: MDBXChain) throws -> [Self] {
    var options = JSONDecodingOptions()
    options.ignoreUnknownFields = true
    let objects = try _Account.array(fromJSONString: string, options: options)
    return objects.lazy.map({ $0.wrapped(chain) })
  }

  public static func array(fromJSONData data: Data, chain: MDBXChain) throws -> [Self] {
    var options = JSONDecodingOptions()
    options.ignoreUnknownFields = true
    let objects = try _Account.array(fromJSONUTF8Data: data, options: options)
    return objects.lazy.map({ $0.wrapped(chain) })
  }

  mutating public func merge(with object: any MDBXObject) {
    let other = object as! Account
    
    self._wrapped.groupID = other._wrapped.groupID
    self._wrapped.source = other._wrapped.source
    self._wrapped.type = other._wrapped.type
    // Keys
    if other._wrapped.keys.hasDerivationPath { self._wrapped.keys.derivationPath = other._wrapped.keys.derivationPath }
    if other._wrapped.keys.hasAnonymizedID { self._wrapped.keys.anonymizedID = other._wrapped.keys.anonymizedID }
    if other._wrapped.keys.hasEncryptionPublicKey { self._wrapped.keys.encryptionPublicKey = other._wrapped.keys.encryptionPublicKey }
    if other._wrapped.keys.hasWithdrawalPublicKey { self._wrapped.keys.withdrawalPublicKey = other._wrapped.keys.withdrawalPublicKey }
    // UserState
    self._wrapped.state.order = other._wrapped.state.order
    self._wrapped.state.name = other._wrapped.state.name
    self._wrapped.state.isHidden = other._wrapped.state.isHidden
    self._wrapped.state.nftFavorite = other._wrapped.state.nftFavorite
    self._wrapped.state.nftHidden = other._wrapped.state.nftHidden
    self._wrapped.state.tokenHidden = other._wrapped.state.tokenHidden
  }
}

// MARK: - _Account + ProtoWrappedMessage

extension _Account: ProtoWrappedMessage {
  func wrapped(_ chain: MDBXChain) -> Account {
    return Account(self, chain: chain)
  }
}

// MARK: - Account + Equitable

extension Account: Equatable {
  public static func ==(lhs: Account, rhs: Account) -> Bool {
    return lhs._chain == rhs._chain &&
           lhs._wrapped == rhs._wrapped
  }
}

// MARK: - Account + Identifiable

extension Account: Identifiable {
  public var id: String { _wrapped.address }
}

// MARK: - Account + ProtoWrapper

extension Account: ProtoWrapper {
  init(_ wrapped: _Account, chain: MDBXChain) {
    self._chain = chain
    self._wrapped = wrapped
  }
}

// MARK: - Account + Comparable

extension Account: Comparable {
  public static func < (lhs: Account, rhs: Account) -> Bool {
    return lhs.order < rhs.order
  }
}

// MARK: - Account + Hashable

extension Account: Hashable {
  public func hash(into hasher: inout Hasher) {
    _wrapped.hash(into: &hasher)
  }
}

// MARK: - Account + Sendable

extension Account: Sendable {}
