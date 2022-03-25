//
//  File.swift
//  
//
//  Created by Mikhail Nikanorov on 3/21/22.
//

import Foundation
import SwiftProtobuf
import mdbx_ios

public struct Token: Equatable {
  public weak var database: WalletDB?
  var _wrapped: _Token
  var _chain: MDBXChain
  
  // MARK: - Private Properties
  
  private let _metaKey: TokenMetaKey
  private let _meta: MDBXPointer<TokenMetaKey, TokenMeta> = .init(.tokenMeta)
  
  // MARK: - LifeCycle
    
  public init(chain: MDBXChain, address: String, contractAddress: String, database: WalletDB? = nil) {
    self.database = database ?? MEWwalletDBImpl.shared
    self._wrapped = .with {
      $0.contractAddress = contractAddress
      $0.address = address
    }
    self._chain = chain
    self._metaKey = TokenMetaKey(chain: chain, contractAddress: contractAddress)
  }
}

// MARK: - Token + Properties

extension Token {
  // MARK: - Relations
  
  public var meta: TokenMeta {
    get throws {
      return try _meta.getData(key: self._metaKey, policy: .cacheOrLoad, database: self.database)
    }
  }
  
  // MARK: - Properties
  
  public var contract_address: String { self._wrapped.contractAddress }
  public var address: String { self._wrapped.address }
  public var amount: Decimal { Decimal(wrapped: self._wrapped.amount, hex: true) ?? .zero }
  public var lockedAmount: Decimal { Decimal(wrapped: self._wrapped.lockedAmount, hex: true) ?? .zero }
}

// MARK: - Token + MDBXObject

extension Token: MDBXObject {
  public var serialized: Data {
    get throws {
      return try self._wrapped.serializedData()
    }
  }
  
  public var key: MDBXKey {
    return TokenKey(chain: _chain, address: self.address, contractAddress: self.contract_address)
  }
  
  public var alternateKey: MDBXKey? { return nil }
  
  public init(serializedData data: Data, chain: MDBXChain, key: Data?) throws {
    self._chain = chain
    self._wrapped = try _Token(serializedData: data)
    self._metaKey = TokenMetaKey(chain: chain, contractAddress: self._wrapped.contractAddress)
  }
  
  public init(jsonData: Data, chain: MDBXChain, key: Data?) throws {
    var options = JSONDecodingOptions()
    options.ignoreUnknownFields = true
    self._chain = chain
    self._wrapped = try _Token(jsonUTF8Data: jsonData, options: options)
    self._metaKey = TokenMetaKey(chain: chain, contractAddress: self._wrapped.contractAddress)
  }
  
  public init(jsonString: String, chain: MDBXChain, key: Data?) throws {
    var options = JSONDecodingOptions()
    options.ignoreUnknownFields = true
    self._chain = chain
    self._wrapped = try _Token(jsonString: jsonString, options: options)
    self._metaKey = TokenMetaKey(chain: chain, contractAddress: self._wrapped.contractAddress)
  }
  
  public static func array(fromJSONString string: String, chain: MDBXChain) throws -> [Self] {
    var options = JSONDecodingOptions()
    options.ignoreUnknownFields = true
    let objects = try _Token.array(fromJSONString: string, options: options)
    return objects.lazy.map({ $0.wrapped(chain) })
  }
  
  public static func array(fromJSONData data: Data, chain: MDBXChain) throws -> [Self] {
    var options = JSONDecodingOptions()
    options.ignoreUnknownFields = true
    let objects = try _Token.array(fromJSONUTF8Data: data, options: options)
    return objects.lazy.map({ $0.wrapped(chain) })
  }
  
  mutating public func merge(with object: MDBXObject) {
    let other = object as! Token

    self._wrapped.address               = other._wrapped.address
    self._wrapped.contractAddress       = other._wrapped.contractAddress
    self._wrapped.amount                = other._wrapped.amount
    self._wrapped.lockedAmount          = other._wrapped.lockedAmount
  }
}

// MARK: - _Token + ProtoWrappedMessage

extension _Token: ProtoWrappedMessage {
  func wrapped(_ chain: MDBXChain) -> Token {
    return Token(self, chain: chain)
  }
}

// MARK: - Token + Equitable

public extension Token {
  static func ==(lhs: Token, rhs: Token) -> Bool {
    return lhs._chain == rhs._chain
        && lhs._wrapped == rhs._wrapped
  }
}

// MARK: - Token + ProtoWrapper

extension Token: ProtoWrapper {
  init(_ wrapped: _Token, chain: MDBXChain) {
    self._chain = chain
    self._wrapped = wrapped
    self._metaKey = TokenMetaKey(chain: chain, contractAddress: self._wrapped.contractAddress)
  }
}
