//
//  File.swift
//  
//
//  Created by Mikhail Nikanorov on 5/5/22.
//

import Foundation
import SwiftProtobuf
import mdbx_ios

public struct DAppRecord: Equatable {
  public struct RecordType: OptionSet {
    public static let unknown   = RecordType(rawValue: 0 << 0)
    public static let recent    = RecordType(rawValue: 1 << 0)
    public static let favorite  = RecordType(rawValue: 1 << 1)
    public let rawValue: UInt32
    
    public init(rawValue: UInt32) {
      self.rawValue = rawValue
    }
  }
  
  public weak var database: WalletDB? = MEWwalletDBImpl.shared
  var _wrapped: _DAppRecord
  var _chain: MDBXChain
  var _hash: Data
  var _uuid: UInt64 = 0
  
  public var reference: DAppRecordReference?
  
  // MARK: - Lifecycle
  
  public init(chain: MDBXChain, url: URL, address: String?, type: DAppRecord.RecordType, uuid: UInt64, database: WalletDB? = nil) {
    self.database = database ?? MEWwalletDBImpl.shared
    self._chain = chain
    self._hash = url.sha256
    self._uuid = uuid
    
    self._wrapped = .with {
      $0.url = url.absoluteString
      $0.type = type.rawValue
      if let address = address { $0.address = address }
    }
  }
  
  // MARK: - Private
  
  mutating private func tryRestorePrimaryKeyInfo(_ key: Data?) {
    guard let key = key else { return }
    if let primaryKey = DAppRecordKey(data: key) {
      _uuid = primaryKey.uuid
    }
  }
}

// MARK: - DAppRecord + Properties

extension DAppRecord {
  // MARK: - Properties
  
  public var url: URL { URL(string: self._wrapped.url)! }
  public var address: String? {
    set {
      guard let address = newValue else { return }
      self._wrapped.address = address
    }
    get {
      guard self._wrapped.hasAddress else { return nil }
      return self._wrapped.address
    }
  }
  public var title: String?   { self.reference?.title }
  public var icon: URL?       { self.reference?.icon }
  public var preview: Data?   { self.reference?.preview }
  public var type: RecordType { RecordType(rawValue: self._wrapped.type) }
  public var uuid: UInt64     { self._uuid }
}

// MARK: - DAppRecord + MDBXObject

extension DAppRecord: MDBXObject {
  public var serialized: Data {
    get throws {
      return try self._wrapped.serializedData()
    }
  }

  public var key: MDBXKey {
    return DAppRecordKey(chain: _chain, hash: _hash, uuid: _uuid)
  }

  public var alternateKey: MDBXKey? {
    return nil
  }

  public init(serializedData data: Data, chain: MDBXChain, key: Data?) throws {
    self._chain = chain
    self._wrapped = try _DAppRecord(serializedData: data)
    self._hash = self._wrapped.url.sha256
    self.tryRestorePrimaryKeyInfo(key)
  }

  public init(jsonData: Data, chain: MDBXChain, key: Data?) throws {
    var options = JSONDecodingOptions()
    options.ignoreUnknownFields = true
    self._chain = chain
    self._wrapped = try _DAppRecord(jsonUTF8Data: jsonData, options: options)
    self._hash = self._wrapped.url.sha256
    self.tryRestorePrimaryKeyInfo(key)
  }

  public init(jsonString: String, chain: MDBXChain, key: Data?) throws {
    var options = JSONDecodingOptions()
    options.ignoreUnknownFields = true
    self._chain = chain
    self._wrapped = try _DAppRecord(jsonString: jsonString, options: options)
    self._hash = self._wrapped.url.sha256
    self.tryRestorePrimaryKeyInfo(key)
  }

  public static func array(fromJSONString string: String, chain: MDBXChain) throws -> [Self] {
    var options = JSONDecodingOptions()
    options.ignoreUnknownFields = true
    let objects = try _DAppRecord.array(fromJSONString: string, options: options)
    return objects.lazy.map({ $0.wrapped(chain) })
  }

  public static func array(fromJSONData data: Data, chain: MDBXChain) throws -> [Self] {
    var options = JSONDecodingOptions()
    options.ignoreUnknownFields = true
    let objects = try _DAppRecord.array(fromJSONUTF8Data: data, options: options)
    return objects.lazy.map({ $0.wrapped(chain) })
  }

  mutating public func merge(with object: MDBXObject) {
    let other = object as! DAppRecord
    
    self._wrapped.url = other._wrapped.url
  }
}

// MARK: - _DAppRecord + ProtoWrappedMessage

extension _DAppRecord: ProtoWrappedMessage {
  func wrapped(_ chain: MDBXChain) -> DAppRecord {
    return DAppRecord(self, chain: chain)
  }
}

// MARK: - DAppRecord + Equitable

public extension DAppRecord {
  static func ==(lhs: DAppRecord, rhs: DAppRecord) -> Bool {
    if let lhsUUID = lhs.reference?.uuid, let rhsUUID = rhs.reference?.uuid {
      return lhsUUID == rhsUUID && lhs._hash == rhs._hash
    }
    return lhs._chain == rhs._chain &&
           lhs._wrapped == rhs._wrapped
  }
}

// MARK: - DAppRecord + ProtoWrapper

extension DAppRecord: ProtoWrapper {
  init(_ wrapped: _DAppRecord, chain: MDBXChain) {
    self._chain = chain
    self._wrapped = wrapped
    self._hash = wrapped.url.sha256
    self._uuid = UUID().uint64uuid
  }
}

// MARK: - DAppRecord + Hashable

extension DAppRecord: Hashable {
  public func hash(into hasher: inout Hasher) {
    if let uuid = reference?.uuid {
      hasher.combine(uuid)
    } else {
      hasher.combine(self.url)
      hasher.combine(self.address)
    }
  }
}
