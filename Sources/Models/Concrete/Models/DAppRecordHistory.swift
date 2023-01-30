//
//  File.swift
//  
//
//  Created by Mikhail Nikanorov on 5/16/22.
//

import Foundation
import SwiftProtobuf
import mdbx_ios
import mew_wallet_ios_extensions
import SwiftProtobuf
import mdbx_ios

public struct DAppRecordHistory: Equatable {
  public weak var database: WalletDB? = MEWwalletDBImpl.shared
  var _wrapped: _DAppRecordHistory
  var _chain: MDBXChain
  var _hash: Data = Data()
  
  // MARK: - Private properties
  
  private let _meta: MDBXPointer<DAppRecordMetaKey, DAppRecordMeta> = .init(.dappRecordMeta)
  
  // MARK: - Lifecycle
  
  public init(url: URL, title: String?, database: WalletDB? = nil) {
    self.database = database ?? MEWwalletDBImpl.shared
    self._chain = .universal
    self._hash = url.sha256
    
    self._wrapped = .with {
      $0.url = url.absoluteString
      $0.timestamp = .init(date: Date())
      if let title = title { $0.title = title }
    }
  }
  
  // MARK: - Private
  
  mutating private func tryRestorePrimaryKeyInfo(_ key: Data?) {
    guard let key = key else { return }
    if let primaryKey = DAppRecordHistoryKey(data: key) {
      _hash = primaryKey.urlHash
    }
  }
}

// MARK: - DAppRecordHistory + Properties

extension DAppRecordHistory {
  // MARK: - Relations
  
  private var meta: DAppRecordMeta {
    get throws {
      guard let host = self.url?.hostURL?.sanitized else { throw MDBXError.notFound }
      let key = DAppRecordMetaKey(url: host)
      return try _meta.getData(key: key, policy: .cacheOrLoad(chain: .universal), database: self.database)
    }
  }
  
  // MARK: - Properties
  
  public var title: String? {
    guard self._wrapped.hasTitle else { return nil }
    return self._wrapped.title
  }
  
  public var url: URL? { URL(string: self._wrapped.url) }
  public var icon: URL?       {
    guard let meta = try? self.meta else { return nil }
    return meta.icon
  }
  
  public var timestamp: Date { self._wrapped.timestamp.date }
}

// MARK: - DAppRecordHistory + MDBXObject

extension DAppRecordHistory: MDBXObject {
  public var serialized: Data {
    get throws {
      return try self._wrapped.serializedData()
    }
  }

  public var key: MDBXKey {
    return DAppRecordHistoryKey(hash: _hash)
  }

  public var alternateKey: MDBXKey? {
    return nil
  }

  public init(serializedData data: Data, chain: MDBXChain, key: Data?) throws {
    self._chain = .universal
    self._wrapped = try _DAppRecordHistory(serializedData: data)
    self.tryRestorePrimaryKeyInfo(key)
  }

  public init(jsonData: Data, chain: MDBXChain, key: Data?) throws {
    var options = JSONDecodingOptions()
    options.ignoreUnknownFields = true
    self._chain = .universal
    self._wrapped = try _DAppRecordHistory(jsonUTF8Data: jsonData, options: options)
    self.tryRestorePrimaryKeyInfo(key)
  }

  public init(jsonString: String, chain: MDBXChain, key: Data?) throws {
    var options = JSONDecodingOptions()
    options.ignoreUnknownFields = true
    self._chain = .universal
    self._wrapped = try _DAppRecordHistory(jsonString: jsonString, options: options)
    self.tryRestorePrimaryKeyInfo(key)
  }

  public static func array(fromJSONString string: String, chain: MDBXChain) throws -> [Self] {
    var options = JSONDecodingOptions()
    options.ignoreUnknownFields = true
    let objects = try _DAppRecordHistory.array(fromJSONString: string, options: options)
    return objects.lazy.map({ $0.wrapped(.universal) })
  }

  public static func array(fromJSONData data: Data, chain: MDBXChain) throws -> [Self] {
    var options = JSONDecodingOptions()
    options.ignoreUnknownFields = true
    let objects = try _DAppRecordHistory.array(fromJSONUTF8Data: data, options: options)
    return objects.lazy.map({ $0.wrapped(.universal) })
  }

  mutating public func merge(with object: MDBXObject) {
    let other = object as! DAppRecordHistory
    if other._wrapped.hasTitle {
      self._wrapped.title = other._wrapped.title
    }
  }
}

// MARK: - _DAppRecordHistory + ProtoWrappedMessage

extension _DAppRecordHistory: ProtoWrappedMessage {
  func wrapped(_ chain: MDBXChain) -> DAppRecordHistory {
    return DAppRecordHistory(self, chain: .universal)
  }
}

// MARK: - DAppRecordHistory + Equitable

public extension DAppRecordHistory {
  static func ==(lhs: DAppRecordHistory, rhs: DAppRecordHistory) -> Bool {
    return lhs._chain == rhs._chain &&
           lhs._wrapped == rhs._wrapped
  }
}

// MARK: - DAppRecordHistory + ProtoWrapper

extension DAppRecordHistory: ProtoWrapper {
  init(_ wrapped: _DAppRecordHistory, chain: MDBXChain) {
    self._chain = .universal
    self._wrapped = wrapped
  }
}

// MARK: - DAppRecordHistory + Hashable

extension DAppRecordHistory: Hashable {
  public func hash(into hasher: inout Hasher) {
    hasher.combine(self.url)
    hasher.combine(self.title)
  }
}

// MARK: - DAppRecordHistory + Comparable

extension DAppRecordHistory: Comparable {
  public static func < (lhs: DAppRecordHistory, rhs: DAppRecordHistory) -> Bool {
    lhs._wrapped.timestamp.seconds > rhs._wrapped.timestamp.seconds
  }
}

// MARK: - DAppRecordHistory + Sendable

extension DAppRecordHistory: @unchecked Sendable {}
