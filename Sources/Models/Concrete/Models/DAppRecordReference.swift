//
//  File.swift
//  
//
//  Created by Mikhail Nikanorov on 5/5/22.
//

import Foundation
import SwiftProtobuf
import mdbx_ios

public struct DAppRecordReference: Equatable {
  private var _restoredAlternateKey: DAppRecordFavoriteKey?
  public weak var database: WalletDB? = MEWwalletDBImpl.shared
  var _wrapped: _DAppRecordReference
  var _chain: MDBXChain
  var _timestamp: Date = Date()
  public var order: UInt16?
  
  // MARK: - Private Properties
  
  private let _dappRecord: MDBXPointer<DAppRecordKey, DAppRecord> = .init(.dappRecord)
  
  // MARK: - Lifecycle
  
  public init(chain: MDBXChain, url: URL, timestamp: Date = Date(), order: UInt16?, database: WalletDB? = nil) {
    self.database = database ?? MEWwalletDBImpl.shared
    self._chain = chain
    self._timestamp = timestamp
    self.order = order
    
    self._wrapped = .with {
      $0.reference = url.sha256
      $0.uuid = UUID().uint64uuid
    }
  }
  
  // MARK: - Private
  
  mutating private func tryRestorePrimaryKeyInfo(_ key: Data?) {
    guard let key = key else { return }
    if let primaryKey = DAppRecordRecentKey(data: key) {
      _timestamp = Date(timeIntervalSince1970: primaryKey.timestamp)
    }
  }
  
  mutating private func tryRestoreAlternateKey(_ key: Data?) {
    guard let key = key else { return }
    if let alternateKey = DAppRecordFavoriteKey(data: key) {
      _restoredAlternateKey = alternateKey
      order = alternateKey.order
    }
  }
}

// MARK: - DAppRecordReference + Properties

extension DAppRecordReference {
  // MARK: - Relations
  
  public var asd: Data {
    self._wrapped.reference
  }

  public var dappRecord: DAppRecord {
    get throws {
      let key = DAppRecordKey(chain: _chain, hash: self._wrapped.reference)
      return try _dappRecord.getData(key: key, policy: .ignoreCache, database: self.database)
    }
  }
  
  public var dappRecordSetter: DAppRecord? {
    get {
      return nil
    }
    set(record) {
      self._wrapped.reference = record?.url.sha256 ?? Data()
    }
  }
  
  // MARK: - Properties
  public var uuid: UInt64 { self._wrapped.uuid }
}

// MARK: - DAppRecordReference + MDBXObject

extension DAppRecordReference: MDBXObject {
  public var serialized: Data {
    get throws {
      return try self._wrapped.serializedData()
    }
  }
  
  /// Recent key
  public var key: MDBXKey {
    return DAppRecordRecentKey(chain: _chain, timestamp: self._timestamp.timeIntervalSince1970)
  }
  
  /// Favorite key
  public var alternateKey: MDBXKey? {
    guard let order = order else { return nil }
    return DAppRecordFavoriteKey(chain: _chain, order: order)
  }

  public init(serializedData data: Data, chain: MDBXChain, key: Data?) throws {
    self._chain = chain
    self._wrapped = try _DAppRecordReference(serializedData: data)
    self.tryRestorePrimaryKeyInfo(key)
    self.tryRestoreAlternateKey(key)
  }

  public init(jsonData: Data, chain: MDBXChain, key: Data?) throws {
    var options = JSONDecodingOptions()
    options.ignoreUnknownFields = true
    self._chain = chain
    self._wrapped = try _DAppRecordReference(jsonUTF8Data: jsonData, options: options)
    self.tryRestorePrimaryKeyInfo(key)
    self.tryRestoreAlternateKey(key)
  }

  public init(jsonString: String, chain: MDBXChain, key: Data?) throws {
    var options = JSONDecodingOptions()
    options.ignoreUnknownFields = true
    self._chain = chain
    self._wrapped = try _DAppRecordReference(jsonString: jsonString, options: options)
    self.tryRestorePrimaryKeyInfo(key)
    self.tryRestoreAlternateKey(key)
  }

  public static func array(fromJSONString string: String, chain: MDBXChain) throws -> [Self] {
    var options = JSONDecodingOptions()
    options.ignoreUnknownFields = true
    let objects = try _DAppRecordReference.array(fromJSONString: string, options: options)
    return objects.lazy.map({ $0.wrapped(chain) })
  }

  public static func array(fromJSONData data: Data, chain: MDBXChain) throws -> [Self] {
    var options = JSONDecodingOptions()
    options.ignoreUnknownFields = true
    let objects = try _DAppRecordReference.array(fromJSONUTF8Data: data, options: options)
    return objects.lazy.map({ $0.wrapped(chain) })
  }

  mutating public func merge(with object: MDBXObject) {
    let other = object as! DAppRecordReference
    self._wrapped.reference               = other._wrapped.reference
    self._wrapped.uuid                    = other._wrapped.uuid
  }
}

// MARK: - _DAppRecordReference + ProtoWrappedMessage

extension _DAppRecordReference: ProtoWrappedMessage {
  func wrapped(_ chain: MDBXChain) -> DAppRecordReference {
    return DAppRecordReference(self, chain: chain)
  }
}

// MARK: - DAppRecordReference + Equitable

public extension DAppRecordReference {
  static func ==(lhs: DAppRecordReference, rhs: DAppRecordReference) -> Bool {
    return lhs._chain == rhs._chain &&
           lhs._wrapped == rhs._wrapped
  }
}

// MARK: - DAppRecordReference + ProtoWrapper

extension DAppRecordReference: ProtoWrapper {
  init(_ wrapped: _DAppRecordReference, chain: MDBXChain) {
    self._chain = chain
    self._wrapped = wrapped
  }
}
