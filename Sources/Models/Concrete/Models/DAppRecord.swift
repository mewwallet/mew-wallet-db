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
  public weak var database: WalletDB? = MEWwalletDBImpl.shared
  var _wrapped: _DAppRecord
  var _chain: MDBXChain
  var _hash: Data
  public var recentReference: DAppRecordReference?
  
  // MARK: - Lifecycle
  
  public init(chain: MDBXChain, url: URL, address: String?, title: String?, icon: URL?, favorite: Bool? = nil, recent: Bool? = nil, preview: Data?, database: WalletDB? = nil) {
    self.database = database ?? MEWwalletDBImpl.shared
    self._chain = chain
    self._hash = url.sha256
    
    self._wrapped = .with {
      $0.url = url.absoluteString
      if let favorite = favorite  { $0.favorite = favorite }
      if let recent = recent      { $0.recent = recent }
      if let address = address    { $0.address = address }
      if let title = title        { $0.title = title }
      if let icon = icon          { $0.iconURL = icon.absoluteString }
      if let preview = preview    { $0.preview = preview }
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
  public var title: String? {
    set {
      guard let title = newValue else { return }
      self._wrapped.title = title
    }
    get {
      guard self._wrapped.hasTitle else { return nil }
      return self._wrapped.title
    }
  }
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
  public var preview: Data? {
    guard self._wrapped.hasPreview else { return nil }
    return self._wrapped.preview
  }
  public var favorite: Bool {
    set { self._wrapped.favorite = newValue }
    get {
      guard self._wrapped.hasFavorite else { return false }
      return self._wrapped.favorite
    }
  }
  public var recent: Bool {
    set { self._wrapped.recent = newValue }
    get {
      guard self._wrapped.hasRecent else { return false }
      return self._wrapped.recent
    }
  }
}

// MARK: - DAppRecord + MDBXObject

extension DAppRecord: MDBXObject {
  public var serialized: Data {
    get throws {
      return try self._wrapped.serializedData()
    }
  }

  public var key: MDBXKey {
    return DAppRecordKey(chain: _chain, hash: _hash)
  }

  public var alternateKey: MDBXKey? {
    return nil
  }

  public init(serializedData data: Data, chain: MDBXChain, key: Data?) throws {
    self._chain = chain
    self._wrapped = try _DAppRecord(serializedData: data)
    self._hash = self._wrapped.url.sha256
  }

  public init(jsonData: Data, chain: MDBXChain, key: Data?) throws {
    var options = JSONDecodingOptions()
    options.ignoreUnknownFields = true
    self._chain = chain
    self._wrapped = try _DAppRecord(jsonUTF8Data: jsonData, options: options)
    self._hash = self._wrapped.url.sha256
  }

  public init(jsonString: String, chain: MDBXChain, key: Data?) throws {
    var options = JSONDecodingOptions()
    options.ignoreUnknownFields = true
    self._chain = chain
    self._wrapped = try _DAppRecord(jsonString: jsonString, options: options)
    self._hash = self._wrapped.url.sha256
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
    if other._wrapped.hasFavorite {
      self._wrapped.favorite = other._wrapped.favorite
    }
    if other._wrapped.hasRecent {
      self._wrapped.recent = other._wrapped.recent
    }
    if other._wrapped.hasAddress {
      self._wrapped.address = other._wrapped.address
    } else {
      self._wrapped.clearAddress()
    }
    if other._wrapped.hasTitle {
      self._wrapped.title = other._wrapped.title
    }
    if other._wrapped.hasIconURL {
      self._wrapped.iconURL = other._wrapped.iconURL
    }
    if other._wrapped.hasPreview {
      if other._wrapped.preview.isEmpty {
        self._wrapped.clearPreview()
      } else {
        self._wrapped.preview = other._wrapped.preview
      }
    }
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
    if let lhsUUID = lhs.recentReference?.uuid, let rhsUUID = rhs.recentReference?.uuid {
      return lhsUUID == rhsUUID
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
  }
}

// MARK: - DAppRecord + Hashable

extension DAppRecord: Hashable {
  public func hash(into hasher: inout Hasher) {
    if let uuid = recentReference?.uuid {
      hasher.combine(uuid)
    } else {
      hasher.combine(self.url)
      hasher.combine(self.address)
      hasher.combine(self.title)
      hasher.combine(self.icon)
      hasher.combine(self.preview)
      hasher.combine(self.favorite)
      hasher.combine(self.recent)
    }
  }
}

// MARK: DAppRecord + CustomDebugStringConvertible

extension DAppRecord: CustomDebugStringConvertible {
  public var debugDescription: String {
    """
    url: \(self._wrapped.url)
    address: \(self._wrapped.address)
    title: \(self._wrapped.title)
    icon: \(self._wrapped.iconURL)
    favorite: \(self._wrapped.favorite)
    recent: \(self._wrapped.recent)
    """
  }
}
