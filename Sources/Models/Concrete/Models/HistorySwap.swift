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
      return try _account.getData(key: AccountKey(chain: _chain, address: address), policy: .cacheOrLoad, database: self.database)
    }
  }

  public var fromMeta: TokenMeta {
    get throws {
      let contractAddress = Address(rawValue: _wrapped.fromToken)
      return try _fromMeta.getData(key: TokenMetaKey(chain: _chain, contractAddress: contractAddress), policy: .cacheOrLoad, database: self.database)
    }
  }
  
  public var toMeta: TokenMeta {
    get throws {
      let contractAddress = Address(rawValue: _wrapped.toToken)
      return try _toMeta.getData(key: TokenMetaKey(chain: _chain, contractAddress: contractAddress), policy: .cacheOrLoad, database: self.database)
    }
  }
  
  // MARK: - Properties
  
  public var rawFromAmount: Decimal { Decimal(wrapped: self._wrapped.fromAmount, hex: true) ?? .zero }
  public var rawToAmount: Decimal { Decimal(wrapped: self._wrapped.toAmount, hex: true) ?? .zero }
  public var status: History.Status { History.Status(_status) }
  public var dex: String { return self._wrapped.dex }
  public var hash: String {
    // TODO: jump between hashes
    return self._wrapped.hash
  }
  public var timestamp: Date { return self._wrapped.timestamp.date }
  
  // MARK: - Private
  
  private var _status: Status { Status(rawValue: self._wrapped.status) ?? .pending}
}

// MARK: - Transfer + MDBXObject

extension HistorySwap: MDBXObject {
  public var serialized: Data {
    get throws {
      return try self._wrapped.serializedData()
    }
  }
  
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
//    let other = object as! TokenMeta
//
//    self._wrapped.contractAddress       = other._wrapped.contractAddress
//    self._wrapped.name                  = other._wrapped.name
//    self._wrapped.symbol                = other._wrapped.symbol
//    if other._wrapped.hasDecimals {
//      self._wrapped.decimals            = other._wrapped.decimals
//    }
//    if other._wrapped.hasIcon {
//      self._wrapped.icon                = other._wrapped.icon
//    }
//    if other._wrapped.hasPrice {
//      self._wrapped.price               = other._wrapped.price
//    }
//    if other._wrapped.hasMarketCap {
//      self._wrapped.marketCap           = other._wrapped.marketCap
//    }
//    if !other._wrapped.sparkline.isEmpty {
//      self._wrapped.sparkline           = other._wrapped.sparkline
//    }
//    if other._wrapped.hasVolume24H {
//      self._wrapped.volume24H           = other._wrapped.volume24H
//    }
  }
}

// MARK: - _Transfer + ProtoWrappedMessage

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
    if lhs.status == rhs.status {
      return lhs.timestamp < rhs.timestamp
    }
    
    return lhs.status == .pending
  }
}
