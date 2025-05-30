//
//  File.swift
//  
//
//  Created by Mikhail Nikanorov on 5/23/23.
//

import Foundation
import SwiftProtobuf
import mdbx_ios
import mew_wallet_ios_extensions

public struct DAppLists: Equatable, Sendable {
  public weak var database: (any WalletDB)? = MEWwalletDBImpl.shared
  var _wrapped: _DAppLists
  let _chain: MDBXChain = .evm
  
  // MARK: - Lifecycle
  
  public init() {
    self.database = MEWwalletDBImpl.shared
    
    self._wrapped = .with { _ in }
  }
}

// MARK: - DAppLists + Properties

extension DAppLists {
  // MARK: - Properties
  
  public var denyList: [String] { _wrapped.denylist }
  public var allowList: [String] { _wrapped.allowlist }
  public var fuzzyList: [String] { _wrapped.fuzzylist }
}

// MARK: - _DAppLists + MDBXObject

extension DAppLists: MDBXObject {
  public var serialized: Data {
    get throws {
      return try self._wrapped.serializedData()
    }
  }

  public var key: any MDBXKey {
    DAppLists.Key()
  }

  public var alternateKey: (any MDBXKey)? {
    return nil
  }

  public init(serializedData data: Data, chain: MDBXChain, key: Data?) throws {
    self._wrapped = try _DAppLists(serializedBytes: data)
  }

  public init(jsonData: Data, chain: MDBXChain, key: Data?) throws {
    var options = JSONDecodingOptions()
    options.ignoreUnknownFields = true
    self._wrapped = try _DAppLists(jsonUTF8Data: jsonData, options: options)
  }

  public init(jsonString: String, chain: MDBXChain, key: Data?) throws {
    var options = JSONDecodingOptions()
    options.ignoreUnknownFields = true
    self._wrapped = try _DAppLists(jsonString: jsonString, options: options)
  }

  public static func array(fromJSONString string: String, chain: MDBXChain) throws -> [Self] {
    var options = JSONDecodingOptions()
    options.ignoreUnknownFields = true
    let objects = try _DAppLists.array(fromJSONString: string, options: options)
    return objects.lazy.map({ $0.wrapped(.evm) })
  }

  public static func array(fromJSONData data: Data, chain: MDBXChain) throws -> [Self] {
    var options = JSONDecodingOptions()
    options.ignoreUnknownFields = true
    let objects = try _DAppLists.array(fromJSONUTF8Data: data, options: options)
    return objects.lazy.map({ $0.wrapped(.evm) })
  }

  mutating public func merge(with object: any MDBXObject) {
    let other = object as! DAppLists
    
    self._wrapped.allowlist = other._wrapped.allowlist
    self._wrapped.denylist = other._wrapped.denylist
    self._wrapped.fuzzylist = other._wrapped.fuzzylist
  }
}

// MARK: - _DAppLists + ProtoWrappedMessage

extension _DAppLists: ProtoWrappedMessage {
  func wrapped(_ chain: MDBXChain) -> DAppLists {
    return DAppLists(self, chain: .evm)
  }
}

// MARK: - DAppLists + Equatable

public extension DAppLists {
  static func ==(lhs: DAppLists, rhs: DAppLists) -> Bool {
    return lhs._wrapped == rhs._wrapped
  }
}

// MARK: - DAppLists + ProtoWrapper

extension DAppLists: ProtoWrapper {
  init(_ wrapped: _DAppLists, chain: MDBXChain) {
    self._wrapped = wrapped
  }
}

// MARK: - DAppLists + Hashable

extension DAppLists: Hashable {
  public func hash(into hasher: inout Hasher) {
    hasher.combine(self.denyList)
    hasher.combine(self.allowList)
    hasher.combine(self.fuzzyList)
  }
}
