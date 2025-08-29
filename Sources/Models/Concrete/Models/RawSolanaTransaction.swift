//
//  RawSolanaTransaction.swift
//  mew-wallet-db
//
//  Created by Mitya 28/09/2025.
//

import Foundation
import SwiftProtobuf
import mdbx_ios

public struct RawSolanaTransaction: Equatable {
  public weak var database: (any WalletDB)?
  var _wrapped: _RawSolanaTransaction
  var _chain: MDBXChain
  
  // MARK: - LifeCycle
  
  public init(chain: MDBXChain,
              signature: String,
              fee: Decimal,
              instructions: [Instruction],
              accountKeys: [String],
              recentBlockhash: String? = nil,
              version: UInt32? = nil) {
    self.database = database ?? MEWwalletDBImpl.shared
    _wrapped = .with {
      $0.signature = signature
      $0.fee = (fee as NSDecimalNumber).uint64Value
      $0.instructions = instructions.map { instruction in
        .with {
          $0.programID = instruction.programId
          $0.accounts = instruction.accounts
          if let data = instruction.data {
            $0.data = data
          }
        }
      }
      $0.accountKeys = accountKeys
      if let recentBlockhash = recentBlockhash {
        $0.recentBlockhash = UInt64(recentBlockhash) ?? 0
      }
      if let version = version {
        $0.version = version
      }
    }
    self._chain = chain
  }
  
  // MARK: - Nested Types
  
  public struct Instruction {
    public let programId: String
    public let accounts: [String]
    public let data: Data?
    
    public init(programId: String, accounts: [String], data: Data? = nil) {
      self.programId = programId
      self.accounts = accounts
      self.data = data
    }
  }
}

// MARK: - RawSolanaTransaction + Properties

extension RawSolanaTransaction {
  // MARK: - Properties
  
  public var signature: String { _wrapped.signature }
  public var rawFee: Decimal { Decimal(_wrapped.fee) }
  //FIXME: Add solana to  mew-extensions Solana has 9 decimal places (lamports)
  public var fee: Decimal { rawFee.convert(to: .custom(9)) } 
  public var instructions: [Instruction] {
    _wrapped.instructions.map { instruction in
      Instruction(
        programId: instruction.programID,
        accounts: instruction.accounts,
        data: instruction.hasData ? instruction.data : nil
      )
    }
  }
  public var accountKeys: [String] { _wrapped.accountKeys }
  public var slot: UInt64? {
    guard _wrapped.hasBlock else { return nil }
    return _wrapped.block.slot
  }
  public var blockTime: UInt64? {
    guard _wrapped.hasBlock else { return nil }
    return _wrapped.block.blockTime
  }
  public var recentBlockhash: String? {
    guard _wrapped.hasRecentBlockhash else { return nil }
    return String(_wrapped.recentBlockhash)
  }
  public var version: UInt32? {
    guard _wrapped.hasVersion else { return nil }
    return _wrapped.version
  }
}

// MARK: - RawSolanaTransaction + MDBXObject

extension RawSolanaTransaction: MDBXObject {
  public var serialized: Data {
    get throws {
      return try _wrapped.serializedData()
    }
  }
  
  public var key: any MDBXKey {
    return RawSolanaTransaction.Key(chain: _chain, signature: self.signature)
  }
  
  public var alternateKey: (any MDBXKey)? { return nil }
  
  public init(serializedData data: Data, chain: MDBXChain, key: Data?) throws {
    self._chain = chain
    self._wrapped = try _RawSolanaTransaction(serializedBytes: data)
  }
  
  public init(jsonData: Data, chain: MDBXChain, key: Data?) throws {
    var options = JSONDecodingOptions()
    options.ignoreUnknownFields = true
    self._chain = chain
    self._wrapped = try _RawSolanaTransaction(jsonUTF8Data: jsonData, options: options)
  }
  
  public init(jsonString: String, chain: MDBXChain, key: Data?) throws {
    var options = JSONDecodingOptions()
    options.ignoreUnknownFields = true
    self._chain = chain
    self._wrapped = try _RawSolanaTransaction(jsonString: jsonString, options: options)
  }
  
  public static func array(fromJSONString string: String, chain: MDBXChain) throws -> [Self] {
    var options = JSONDecodingOptions()
    options.ignoreUnknownFields = true
    let objects = try _RawSolanaTransaction.array(fromJSONString: string, options: options)
    return objects.lazy.map({ $0.wrapped(chain) })
  }
  
  public static func array(fromJSONData data: Data, chain: MDBXChain) throws -> [Self] {
    var options = JSONDecodingOptions()
    options.ignoreUnknownFields = true
    let objects = try _RawSolanaTransaction.array(fromJSONUTF8Data: data, options: options)
    return objects.lazy.map({ $0.wrapped(chain) })
  }
  
  mutating public func merge(with object: any MDBXObject) {
    let other = object as! RawSolanaTransaction
    
    self._wrapped.signature = other._wrapped.signature
    self._wrapped.fee = other._wrapped.fee
    if !other._wrapped.instructions.isEmpty {
      self._wrapped.instructions = other._wrapped.instructions
    }
    if !other._wrapped.accountKeys.isEmpty {
      self._wrapped.accountKeys = other._wrapped.accountKeys
    }
    if other._wrapped.hasBlock {
      self._wrapped.block = other._wrapped.block
    }
    if other._wrapped.hasRecentBlockhash {
      self._wrapped.recentBlockhash = other._wrapped.recentBlockhash
    }
    if other._wrapped.hasVersion {
      self._wrapped.version = other._wrapped.version
    }
  }
}

// MARK: - _RawSolanaTransaction + ProtoWrappedMessage

extension _RawSolanaTransaction: ProtoWrappedMessage {
  func wrapped(_ chain: MDBXChain) -> RawSolanaTransaction {
    return RawSolanaTransaction(self, chain: chain)
  }
}

// MARK: - RawSolanaTransaction + Equatable

public extension RawSolanaTransaction {
  static func ==(lhs: RawSolanaTransaction, rhs: RawSolanaTransaction) -> Bool {
    return lhs._chain == rhs._chain &&
           lhs._wrapped == rhs._wrapped
  }
}

// MARK: - RawSolanaTransaction + ProtoWrapper

extension RawSolanaTransaction: ProtoWrapper {
  init(_ wrapped: _RawSolanaTransaction, chain: MDBXChain) {
    self._chain = chain
    self._wrapped = wrapped
  }
}
