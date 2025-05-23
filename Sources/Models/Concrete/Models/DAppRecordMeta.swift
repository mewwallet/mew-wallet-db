//
//  File.swift
//  
//
//  Created by Mikhail Nikanorov on 5/16/22.
//

import Foundation
import SwiftProtobuf
import mdbx_ios

public struct DAppRecordMeta: Equatable, Sendable {
  private let _queue = DispatchQueue(label: "db.DAppRecordMeta.queue")
  
  public weak var database: (any WalletDB)? = MEWwalletDBImpl.shared
  var _wrapped: _DAppRecordMeta
  var _chain: MDBXChain
  var _hash: Data = Data()
  
  // MARK: - Lifecycle
  
  public init(url: URL, icon: URL?, database: (any WalletDB)? = nil) {
    self.database = database ?? MEWwalletDBImpl.shared
    self._chain = .evm
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
      _hash = Data(primaryKey.urlHash)
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
    _queue.sync {
      self._hash = url.sha256
    }
  }
  
  mutating public func update(absoluteURL: String) {
    _queue.sync {
      self._hash = absoluteURL.sha256
    }
  }
}

// MARK: - DAppRecordMeta + MDBXObject

extension DAppRecordMeta: MDBXObject {
  public var serialized: Data {
    get throws {
      return try self._wrapped.serializedData()
    }
  }

  public var key: any MDBXKey {
    return DAppRecordMetaKey(hash: _hash)
  }

  public var alternateKey: (any MDBXKey)? {
    return nil
  }

  public init(serializedData data: Data, chain: MDBXChain, key: Data?) throws {
    self._chain = .evm
    self._wrapped = try _DAppRecordMeta(serializedBytes: data)
    self.tryRestorePrimaryKeyInfo(key)
  }

  public init(jsonData: Data, chain: MDBXChain, key: Data?) throws {
    var options = JSONDecodingOptions()
    options.ignoreUnknownFields = true
    self._chain = .evm
    self._wrapped = try _DAppRecordMeta(jsonUTF8Data: jsonData, options: options)
    self.tryRestorePrimaryKeyInfo(key)
  }

  public init(jsonString: String, chain: MDBXChain, key: Data?) throws {
    var options = JSONDecodingOptions()
    options.ignoreUnknownFields = true
    self._chain = .evm
    self._wrapped = try _DAppRecordMeta(jsonString: jsonString, options: options)
    self.tryRestorePrimaryKeyInfo(key)
  }

  public static func array(fromJSONString string: String, chain: MDBXChain) throws -> [Self] {
    var options = JSONDecodingOptions()
    options.ignoreUnknownFields = true
    let objects = try _DAppRecordMeta.array(fromJSONString: string, options: options)
    return objects.lazy.map({ $0.wrapped(.evm) })
  }

  public static func array(fromJSONData data: Data, chain: MDBXChain) throws -> [Self] {
    var options = JSONDecodingOptions()
    options.ignoreUnknownFields = true
    let objects = try _DAppRecordMeta.array(fromJSONUTF8Data: data, options: options)
    return objects.lazy.map({ $0.wrapped(.evm) })
  }

  mutating public func merge(with object: any MDBXObject) {
    let other = object as! DAppRecordMeta
    if other._wrapped.hasIcon {
      self._wrapped.icon = other._wrapped.icon
    }
  }
}

// MARK: - _DAppRecordMeta + ProtoWrappedMessage

extension _DAppRecordMeta: ProtoWrappedMessage {
  func wrapped(_ chain: MDBXChain) -> DAppRecordMeta {
    return DAppRecordMeta(self, chain: .evm)
  }
}

// MARK: - DAppRecordMeta + Equatable

public extension DAppRecordMeta {
  static func ==(lhs: DAppRecordMeta, rhs: DAppRecordMeta) -> Bool {
    return lhs._chain == rhs._chain &&
           lhs._wrapped == rhs._wrapped
  }
}

// MARK: - DAppRecordMeta + ProtoWrapper

extension DAppRecordMeta: ProtoWrapper {
  init(_ wrapped: _DAppRecordMeta, chain: MDBXChain) {
    self._chain = .evm
    self._wrapped = wrapped
  }
}
