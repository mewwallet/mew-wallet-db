//
//  File.swift
//  
//
//  Created by Mikhail Nikanorov on 10/3/22.
//

import Foundation
import SwiftProtobuf
import mdbx_ios

public struct HistorySwap {
  public enum Status: String {
    case pending = "PENDING"
    case success = "COMPLETE"
    case failed  = "FAILED"
    
    public init(rawValue: String) {
      switch rawValue {
      case "PENDING":   self = .pending
      case "COMPLETE":  self = .success
      case "FAILED":    self = .failed
      default:          self = .pending
      }
    }
    
    public init(_ status: History.Status) {
      switch status {
      case .pending:    self = .pending
      case .success:    self = .success
      case .failed:     self = .failed
      case .dropped:    self = .pending
      }
    }
  }
  
  public weak var database: (any WalletDB)?
  var _wrapped: _HistorySwap
  var _chain: MDBXChain
  
  // MARK: - Private Properties
  private let _fromAccount: MDBXPointer<AccountKey, Account> = .init(.account)
  private let _toAccount: MDBXPointer<AccountKey, Account> = .init(.account)
  private let _fromMeta: MDBXPointer<TokenMetaKey, TokenMeta> = .init(.tokenMeta)
  private let _toMeta: MDBXPointer<TokenMetaKey, TokenMeta> = .init(.tokenMeta)

  public init(id: String?,
              orderId: String?,
              dex: String,
              status: Status,
              fromChain: MDBXChain,
              fromToken: Address,
              fromAddress: Address,
              fromAmount: Decimal,
              toChain: MDBXChain,
              toToken: Address,
              toAddress: Address,
              toAmount: Decimal,
              hashes: [String],
              hashTo: String?
  ) {
    precondition(!hashes.isEmpty)
    self.database = database ?? MEWwalletDBImpl.shared
    self._wrapped = .with {
      if let id {
        $0.id = id
      }
      if let orderId {
        $0.orderID = orderId
      }
      
      $0.provider = dex
      $0.status = status.rawValue
      
      $0.fromChainID = fromChain.value
      $0.fromContractAddress = fromToken.rawValue
      $0.fromAddress = fromAddress.rawValue
      $0.fromAmount = fromAmount.hexString
      
      $0.toChainID = toChain.value
      $0.toContractAddress = toToken.rawValue
      $0.toAddress = toAddress.rawValue
      $0.toAmount = toAmount.hexString
      
      $0.hashFrom = hashes.last!
      $0.hashes.append(contentsOf: hashes)
      if let hashTo {
        $0.hashTo = hashTo
      }
      
      $0.timestamp = .init(date: Date())
    }
    self._chain = fromChain
  }
}

// MARK: - HistorySwap + Properties

extension HistorySwap {
  
  // MARK: - Relations
  
  public var fromAccount: Account {
    get throws {
      let address = Address(rawValue: _wrapped.fromAddress)
      let key = AccountKey(address: address)
      return try _fromAccount.getData(key: key, policy: .cacheOrLoad, chain: address.networkChain, database: self.database)
    }
  }
  
  public var toAccount: Account {
    get throws {
      let address = Address(rawValue: _wrapped.toAddress)
      let key = AccountKey(address: address)
      return try _toAccount.getData(key: key, policy: .cacheOrLoad, chain: address.networkChain, database: self.database)
    }
  }
  
  public var fromMeta: TokenMeta {
    get throws {
      let contractAddress = Address(rawValue: _wrapped.fromContractAddress)
      let key = TokenMetaKey(chain: fromChain, contractAddress: contractAddress)
      return try _fromMeta.getData(key: key, policy: .cacheOrLoad, chain: fromChain, database: self.database)
    }
  }
  
  public var toMeta: TokenMeta {
    get throws {
      let contractAddress = Address(rawValue: _wrapped.toContractAddress)
      let key = TokenMetaKey(chain: toChain, contractAddress: contractAddress)
      return try _toMeta.getData(key: key, policy: .cacheOrLoad, chain: toChain, database: self.database)
    }
  }
  
  // MARK: - Properties
  
  public var isCrosschain: Bool { _wrapped.fromChainID != _wrapped.toChainID }
  public var uuid: String? { _wrapped.hasID ? _wrapped.id : nil }
  public var orderId: String? { _wrapped.hasOrderID ? _wrapped.orderID : nil }
  public var fromChain: MDBXChain { MDBXChain(rawValue: _wrapped.fromChainID) }
  public var toChain: MDBXChain { MDBXChain(rawValue: _wrapped.toChainID) }
  public var rawFromAmount: Decimal { Decimal(wrapped: _wrapped.fromAmount, hex: true) ?? .zero }
  public var rawToAmount: Decimal { Decimal(wrapped: _wrapped.toAmount, hex: true) ?? .zero }
  public var fromAmount: Decimal {
    do {
      return try self.rawFromAmount.convert(to: self.fromMeta.cryptoUnit)
    } catch {
      return .zero
    }
  }
  public var toAmount: Decimal {
    do {
      return try self.rawToAmount.convert(to: self.toMeta.cryptoUnit)
    } catch {
      return .zero
    }
  }
  
  public var status: History.Status {
    set { _wrapped.status = HistorySwap.Status(newValue).rawValue }
    get { History.Status(_status) }
  }
  public var dex: String { _wrapped.provider }
  
  public var hashFrom: String { _wrapped.hashFrom }
  public var hashTo: String? { _wrapped.hasHashTo ? _wrapped.hashTo : nil }
  
  public var currentHash: String {
    var hash = self._wrapped.hashFrom
    while let replace = _wrapped.replaceHashes[hash] {
      hash = replace
    }
    return hash
  }
  public var knownHashes: [String] {
    var hashes = _wrapped.hashes
    if _wrapped.hasHashTo {
      hashes.append(_wrapped.hashTo)
    }
    hashes.append(contentsOf: _wrapped.replaceHashes.values)
    return hashes
  }
  public var timestamp: Date {
    if self.status.isFinal {
      return _wrapped.hasUpdatedAt ? _wrapped.updatedAt.date : _wrapped.timestamp.date
    } else {
      return _wrapped.timestamp.date
    }
  }
  
  public var safeFromAccount: Account? { try? fromAccount }
  public var safeToAccount: Account? { try? toAccount }
  public var safeFromMeta: TokenMeta? { try? fromMeta }
  public var safeToMeta: TokenMeta? { try? toMeta }
  
  // MARK: - Methods
  
  mutating public func add(hash: String, to: String) {
    _wrapped.replaceHashes[to] = hash
  }
  
  // MARK: - Private
  
  private var _status: Status { Status(rawValue: _wrapped.status)}
}

// MARK: - Transfer + MDBXObject

extension HistorySwap: MDBXObject {
  public var serialized: Data {
    get throws {
      return try self._wrapped.serializedData()
    }
  }
  
  public var chain: MDBXChain { _chain }
  
  public var key: any MDBXKey {
    let address = Address(rawValue: _wrapped.fromAddress)
    return HistorySwapKey(chain: fromChain, account: address, hash: _wrapped.hashFrom)
  }
  
  public var alternateKey: (any MDBXKey)? {
    guard self.isCrosschain else { return nil }
    let address = Address(rawValue: _wrapped.toAddress)
    return HistorySwapKey(chain: toChain, account: address, hash: _wrapped.hashFrom)
  }
  
  public init(serializedData data: Data, chain: MDBXChain, key: Data?) throws {
    self._chain = chain
    self._wrapped = try _HistorySwap(serializedBytes: data)
  }
  
  public init(jsonData: Data, chain: MDBXChain, key: Data?) throws {
    var options = JSONDecodingOptions()
    options.ignoreUnknownFields = true
    self._chain = chain
    self._wrapped = try _HistorySwap(jsonUTF8Data: jsonData, options: options)
  }
  
  public init(jsonString: String, chain: MDBXChain, key: Data?) throws {
    var options = JSONDecodingOptions()
    options.ignoreUnknownFields = true
    self._chain = chain
    self._wrapped = try _HistorySwap(jsonString: jsonString, options: options)
  }
  
  public static func array(fromJSONString string: String, chain: MDBXChain) throws -> [Self] {
    var options = JSONDecodingOptions()
    options.ignoreUnknownFields = true
    let objects = try _HistorySwap.array(fromJSONString: string, options: options)
    return objects.lazy.map({ $0.wrapped(chain) })
  }
  
  public static func array(fromJSONData data: Data, chain: MDBXChain) throws -> [Self] {
    var options = JSONDecodingOptions()
    options.ignoreUnknownFields = true
    let objects = try _HistorySwap.array(fromJSONUTF8Data: data, options: options)
    return objects.lazy.map({ $0.wrapped(chain) })
  }
  
  mutating public func merge(with object: any MDBXObject) {
    let other = object as! HistorySwap
    
    self._wrapped.provider              = other._wrapped.provider
    self._wrapped.status                = other._wrapped.status
    
    self._wrapped.fromChainID           = other._wrapped.fromChainID
    self._wrapped.fromContractAddress   = other._wrapped.fromContractAddress
    self._wrapped.fromAddress           = other._wrapped.fromAddress
    self._wrapped.fromAmount            = other._wrapped.fromAmount
    
    self._wrapped.toChainID             = other._wrapped.toChainID
    self._wrapped.toContractAddress     = other._wrapped.toContractAddress
    self._wrapped.toAddress             = other._wrapped.toAddress
    self._wrapped.toAmount              = other._wrapped.toAmount
    
    var allHashes = self._wrapped.hashes
    allHashes.append(contentsOf: other._wrapped.hashes)
    self._wrapped.hashes                = allHashes.uniqued(on: { $0 })
    
    other._wrapped.replaceHashes.forEach {
      self._wrapped.replaceHashes[$0.key] = $0.value
    }
    
    self._wrapped.timestamp = other._wrapped.timestamp
    
    if other._wrapped.hasID {
      self._wrapped.id = other._wrapped.id
    }
    if other._wrapped.hasOrderID {
      self._wrapped.orderID = other._wrapped.orderID
    }
    if other._wrapped.hasUpdatedAt {
      self._wrapped.updatedAt = other._wrapped.updatedAt
    }
    if other._wrapped.hasHashTo {
      self._wrapped.hashTo = other._wrapped.hashTo
    }
  }
}

// MARK: - _HistorySwap + ProtoWrappedMessage

extension _HistorySwap: ProtoWrappedMessage {
  func wrapped(_ chain: MDBXChain) -> HistorySwap {
    return HistorySwap(self, chain: chain)
  }
}

// MARK: - HistorySwap + Equatable

extension HistorySwap: Equatable {
  public static func ==(lhs: HistorySwap, rhs: HistorySwap) -> Bool {
    return lhs.fromChain == rhs.fromChain &&
           lhs.toChain == rhs.toChain &&
           lhs._wrapped.hashFrom == rhs._wrapped.hashFrom &&
           lhs._wrapped.hashTo == rhs._wrapped.hashTo
  }
}

// MARK: - HistorySwap + Identifiable

extension HistorySwap: Identifiable {
  /// The stable identity of the entity associated with this instance.
  public var id: String { self._wrapped.hashFrom }
}

// MARK: - HistorySwap + ProtoWrapper

extension HistorySwap: ProtoWrapper {
  init(_ wrapped: _HistorySwap, chain: MDBXChain) {
    self._chain = chain
    self._wrapped = wrapped
  }
}

// MARK: - HistorySwap + Comparable

extension HistorySwap: Comparable {
  /// First group - 'Pending'
  /// Second group - other
  /// Inside the group - by timestamp
  public static func < (lhs: HistorySwap, rhs: HistorySwap) -> Bool {
    // If equal statuses
    if lhs.status.isFinal == rhs.status.isFinal {
      return lhs.timestamp > rhs.timestamp
    }
    
    return lhs.status == .pending
  }
}

// MARK: - HistorySwap + Hashable

extension HistorySwap: Hashable {
  public func hash(into hasher: inout Hasher) {
    hasher.combine(_wrapped.status)
    hasher.combine(_wrapped.fromChainID)
    hasher.combine(_wrapped.fromContractAddress)
    hasher.combine(_wrapped.fromAmount)
    hasher.combine(_wrapped.fromAddress)
    hasher.combine(_wrapped.toChainID)
    hasher.combine(_wrapped.toContractAddress)
    hasher.combine(_wrapped.toAmount)
    hasher.combine(_wrapped.toAddress)
    hasher.combine(_wrapped.hashFrom)
    if _wrapped.hasHashTo {
      hasher.combine(_wrapped.hashTo)
    }
  }
}
