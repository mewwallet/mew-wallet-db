//
//  File.swift
//  mew-wallet-db
//
//  Created by Mikhail Nikanorov on 5/13/25.
//

import Foundation
import SwiftProtobuf
import mdbx_ios

public struct RawBitcoinTransaction: Equatable {
  public weak var database: (any WalletDB)?
  var _wrapped: _RawBitcoinTransaction
  var _chain: MDBXChain
  
  // MARK: - LifeCycle
  
  public init(chain: MDBXChain,
              txid: String,
              from: Address,
              fromAmount: Decimal,
              to: Address,
              toAmount: Decimal,
              fee: Decimal) {
    self.database = database ?? MEWwalletDBImpl.shared
    _wrapped = .with {
      $0.txid = txid
      $0.fee = (fee as NSDecimalNumber).uint64Value
      $0.inputs = [
        .with({
          $0.address = from.rawValue
          $0.value = (fromAmount as NSDecimalNumber).uint64Value
        })
      ]
      $0.outputs = [
        .with({
          $0.address = to.rawValue
          $0.value = (toAmount as NSDecimalNumber).uint64Value
        })
      ]
    }
    self._chain = chain
  }
}

// MARK: - RawBitcoinTransaction + Properties

extension RawBitcoinTransaction {
  // MARK: - Properties
  
  public var hash: String { _wrapped.txid }
  public var rawFee: Decimal { Decimal(_wrapped.fee) }
  public var fee: Decimal { rawFee.convert(to: .bitcoin) }
  public var block: Int64? {
    guard _wrapped.hasBlock else { return nil }
    guard _wrapped.block.height != -1 else { return nil }
    return _wrapped.block.height
  }
}

// MARK: - RawBitcoinTransaction + MDBXObject

extension RawBitcoinTransaction: MDBXObject {
  public var serialized: Data {
    get throws {
      return try _wrapped.serializedData()
    }
  }
  
  public var key: any MDBXKey {
    return RawBitcoinTransaction.Key(chain: _chain, hash: self.hash)
  }
  
  public var alternateKey: (any MDBXKey)? { return nil }
  
  public init(serializedData data: Data, chain: MDBXChain, key: Data?) throws {
    self._chain = chain
    self._wrapped = try _RawBitcoinTransaction(serializedBytes: data)
  }
  
  public init(jsonData: Data, chain: MDBXChain, key: Data?) throws {
    var options = JSONDecodingOptions()
    options.ignoreUnknownFields = true
    self._chain = chain
    self._wrapped = try _RawBitcoinTransaction(jsonUTF8Data: jsonData, options: options)
  }
  
  public init(jsonString: String, chain: MDBXChain, key: Data?) throws {
    var options = JSONDecodingOptions()
    options.ignoreUnknownFields = true
    self._chain = chain
    self._wrapped = try _RawBitcoinTransaction(jsonString: jsonString, options: options)
  }
  
  public static func array(fromJSONString string: String, chain: MDBXChain) throws -> [Self] {
    var options = JSONDecodingOptions()
    options.ignoreUnknownFields = true
    let objects = try _RawBitcoinTransaction.array(fromJSONString: string, options: options)
    return objects.lazy.map({ $0.wrapped(chain) })
  }
  
  public static func array(fromJSONData data: Data, chain: MDBXChain) throws -> [Self] {
    var options = JSONDecodingOptions()
    options.ignoreUnknownFields = true
    let objects = try _RawBitcoinTransaction.array(fromJSONUTF8Data: data, options: options)
    return objects.lazy.map({ $0.wrapped(chain) })
  }
  
  mutating public func merge(with object: any MDBXObject) {
    let other = object as! RawBitcoinTransaction
    
    self._wrapped.txid                  = other._wrapped.txid
    self._wrapped.fee                   = other._wrapped.fee
    if !other._wrapped.inputs.isEmpty {
      self._wrapped.inputs = other._wrapped.inputs
    }
    if !other._wrapped.outputs.isEmpty {
      self._wrapped.outputs = other._wrapped.outputs
    }
    if other._wrapped.hasBlock {
      self._wrapped.block = other._wrapped.block
    }
  }
}

// MARK: - _RawBitcoinTransaction + ProtoWrappedMessage

extension _RawBitcoinTransaction: ProtoWrappedMessage {
  func wrapped(_ chain: MDBXChain) -> RawBitcoinTransaction {
    return RawBitcoinTransaction(self, chain: chain)
  }
}

// MARK: - RawBitcoinTransaction + Equatable

public extension RawBitcoinTransaction {
  static func ==(lhs: RawBitcoinTransaction, rhs: RawBitcoinTransaction) -> Bool {
    return lhs._chain == rhs._chain &&
           lhs._wrapped == rhs._wrapped
  }
}

// MARK: - RawBitcoinTransaction + ProtoWrapper

extension RawBitcoinTransaction: ProtoWrapper {
  init(_ wrapped: _RawBitcoinTransaction, chain: MDBXChain) {
    self._chain = chain
    self._wrapped = wrapped
  }
}
