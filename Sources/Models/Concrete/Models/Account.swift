//
//  File.swift
//  
//
//  Created by Mikhail Nikanorov on 6/7/22.
//

import Foundation
import SwiftProtobuf
import mdbx_ios
import MEWextensions

public struct Account: Equatable {
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
  
  public weak var database: WalletDB? = MEWwalletDBImpl.shared
  var _wrapped: _Account
  var _chain: MDBXChain
  
  // MARK: - Private properties
  
//  private let _meta: MDBXPointer<DAppRecordMetaKey, DAppRecordMeta> = .init(.dappRecordMeta)
  
  // MARK: - Lifecycle
  
  public init(chain: MDBXChain,
              address: String,
              name: String,
              source: Source = .recoveryPhrase,
              type: `Type` = .`internal`,
              derivationPath: String?,
              anonymizedId: String?,
              encryptionPublicKey: String?,
              withdrawalPublicKey: String?,
              isHidden: Bool = false,
              database: WalletDB? = nil) {
    self.database = database ?? MEWwalletDBImpl.shared
    self._chain = chain
    self._wrapped = .with {
      $0.address = address
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
        $0.name = name
        $0.isHidden = isHidden
      }
    }
  }
}

// MARK: - Account + Properties

extension Account {
  // MARK: - Relations
  
//  private var meta: DAppRecordMeta {
//    get throws {
//      guard let host = self.url.hostURL?.sanitized else { throw MDBXError.notFound }
//      let key = DAppRecordMetaKey(chain: _chain, url: host)
//      return try _meta.getData(key: key, policy: .cacheOrLoad, database: self.database)
//    }
//  }
  
  // MARK: - Properties
  
  // MARK: Address
  
  /// Address of account
  public var address: String? { self._wrapped.address }
  
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
}

// MARK: - Account + MDBXObject

extension Account: MDBXObject {
  public var serialized: Data {
    get throws {
      return try self._wrapped.serializedData()
    }
  }

  public var key: MDBXKey {
    return AccountKey(chain: _chain, address: self._wrapped.address)
  }

  public var alternateKey: MDBXKey? {
    return nil
  }

  public init(serializedData data: Data, chain: MDBXChain, key: Data?) throws {
    self._chain = chain
    self._wrapped = try _Account(serializedData: data)
  }

  public init(jsonData: Data, chain: MDBXChain, key: Data?) throws {
    var options = JSONDecodingOptions()
    options.ignoreUnknownFields = true
    self._chain = chain
    self._wrapped = try _Account(jsonUTF8Data: jsonData, options: options)
  }

  public init(jsonString: String, chain: MDBXChain, key: Data?) throws {
    var options = JSONDecodingOptions()
    options.ignoreUnknownFields = true
    self._chain = chain
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

  mutating public func merge(with object: MDBXObject) {
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
    self._wrapped.state.name = other._wrapped.state.name
    self._wrapped.state.isHidden = other._wrapped.state.isHidden
  }
}

// MARK: - _Account + ProtoWrappedMessage

extension _Account: ProtoWrappedMessage {
  func wrapped(_ chain: MDBXChain) -> Account {
    return Account(self, chain: chain)
  }
}

// MARK: - Account + Equitable

public extension Account {
  static func ==(lhs: Account, rhs: Account) -> Bool {
    return lhs._chain == rhs._chain &&
           lhs._wrapped == rhs._wrapped
  }
}

// MARK: - Account + ProtoWrapper

extension Account: ProtoWrapper {
  init(_ wrapped: _Account, chain: MDBXChain) {
    self._chain = chain
    self._wrapped = wrapped
  }
}
//
//// MARK: - Account + Hashable
//
//extension Account: Hashable {
//  public func hash(into hasher: inout Hasher) {
////    if let uuid = reference?.uuid {
////      hasher.combine(uuid)
////    } else {
////      hasher.combine(self.url)
////      hasher.combine(self.address)
////      hasher.combine(self.icon)
////    }
//  }
//}
