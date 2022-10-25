//
//  File.swift
//  
//
//  Created by Mikhail Nikanorov on 10/24/22.
//

import Foundation
import SwiftProtobuf
import mdbx_ios

public struct HistoryPurchase {
  public enum Status: String {
    case completed    = "COMPLETED"
    case complete     = "COMPLETE"
    case processing   = "PROCESSING"
    case failed       = "FAILED"
    case waiting      = "WAITING"
    
    public init(rawValue: String) {
      switch rawValue {
      case "COMPLETE":    self = .complete
      case "COMPLETED":   self = .completed
      case "PROCESSING":  self = .processing
      case "FAILED":      self = .failed
      case "WAITING":     self = .waiting
      default:            self = .waiting
      }
    }
    
    public init(_ status: History.Status) {
      switch status {
      case .pending:    self = .waiting
      case .success:    self = .completed
      case .failed:     self = .failed
      }
    }
  }
  
  public weak var database: WalletDB?
  var _wrapped: _HistoryPurchase
  var _chain: MDBXChain
  
  // MARK: - Private Properties
  private let _meta: MDBXPointer<TokenMetaKey, TokenMeta> = .init(.tokenMeta)
  private let _account: MDBXPointer<AccountKey, Account> = .init(.account)
}

// MARK: - HistoryPurchase + Properties

extension HistoryPurchase {
  
  // MARK: - Relations
  
  public var account: Account {
    get throws {
      let address = Address(rawValue: _wrapped.address)
      return try _account.getData(key: AccountKey(chain: _chain, address: address), policy: .cacheOrLoad, database: self.database)
    }
  }

  public var meta: TokenMeta {
    get throws {
      let contractAddress: Address
      if _wrapped.hasContractAddress {
        contractAddress = Address(rawValue: _wrapped.contractAddress)
      } else {
        contractAddress = .primary
      }
      return try _meta.getData(key: TokenMetaKey(chain: _chain, contractAddress: contractAddress), policy: .cacheOrLoad, database: self.database)
    }
  }
  
  // MARK: - Properties

  public var status: History.Status {
    set { _wrapped.status = HistoryPurchase.Status(newValue).rawValue }
    get { History.Status(_status) }
  }
  public var transactionID: String { return _wrapped.transactionID }
  public var fiatAmount: Decimal { return Decimal(wrapped: _wrapped.fiatAmount, hex: false) ?? .zero }
  public var fiatCurrency: String { return _wrapped.fiatCurrency }
  public var amount: Decimal { return Decimal(wrapped: _wrapped.cryptoAmount, hex: true) ?? .zero }
  public var provider: String { return _wrapped.provider }
  public var timestamp: Date { return _wrapped.timestamp.date }
  public var details: Data? {
    guard _wrapped.hasOrderDetails else { return nil }
    return _wrapped.orderDetails
  }
  
  // MARK: - Private
  
  private var _status: Status { Status(rawValue: _wrapped.status)}
}

// MARK: - HistoryPurchase + MDBXObject

extension HistoryPurchase: MDBXObject {
  public var serialized: Data {
    get throws {
      return try self._wrapped.serializedData()
    }
  }
  
  public var key: MDBXKey {
    return HistoryPurchaseKey(chain: _chain, account: .unknown(_wrapped.address), transactionID: _wrapped.transactionID)
  }
  
  public var alternateKey: MDBXKey? { return nil }
  
  public init(serializedData data: Data, chain: MDBXChain, key: Data?) throws {
    self._chain = chain
    self._wrapped = try _HistoryPurchase(serializedData: data)
  }
  
  public init(jsonData: Data, chain: MDBXChain, key: Data?) throws {
    var options = JSONDecodingOptions()
    options.ignoreUnknownFields = true
    self._chain = chain
    self._wrapped = try _HistoryPurchase(jsonUTF8Data: jsonData, options: options)
  }
  
  public init(jsonString: String, chain: MDBXChain, key: Data?) throws {
    var options = JSONDecodingOptions()
    options.ignoreUnknownFields = true
    self._chain = chain
    self._wrapped = try _HistoryPurchase(jsonString: jsonString, options: options)
  }
  
  public static func array(fromJSONString string: String, chain: MDBXChain) throws -> [Self] {
    var options = JSONDecodingOptions()
    options.ignoreUnknownFields = true
    let objects = try _HistoryPurchase.array(fromJSONString: string, options: options)
    return objects.lazy.map({ $0.wrapped(chain) })
  }
  
  public static func array(fromJSONData data: Data, chain: MDBXChain) throws -> [Self] {
    var options = JSONDecodingOptions()
    options.ignoreUnknownFields = true
    let objects = try _HistoryPurchase.array(fromJSONUTF8Data: data, options: options)
    return objects.lazy.map({ $0.wrapped(chain) })
  }
  
  mutating public func merge(with object: MDBXObject) {
    let other = object as! HistoryPurchase
    
    self._wrapped.address               = other._wrapped.address
    self._wrapped.transactionID         = other._wrapped.transactionID
    self._wrapped.fiatAmount            = other._wrapped.fiatAmount
    self._wrapped.fiatCurrency          = other._wrapped.fiatCurrency
    self._wrapped.cryptoAmount          = other._wrapped.cryptoAmount
    if other._wrapped.hasContractAddress {
      self._wrapped.contractAddress     = other._wrapped.contractAddress
    }
    self._wrapped.status                = other._wrapped.status
    self._wrapped.provider              = other._wrapped.provider
    self._wrapped.timestamp             = other._wrapped.timestamp
    if other._wrapped.hasOrderDetails {
      self._wrapped.orderDetails        = other._wrapped.orderDetails
    }
  }
}

// MARK: - _HistoryPurchase + ProtoWrappedMessage

extension _HistoryPurchase: ProtoWrappedMessage {
  func wrapped(_ chain: MDBXChain) -> HistoryPurchase {
    return HistoryPurchase(self, chain: chain)
  }
}

// MARK: - HistoryPurchase + Equitable

extension HistoryPurchase: Equatable {
  public static func ==(lhs: HistoryPurchase, rhs: HistoryPurchase) -> Bool {
    return lhs._chain == rhs._chain &&
           lhs._wrapped.transactionID == rhs._wrapped.transactionID
  }
}

// MARK: - HistoryPurchase + Identifiable

extension HistoryPurchase: Identifiable {
  /// The stable identity of the entity associated with this instance.
  public var id: String { self._wrapped.transactionID }
}

// MARK: - HistoryPurchase + ProtoWrapper

extension HistoryPurchase: ProtoWrapper {
  init(_ wrapped: _HistoryPurchase, chain: MDBXChain) {
    self._chain = chain
    self._wrapped = wrapped
  }
}

// MARK: - HistoryPurchase + Comparable

extension HistoryPurchase: Comparable {
  /// First group - 'Pending'
  /// Second group - other
  /// Inside the group - by timestamp
  public static func < (lhs: HistoryPurchase, rhs: HistoryPurchase) -> Bool {
    // If equal statuses
    if lhs.status.isFinal == rhs.status.isFinal {
      return lhs.timestamp > rhs.timestamp
    }
    
    return lhs.status == .pending
  }
}

// MARK: - HistoryPurchase + Hashable

extension HistoryPurchase: Hashable {
  public func hash(into hasher: inout Hasher) {
    hasher.combine(_wrapped.address)
    hasher.combine(_wrapped.transactionID)
    hasher.combine(_wrapped.fiatAmount)
    hasher.combine(_wrapped.fiatCurrency)
    hasher.combine(_wrapped.cryptoAmount)
    if _wrapped.hasContractAddress {
      hasher.combine(_wrapped.contractAddress)
    }
    hasher.combine(_wrapped.status)
    hasher.combine(_wrapped.provider)
    hasher.combine(_wrapped.timestamp)
    if _wrapped.hasOrderDetails {
      hasher.combine(_wrapped.orderDetails)
    }
  }
}
