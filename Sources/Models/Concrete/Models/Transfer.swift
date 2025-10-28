//
//  File.swift
//
//
//  Created by Mikhail Nikanorov on 9/23/22.
//

import Foundation
import SwiftProtobuf
import mdbx_ios

public struct Transfer: Equatable {
  public enum Direction: UInt8, Sendable {
    case `self`
    case outgoing
    case incoming
  }

  public enum Status: String {
    case pending = "PENDING"
    case success = "SUCCESS"
    case failed  = "FAIL"
    case dropped = "DROPPED"

    public init(rawValue: String) {
      switch rawValue {
      case "PENDING":   self = .pending
      case "SUCCESS":   self = .success
      case "FAIL":      self = .failed
      case "DROPPED":   self = .dropped
      default:          self = .pending
      }
    }

    public init(_ status: History.Status) {
      switch status {
      case .pending:    self = .pending
      case .success:    self = .success
      case .failed:     self = .failed
      case .dropped:    self = .dropped
      }
    }
  }

  public weak var database: (any WalletDB)?
  var _wrapped: _Transfer
  var _chain: MDBXChain
  public var order: UInt16?

  // MARK: - Private Properties
  private let _metaKey: TokenMetaKey
  private let _meta: MDBXPointer<TokenMetaKey, TokenMeta> = .init(.tokenMeta)
  private let _primaryMeta: MDBXPointer<TokenMetaKey, TokenMeta> = .init(.tokenMeta)
  private let _from: MDBXPointer<AccountKey, Account> = .init(.account)
  private let _to: MDBXPointer<AccountKey, Account> = .init(.account)
  private let _owner: MDBXPointer<AccountKey, Account> = .init(.account)
  @SubProperty<_NFTTransfer, NFTTransfer> var _nftTransfer: _NFTTransfer?

  // MARK: - LifeCycle

  public init(chain: MDBXChain,
              address: Address,
              hash: String,
              contractAddress: Address,
              from: Address,
              to: Address,
              blockNumber: UInt64,
              nonce: UInt64,
              delta: Decimal,
              timestamp: Date,
              status: Status,
              nft: NFTTransfer?,
              local: Bool,
              order: UInt16?,
              database: (any WalletDB)? = nil) {

    self.database = database ?? MEWwalletDBImpl.shared
    self._wrapped = .with {

      $0.contractAddress = contractAddress.rawValue
      $0.address = address.rawValue
      $0.from = from.rawValue
      $0.to = to.rawValue

      $0.hash = hash
      $0.blockNumber = blockNumber
      $0.nonce = nonce
      $0.delta = delta.hexString
      $0.timestamp = .init(date: timestamp)
      $0.status = status.rawValue
      $0.local = local
      if let nft = nft {
        $0.nft = nft._wrapped
      }
    }
    self._chain = chain
    self.order = order
    self._metaKey = TokenMetaKey(chain: chain, contractAddress: contractAddress)
  }
}

// MARK: - Transfer + Properties

extension Transfer {

  // MARK: - Relations

  public var meta: TokenMeta {
    get throws {
      return try _meta.getData(key: self._metaKey, policy: .cacheOrLoad, chain: _chain, database: self.database)
    }
  }

  public var primary: TokenMeta {
    get throws {
      return try _primaryMeta.getData(key: TokenMetaKey(chain: _chain, contractAddress: _chain.primary), policy: .cacheOrLoad, chain: _chain, database: self.database)
    }
  }

  public var from: Account {
    get throws {
      let key = AccountKey(address: self.fromAddress)
      return try _from.getData(key: key, policy: .cacheOrLoad, chain: key.chain, database: self.database)
    }
  }

  public var to: Account {
    get throws {
      let key = AccountKey(address: self.toAddress)
      return try _to.getData(key: key, policy: .cacheOrLoad, chain: key.chain, database: self.database)
    }
  }

  public var owner: Account {
    get throws {
      let key = AccountKey(address: self.address)
      return try _owner.getData(key: AccountKey(address: address), policy: .cacheOrLoad, chain: key.chain, database: self.database)
    }
  }

  // MARK: - Properties

  public var chain: MDBXChain { _chain }
  public var hash: String { _wrapped.hash }
  public var address: Address { Address(rawValue: self._wrapped.address) }
  public var fromAddress: Address { Address(rawValue: self._wrapped.from) }
  public var toAddress: Address { Address(rawValue: self._wrapped.to) }
  public var contractAddress: Address { Address(rawValue: self._wrapped.contractAddress) }
  public var block: UInt64 {
    set { _wrapped.blockNumber = newValue }
    get { self._wrapped.blockNumber }
  }
  public var nonce: Decimal { Decimal(self._wrapped.nonce) }
  public var delta: Decimal {
    set { _wrapped.delta = newValue.hexString }
    get { Decimal(hex: _wrapped.delta) }
  }

  public var status: History.Status {
    set { _wrapped.status = Transfer.Status(newValue).rawValue }
    get { History.Status(_status) }
  }


  public var nft: NFTTransfer? {
    guard _wrapped.hasNft else { return nil }
    return self.$_nftTransfer
  }

  public var direction: Direction {
    if self._wrapped.from == self._wrapped.to {
      return .`self`
    } else if self._wrapped.address == self._wrapped.from {
      return .outgoing
    } else {
      return .incoming
    }
  }
  public var timestamp: Date { self._wrapped.timestamp.date }
  public var local: Bool {
    set { _wrapped.local = newValue }
    get { _wrapped.local }
  }

  // MARK: - Private

  private var _status: Status { Status(rawValue: self._wrapped.status) }
}

// MARK: - Transfer + MDBXObject

extension Transfer: MDBXObject {
  public var serialized: Data {
    get throws {
      return try self._wrapped.serializedData()
    }
  }

  public var key: any MDBXKey {
    return TransferKey(chain: _chain, address: self.address, block: _wrapped.blockNumber, direction: self.direction, nonce: _wrapped.nonce, order: self.order ?? 0, contractAddress: self.contractAddress)
  }

  public var alternateKey: (any MDBXKey)? {
    return TransferStableKey(chain: _chain, address: self.address, direction: self.direction, nonce: _wrapped.nonce, order: self.order ?? 0)
  }

  public init(serializedData data: Data, chain: MDBXChain, key: Data?) throws {
    self._chain = chain
    self._wrapped = try _Transfer(serializedBytes: data)
    let address = Address(rawValue: self._wrapped.contractAddress)
    self._metaKey = TokenMetaKey(chain: chain, contractAddress: address)
    commonInit(chain: chain, key: key)
  }

  public init(jsonData: Data, chain: MDBXChain, key: Data?) throws {
    var options = JSONDecodingOptions()
    options.ignoreUnknownFields = true
    self._chain = chain
    self._wrapped = try _Transfer(jsonUTF8Data: jsonData, options: options)
    let address = Address(rawValue: self._wrapped.contractAddress)
    self._metaKey = TokenMetaKey(chain: chain, contractAddress: address)
    commonInit(chain: chain, key: key)
  }

  public init(jsonString: String, chain: MDBXChain, key: Data?) throws {
    var options = JSONDecodingOptions()
    options.ignoreUnknownFields = true
    self._chain = chain
    self._wrapped = try _Transfer(jsonString: jsonString, options: options)
    let address = Address(rawValue: self._wrapped.contractAddress)
    self._metaKey = TokenMetaKey(chain: chain, contractAddress: address)
    commonInit(chain: chain, key: key)
  }

  public static func array(fromJSONString string: String, chain: MDBXChain) throws -> [Self] {
    var options = JSONDecodingOptions()
    options.ignoreUnknownFields = true
    let objects = try _Transfer.array(fromJSONString: string, options: options)
    return objects.lazy.map({ $0.wrapped(chain) })
  }

  public static func array(fromJSONData data: Data, chain: MDBXChain) throws -> [Self] {
    var options = JSONDecodingOptions()
    options.ignoreUnknownFields = true
    let objects = try _Transfer.array(fromJSONUTF8Data: data, options: options)
    return objects.lazy.map({ $0.wrapped(chain) })
  }

  mutating public func merge(with object: any MDBXObject) {
    let other = object as! Transfer

    _wrapped.hash               = other._wrapped.hash
    _wrapped.contractAddress    = other._wrapped.contractAddress
    _wrapped.address            = other._wrapped.address
    _wrapped.from               = other._wrapped.from
    _wrapped.to                 = other._wrapped.to
    _wrapped.blockNumber        = other._wrapped.blockNumber
    _wrapped.nonce              = other._wrapped.nonce
    _wrapped.delta              = other._wrapped.delta
    if other._wrapped.hasTimestamp {
      _wrapped.timestamp        = other._wrapped.timestamp
    }
    _wrapped.status             = other._wrapped.status
    if other._wrapped.hasNft {
      _wrapped.nft              = other._wrapped.nft
    }
    _wrapped.local              = other._wrapped.local
  }
}

// MARK: - _Transfer + ProtoWrappedMessage

extension _Transfer: ProtoWrappedMessage {
  func wrapped(_ chain: MDBXChain) -> Transfer {
    var transfer = Transfer(self, chain: chain)
    transfer.commonInit(chain: chain, key: nil)
    return transfer
  }
}

// MARK: - Transfer + Equatable

public extension Transfer {
  static func ==(lhs: Transfer, rhs: Transfer) -> Bool {
    return lhs._chain == rhs._chain &&
    lhs._wrapped == rhs._wrapped
  }
}

// MARK: - Transfer + ProtoWrapper

extension Transfer: ProtoWrapper {
  init(_ wrapped: _Transfer, chain: MDBXChain) {
    self._chain = chain
    self._wrapped = wrapped
    let address = Address(rawValue: self._wrapped.contractAddress)
    self._metaKey = TokenMetaKey(chain: chain, contractAddress: address)
    commonInit(chain: chain, key: nil)
  }
}

// MARK: - Transfer + Comparable

extension Transfer: Comparable {
  public static func < (lhs: Transfer, rhs: Transfer) -> Bool {
    let lhsKey = (lhs.key as! TransferKey).sortingKey
    let rhsKey = (rhs.key as! TransferKey).sortingKey
   
    guard lhsKey.count == rhsKey.count else { return false }
    
    return lhsKey.lexicographicallyPrecedes(rhsKey)
  }
}

// MARK: - Transfer + CommonInit

extension Transfer {
  mutating func commonInit(chain: MDBXChain, key: Data?) {
    // Wrappers
    __nftTransfer.chain = chain
    __nftTransfer.refreshProjected(wrapped: _wrapped.nft)

    if let key, let transferKey = TransferKey(data: key) {
      self.order = transferKey.order
    }
  }
}
