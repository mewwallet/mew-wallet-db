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
      default:          self = .waiting
      }
    }
  }
  
  public weak var database: WalletDB?
  var _wrapped: _HistoryPurchase
  var _chain: MDBXChain
  
  // MARK: - Private Properties
  private let _meta: MDBXPointer<TokenMetaKey, TokenMeta> = .init(.tokenMeta)
  private let _account: MDBXPointer<AccountKey, Account> = .init(.account)
  @SubProperty<_ChainedContractAddress, ChainedContractAddress> private var _crypto_currency: _ChainedContractAddress?
}

// MARK: - HistoryPurchase + Properties

extension HistoryPurchase {
  
  // MARK: - Relations
  
  public var account: Account {
    get throws {
      let address = Address(rawValue: _wrapped.address)
      return try _account.getData(key: AccountKey(address: address), policy: .cacheOrLoad(chain: .universal), database: self.database)
    }
  }

  public var meta: TokenMeta {
    get throws {
      guard _wrapped.hasCryptoCurrency, let crypto_currency = $_crypto_currency else {
        return try _meta.getData(key: TokenMetaKey(chain: .eth, contractAddress: .primary), policy: .cacheOrLoad(chain: .eth), database: self.database)
      }
      
      let chain = crypto_currency.chain
      let address = crypto_currency.address
      return try _meta.getData(key: TokenMetaKey(chain: chain, contractAddress: address), policy: .cacheOrLoad(chain: chain), database: self.database)
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
    return Data(hex: _wrapped.orderDetails)
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
    return HistoryPurchaseKey(account: .unknown(_wrapped.address), transactionID: _wrapped.transactionID)
  }
  
  public var alternateKey: MDBXKey? { return nil }
  
  public init(serializedData data: Data, chain: MDBXChain, key: Data?) throws {
    self._chain = .universal
    self._wrapped = try _HistoryPurchase(serializedData: data)
    self.commonInit(chain: .universal)
  }
  
  public init(jsonData: Data, chain: MDBXChain, key: Data?) throws {
    var options = JSONDecodingOptions()
    options.ignoreUnknownFields = true
    self._chain = .universal
    self._wrapped = try _HistoryPurchase(jsonUTF8Data: jsonData, options: options)
    self.commonInit(chain: .universal)
  }
  
  public init(jsonString: String, chain: MDBXChain, key: Data?) throws {
    var options = JSONDecodingOptions()
    options.ignoreUnknownFields = true
    self._chain = .universal
    self._wrapped = try _HistoryPurchase(jsonString: jsonString, options: options)
    self.commonInit(chain: .universal)
  }
  
  public static func array(fromJSONString string: String, chain: MDBXChain) throws -> [Self] {
    var options = JSONDecodingOptions()
    options.ignoreUnknownFields = true
    let objects = try _HistoryPurchase.array(fromJSONString: string, options: options)
    return objects.lazy.map({ $0.wrapped(.universal) })
  }
  
  public static func array(fromJSONData data: Data, chain: MDBXChain) throws -> [Self] {
    var options = JSONDecodingOptions()
    options.ignoreUnknownFields = true
    let objects = try _HistoryPurchase.array(fromJSONUTF8Data: data, options: options)
    return objects.lazy.map({ $0.wrapped(.universal) })
  }
  
  mutating public func merge(with object: MDBXObject) {
    let other = object as! HistoryPurchase
    
    self._wrapped.address               = other._wrapped.address
    self._wrapped.transactionID         = other._wrapped.transactionID
    self._wrapped.fiatAmount            = other._wrapped.fiatAmount
    self._wrapped.fiatCurrency          = other._wrapped.fiatCurrency
    self._wrapped.cryptoAmount          = other._wrapped.cryptoAmount
    if other._wrapped.hasCryptoCurrency {
      self._wrapped.cryptoCurrency      = other._wrapped.cryptoCurrency
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
    var purchase = HistoryPurchase(self, chain: .universal)
    purchase.commonInit(chain: .universal)
    return purchase
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
    self._chain = .universal
    self._wrapped = wrapped
    self.commonInit(chain: .universal)
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
    if _wrapped.hasCryptoCurrency {
      hasher.combine(_wrapped.cryptoCurrency)
    }
    hasher.combine(_wrapped.status)
    hasher.combine(_wrapped.provider)
    hasher.combine(_wrapped.timestamp)
    if _wrapped.hasOrderDetails {
      hasher.combine(_wrapped.orderDetails)
    }
  }
}

// MARK: - HistoryPurchase + CommonInit

extension HistoryPurchase {
  mutating func commonInit(chain: MDBXChain) {
    // Wrappers
    __crypto_currency.chain = .universal
    __crypto_currency.wrappedValue = _wrapped.cryptoCurrency
    self.populateDB()
  }

  func populateDB() {
    __crypto_currency.database = database
  }
}
