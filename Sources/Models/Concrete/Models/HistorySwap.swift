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
    case success = "SUCCESS"
    case failed  = "FAIL"
    
    public init(rawValue: String) {
      switch rawValue {
      case "PENDING":   self = .pending
      case "SUCCESS":   self = .success
      case "FAIL":      self = .failed
      default:          self = .pending
      }
    }
    
    public init(_ status: History.Status) {
      switch status {
      case .pending:    self = .pending
      case .success:    self = .success
      case .failed:     self = .failed
      }
    }
  }
  
  public weak var database: WalletDB?
  var _wrapped: _HistorySwap
  var _chain: MDBXChain
  
  // MARK: - Private Properties
  private let _fromMeta: MDBXPointer<TokenMetaKey, TokenMeta> = .init(.tokenMeta)
  private let _toMeta: MDBXPointer<TokenMetaKey, TokenMeta> = .init(.tokenMeta)
  private let _account: MDBXPointer<AccountKey, Account> = .init(.account)

   
  public init(chain: MDBXChain,
              address: Address,
              fromToken: Address,
              toToken: Address,
              fromAmount: Decimal,
              toAmount: Decimal,
              status: Status,
              dex: String,
              hashes: [String],
              database: WalletDB? = nil) {

    precondition(!hashes.isEmpty)
    self.database = database ?? MEWwalletDBImpl.shared
    self._wrapped = .with {
      $0.address = address.rawValue
      $0.toAddress = address.rawValue
      
      $0.fromToken = fromToken.rawValue
      $0.toToken = toToken.rawValue
      
      $0.fromAmount = fromAmount.hexString
      $0.toAmount = toAmount.hexString
      
      $0.status = status.rawValue
      
      $0.dex = dex
      
      $0.hash = hashes.last!
      $0.hashes.append(contentsOf: hashes)
      
      $0.timestamp = .init(date: Date())
    }
    self._chain = chain
  }
}

// MARK: - HistorySwap + Properties

extension HistorySwap {
  
  // MARK: - Relations
  
  public var account: Account {
    get throws {
      let address = Address(rawValue: _wrapped.address)
      return try _account.getData(key: AccountKey(address: address), policy: .cacheOrLoad(chain: .universal), database: self.database)
    }
  }

  public var fromMeta: TokenMeta {
    get throws {
      let contractAddress = Address(rawValue: _wrapped.fromToken)
      return try _fromMeta.getData(key: TokenMetaKey(chain: _chain, contractAddress: contractAddress), policy: .cacheOrLoad(chain: _chain), database: self.database)
    }
  }
  
  public var toMeta: TokenMeta {
    get throws {
      let contractAddress = Address(rawValue: _wrapped.toToken)
      return try _toMeta.getData(key: TokenMetaKey(chain: _chain, contractAddress: contractAddress), policy: .cacheOrLoad(chain: _chain), database: self.database)
    }
  }
  
  // MARK: - Properties
  
  public var rawFromAmount: Decimal { Decimal(wrapped: _wrapped.fromAmount, hex: true) ?? .zero }
  public var rawToAmount: Decimal { Decimal(wrapped: _wrapped.toAmount, hex: true) ?? .zero }
  public var status: History.Status {
    set { _wrapped.status = HistorySwap.Status(newValue).rawValue }
    get { History.Status(_status) }
  }
  public var dex: String { _wrapped.dex }
  public var hash: String { _wrapped.hash }
  public var currentHash: String {
    var hash = self._wrapped.hash
    while let replace = _wrapped.replaceHashes[hash] {
      hash = replace
    }
    return hash
  }
  public var knownHashes: [String] {
    var hashes = _wrapped.hashes
    hashes.append(contentsOf: _wrapped.replaceHashes.values)
    return hashes
  }
  public var timestamp: Date { return _wrapped.timestamp.date }
  
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
  
  public var key: MDBXKey {
    return HistorySwapKey(chain: _chain, account: .unknown(_wrapped.address), hash: _wrapped.hash)
  }
  
  public var alternateKey: MDBXKey? { return nil }
  
  public init(serializedData data: Data, chain: MDBXChain, key: Data?) throws {
    self._chain = chain
    self._wrapped = try _HistorySwap(serializedData: data)
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
  
  mutating public func merge(with object: MDBXObject) {
    let other = object as! HistorySwap
    
    self._wrapped.address         = other._wrapped.address
    self._wrapped.fromToken       = other._wrapped.fromToken
    self._wrapped.toToken         = other._wrapped.toToken
    self._wrapped.fromAmount      = other._wrapped.fromAmount
    self._wrapped.toAmount        = other._wrapped.toAmount
    self._wrapped.toAddress       = other._wrapped.toAddress
    self._wrapped.status          = other._wrapped.status
    self._wrapped.dex             = other._wrapped.dex
    self._wrapped.hash            = other._wrapped.hash
    self._wrapped.hashes          = other._wrapped.hashes
    self._wrapped.replaceHashes   = other._wrapped.replaceHashes
    self._wrapped.timestamp       = other._wrapped.timestamp
  }
}

// MARK: - _HistorySwap + ProtoWrappedMessage

extension _HistorySwap: ProtoWrappedMessage {
  func wrapped(_ chain: MDBXChain) -> HistorySwap {
    return HistorySwap(self, chain: chain)
  }
}

// MARK: - HistorySwap + Equitable

extension HistorySwap: Equatable {
  public static func ==(lhs: HistorySwap, rhs: HistorySwap) -> Bool {
    return lhs._chain == rhs._chain &&
           lhs._wrapped.hash == rhs._wrapped.hash
  }
}

// MARK: - HistorySwap + Identifiable

extension HistorySwap: Identifiable {
  /// The stable identity of the entity associated with this instance.
  public var id: String { self._wrapped.hash }
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
    hasher.combine(_wrapped.fromToken)
    hasher.combine(_wrapped.fromAmount)
    hasher.combine(_wrapped.toToken)
    hasher.combine(_wrapped.toAmount)
    hasher.combine(_wrapped.address)
    hasher.combine(_wrapped.hash)
  }
}
