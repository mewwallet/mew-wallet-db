//
//  File.swift
//  
//
//  Created by Mikhail Nikanorov on 3/6/22.
//

import Foundation
import SwiftProtobuf
import mdbx_ios

public struct RawTransaction: Equatable {
  public weak var database: WalletDB?
  var _wrapped: _RawTransaction
  var _chain: MDBXChain
  
  // MARK: - LifeCycle
  
  public init(chain: MDBXChain,
       hash: String,
       from: String,
       to: String?,
       value: String,
       input: String,
       nonce: String,
       gas: String,
       gasPrice: String,
       blockNumber: String?,
       maxFeePerGas: String?,
       maxPriorityFeePerGas: String?,
       database: WalletDB? = nil) {
    self.database = database ?? MEWwalletDBImpl.shared
    var transaction = _RawTransaction.with {
      $0.hash = hash
      $0.from = from
      $0.value = value
      $0.input = input
      $0.nonce = nonce
      $0.gas = gas
      $0.gasPrice = gasPrice
    }
    if let to = to {
      transaction.to = to
    }
    if let blockNumber = blockNumber {
      transaction.blockNumber = blockNumber
    }
    if let maxFeePerGas = maxFeePerGas {
      transaction.maxFeePerGas = maxFeePerGas
    }
    if let maxPriorityFeePerGas = maxPriorityFeePerGas {
      transaction.maxPriorityFeePerGas = maxPriorityFeePerGas
    }
    _wrapped = transaction
    self._chain = chain
  }
}

// MARK: - RawTransaction + Properties

extension RawTransaction {
  // MARK: - Properties
  
  public var hash: String { self._wrapped.hash }
  public var from: String { self._wrapped.from }
  public var to: String? {
    guard self._wrapped.hasTo else { return nil }
    return self._wrapped.to
  }
  public var value: Decimal { Decimal(hex: self._wrapped.value) }
  public var input: Data { Data(hex: self._wrapped.input) }
  public var nonce: Decimal { Decimal(hex: self._wrapped.nonce) }
  public var blockNumber: Decimal? {
    guard self._wrapped.hasBlockNumber else { return nil }
    return Decimal(hex: self._wrapped.blockNumber)
  }
  public var gas: Decimal { Decimal(hex: self._wrapped.gas) }
  public var gasPrice: Decimal { Decimal(hex: self._wrapped.gasPrice) }
  public var maxFeePerGas: Decimal? {
    guard self._wrapped.hasMaxFeePerGas else { return nil }
    return Decimal(hex: self._wrapped.maxFeePerGas)
  }
  public var maxPriorityFeePerGas: Decimal? {
    guard self._wrapped.hasMaxPriorityFeePerGas else { return nil }
    return Decimal(hex: self._wrapped.maxPriorityFeePerGas)
  }
}

// MARK: - RawTransaction + MDBXObject

extension RawTransaction: MDBXObject {
  public var serialized: Data {
    get throws {
      return try self._wrapped.serializedData()
    }
  }
  
  public var key: MDBXKey {
    return RawTransactionKey(chain: _chain, hash: self.hash)
  }
  
  public var alternateKey: MDBXKey? { return nil }
  
  public init(serializedData data: Data, chain: MDBXChain, key: Data?) throws {
    self._chain = chain
    self._wrapped = try _RawTransaction(serializedData: data)
  }
  
  public init(jsonData: Data, chain: MDBXChain, key: Data?) throws {
    var options = JSONDecodingOptions()
    options.ignoreUnknownFields = true
    self._chain = chain
    self._wrapped = try _RawTransaction(jsonUTF8Data: jsonData, options: options)
  }
  
  public init(jsonString: String, chain: MDBXChain, key: Data?) throws {
    var options = JSONDecodingOptions()
    options.ignoreUnknownFields = true
    self._chain = chain
    self._wrapped = try _RawTransaction(jsonString: jsonString, options: options)
  }
  
  public static func array(fromJSONString string: String, chain: MDBXChain) throws -> [Self] {
    var options = JSONDecodingOptions()
    options.ignoreUnknownFields = true
    let objects = try _RawTransaction.array(fromJSONString: string, options: options)
    return objects.lazy.map({ $0.wrapped(chain) })
  }
  
  public static func array(fromJSONData data: Data, chain: MDBXChain) throws -> [Self] {
    var options = JSONDecodingOptions()
    options.ignoreUnknownFields = true
    let objects = try _RawTransaction.array(fromJSONUTF8Data: data, options: options)
    return objects.lazy.map({ $0.wrapped(chain) })
  }
  
  mutating public func merge(with object: MDBXObject) {
    let other = object as! RawTransaction
    
    self._wrapped.hash                  = other._wrapped.hash
    self._wrapped.from                  = other._wrapped.from
    self._wrapped.value                 = other._wrapped.value
    self._wrapped.input                 = other._wrapped.input
    self._wrapped.nonce                 = other._wrapped.nonce
    self._wrapped.gas                   = other._wrapped.gas
    self._wrapped.gasPrice              = other._wrapped.gasPrice
    if other._wrapped.hasTo {
      self._wrapped.to                    = other._wrapped.to
    }
    if other._wrapped.hasBlockNumber {
      self._wrapped.blockNumber         = other._wrapped.blockNumber
    }
    if other._wrapped.hasMaxFeePerGas {
      self._wrapped.maxFeePerGas        = other._wrapped.maxFeePerGas
    }
    if other._wrapped.hasMaxPriorityFeePerGas {
      self._wrapped.maxPriorityFeePerGas  = other._wrapped.maxPriorityFeePerGas
    }
  }
}

// MARK: - _RawTransaction + ProtoWrappedMessage

extension _RawTransaction: ProtoWrappedMessage {
  func wrapped(_ chain: MDBXChain) -> RawTransaction {
    return RawTransaction(self, chain: chain)
  }
}

// MARK: - RawTransaction + Equitable

public extension RawTransaction {
  static func ==(lhs: RawTransaction, rhs: RawTransaction) -> Bool {
    return lhs._chain == rhs._chain &&
           lhs._wrapped == rhs._wrapped
  }
}

// MARK: - RawTransaction + ProtoWrapper

extension RawTransaction: ProtoWrapper {
  init(_ wrapped: _RawTransaction, chain: MDBXChain) {
    self._chain = chain
    self._wrapped = wrapped
  }
}
