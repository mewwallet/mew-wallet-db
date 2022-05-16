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
  private var _restoredAlternateKey: DAppRecordReferenceKey?
  public weak var database: WalletDB? = MEWwalletDBImpl.shared
  var _wrapped: _DAppRecordReference
  var _chain: MDBXChain
  public var order: UInt16 = 0
  
  // MARK: - Private Properties
  
  private let _dappRecord: MDBXPointer<DAppRecordKey, DAppRecord> = .init(.dappRecord)
  
  // MARK: - Lifecycle
  
  public init(chain: MDBXChain, url: URL, order: UInt16, title: String?, icon: URL?, preview: Data?, database: WalletDB? = nil) {
    self.database = database ?? MEWwalletDBImpl.shared
    self._chain = chain
    self.order = order
    
    self._wrapped = .with {
      $0.reference = url.sha256
      $0.uuid = UUID().uint64uuid
      if let title = title          { $0.title = title }
      if let icon = icon            { $0.iconURL = icon.absoluteString }
      if let preview = preview      { $0.preview = preview }
    }
  }
  
  // MARK: - Private
  
  mutating private func tryRestorePrimaryKeyInfo(_ key: Data?) {
    guard let key = key else { return }
    if let primaryKey = DAppRecordReferenceKey(data: key) {
      order = primaryKey.order
    }
  }
}

// MARK: - DAppRecordReference + Properties

extension DAppRecordReference {
  // MARK: - Relations
  
  public var dappRecord: DAppRecord {
    get throws {
      let key = DAppRecordKey(chain: _chain, hash: self._wrapped.reference, uuid: self.uuid)
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
  
  public var icon: URL? {
    set {
      guard let icon = newValue else { return }
      self._wrapped.iconURL = icon.absoluteString
    }
    get {
      guard self._wrapped.hasIconURL else { return nil }
      return URL(string: self._wrapped.iconURL)
    }
  }
  
  public var title: String? {
    set {
      if let title = newValue {
        self._wrapped.title = title
      } else {
        self._wrapped.clearTitle()
      }
    }
    get {
      guard self._wrapped.hasTitle else { return nil }
      return self._wrapped.title
    }
  }
  
  public var preview: Data? {
    set {
      if let preview = newValue {
        self._wrapped.preview = preview
      } else {
        self._wrapped.clearPreview()
      }
    }
    get {
      guard self._wrapped.hasPreview else { return nil }
      return self._wrapped.preview
    }
  }
  
  // MARK: - Functions
  
  mutating public func update(url: URL) {
    self._wrapped.reference = url.sha256
  }
}

// MARK: - DAppRecordReference + MDBXObject

extension DAppRecordReference: MDBXObject {
  public var serialized: Data {
    get throws {
      return try self._wrapped.serializedData()
    }
  }
  
  /// Reference key
  public var key: MDBXKey {
    return DAppRecordReferenceKey(chain: _chain, order: order)
  }
  
  public var alternateKey: MDBXKey? { return nil }

  public init(serializedData data: Data, chain: MDBXChain, key: Data?) throws {
    self._chain = chain
    self._wrapped = try _DAppRecordReference(serializedData: data)
    self.tryRestorePrimaryKeyInfo(key)
  }

  public init(jsonData: Data, chain: MDBXChain, key: Data?) throws {
    var options = JSONDecodingOptions()
    options.ignoreUnknownFields = true
    self._chain = chain
    self._wrapped = try _DAppRecordReference(jsonUTF8Data: jsonData, options: options)
    self.tryRestorePrimaryKeyInfo(key)
  }

  public init(jsonString: String, chain: MDBXChain, key: Data?) throws {
    var options = JSONDecodingOptions()
    options.ignoreUnknownFields = true
    self._chain = chain
    self._wrapped = try _DAppRecordReference(jsonString: jsonString, options: options)
    self.tryRestorePrimaryKeyInfo(key)
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
    if other._wrapped.hasTitle {
      self._wrapped.title = other._wrapped.title
    } else {
      self._wrapped.clearTitle()
    }
    if other._wrapped.hasIconURL {
      self._wrapped.iconURL = other._wrapped.iconURL
    } else {
      self._wrapped.clearIconURL()
    }
    if other._wrapped.hasPreview {
      self._wrapped.preview = other._wrapped.preview
    } else {
      self._wrapped.clearPreview()
    }
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
  
  static func ==(lhs: DAppRecordReference, rhs: URL) -> Bool {
    return lhs._wrapped.reference == rhs.sha256
  }
}

// MARK: - DAppRecordReference + ProtoWrapper

extension DAppRecordReference: ProtoWrapper {
  init(_ wrapped: _DAppRecordReference, chain: MDBXChain) {
    self._chain = chain
    self._wrapped = wrapped
  }
}
