//
//  File.swift
//  
//
//  Created by Mikhail Nikanorov on 5/16/22.
//

import Foundation
import SwiftProtobuf
import mdbx_ios

public struct DAppRecordMeta: Equatable {
  public weak var database: WalletDB? = MEWwalletDBImpl.shared
  var _wrapped: _DAppRecordMeta
  var _chain: MDBXChain
  var _hash: Data = Data()
  
  // MARK: - Lifecycle
  
  public init(chain: MDBXChain, url: URL, icon: URL?, database: WalletDB? = nil) {
    self.database = database ?? MEWwalletDBImpl.shared
    self._chain = chain
    self._hash = url.sha256
    
    guard let icon = icon else {
      self._wrapped = .with { _ in }
      return
    }
    self._wrapped = .with {
      $0.icon = icon.absoluteString
    }
  }
  
  // MARK: - Private
  
  mutating private func tryRestorePrimaryKeyInfo(_ key: Data?) {
    guard let key = key else { return }
    if let primaryKey = DAppRecordMetaKey(data: key) {
      _hash = primaryKey.urlHash
    }
  }
}

// MARK: - DAppRecordMeta + Properties

extension DAppRecordMeta {
  // MARK: - Properties
  
  public var icon: URL? {
    guard self._wrapped.hasIcon else {
      return nil
    }
    return URL(string: self._wrapped.icon)
  }
  
  // MARK: - Functions
  
  mutating public func update(url: URL) {
    self._hash = url.sha256
  }
  
  mutating public func update(absoluteURL: String) {
    self._hash = absoluteURL.sha256
  }
}

// MARK: - DAppRecordMeta + MDBXObject

extension DAppRecordMeta: MDBXObject {
  public var serialized: Data {
    get throws {
      return try self._wrapped.serializedData()
    }
  }

  public var key: MDBXKey {
    return DAppRecordMetaKey(chain: _chain, hash: _hash)
  }

  public var alternateKey: MDBXKey? {
    return nil
  }

  public init(serializedData data: Data, chain: MDBXChain, key: Data?) throws {
    self._chain = chain
    self._wrapped = try _DAppRecordMeta(serializedData: data)
    self.tryRestorePrimaryKeyInfo(key)
  }

  public init(jsonData: Data, chain: MDBXChain, key: Data?) throws {
    var options = JSONDecodingOptions()
    options.ignoreUnknownFields = true
    self._chain = chain
    self._wrapped = try _DAppRecordMeta(jsonUTF8Data: jsonData, options: options)
    self.tryRestorePrimaryKeyInfo(key)
  }

  public init(jsonString: String, chain: MDBXChain, key: Data?) throws {
    var options = JSONDecodingOptions()
    options.ignoreUnknownFields = true
    self._chain = chain
    self._wrapped = try _DAppRecordMeta(jsonString: jsonString, options: options)
    self.tryRestorePrimaryKeyInfo(key)
  }

  public static func array(fromJSONString string: String, chain: MDBXChain) throws -> [Self] {
    var options = JSONDecodingOptions()
    options.ignoreUnknownFields = true
    let objects = try _DAppRecordMeta.array(fromJSONString: string, options: options)
    return objects.lazy.map({ $0.wrapped(chain) })
  }

  public static func array(fromJSONData data: Data, chain: MDBXChain) throws -> [Self] {
    var options = JSONDecodingOptions()
    options.ignoreUnknownFields = true
    let objects = try _DAppRecordMeta.array(fromJSONUTF8Data: data, options: options)
    return objects.lazy.map({ $0.wrapped(chain) })
  }

  mutating public func merge(with object: MDBXObject) {
    let other = object as! DAppRecordMeta
    if other._wrapped.hasIcon {
      self._wrapped.icon = other._wrapped.icon
    }
  }
}

// MARK: - _DAppRecordMeta + ProtoWrappedMessage

extension _DAppRecordMeta: ProtoWrappedMessage {
  func wrapped(_ chain: MDBXChain) -> DAppRecordMeta {
    return DAppRecordMeta(self, chain: chain)
  }
}

// MARK: - DAppRecordMeta + Equitable

public extension DAppRecordMeta {
  static func ==(lhs: DAppRecordMeta, rhs: DAppRecordMeta) -> Bool {
    return lhs._chain == rhs._chain &&
           lhs._wrapped == rhs._wrapped
  }
}

// MARK: - DAppRecordMeta + ProtoWrapper

extension DAppRecordMeta: ProtoWrapper {
  init(_ wrapped: _DAppRecordMeta, chain: MDBXChain) {
    self._chain = chain
    self._wrapped = wrapped
  }
}
