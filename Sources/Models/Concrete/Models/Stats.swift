//
//  Stats.swift
//  
//
//  Created by Sergey Kolokolnikov on 05.05.2022.
//

import Foundation
import SwiftProtobuf
import mdbx_ios

public struct Stats: Equatable {
  public weak var database: WalletDB?
  var _wrapped: _Stats
  var _chain: MDBXChain
    
  // MARK: - LifeCycle
    
  public init(chain: MDBXChain, count: String, owners: String, market: Market, database: WalletDB? = nil) {
    self.database = database ?? MEWwalletDBImpl.shared
    self._wrapped = .with {
      $0.count = count
      $0.owners = owners
      $0.market = market._wrapped
    }
    self._chain = chain
  }
}

// MARK: - Token + Properties

extension Stats {

  // MARK: - Properties
  
  public var count: String { self._wrapped.count }
  public var owners: String { self._wrapped.owners }
}

// MARK: - Token + MDBXObject

extension Stats: MDBXObject {
  public var serialized: Data {
    get throws {
      return try self._wrapped.serializedData()
    }
  }
  
  public var key: MDBXKey {
    return StatsKey(chain: _chain)
  }
  
  public var alternateKey: MDBXKey? { return nil }
  
  public init(serializedData data: Data, chain: MDBXChain, key: Data?) throws {
    self._chain = chain
    self._wrapped = try _Stats(serializedData: data)
  }
  
  public init(jsonData: Data, chain: MDBXChain, key: Data?) throws {
    self._chain = chain
    var options = JSONDecodingOptions()
    options.ignoreUnknownFields = true
    self._wrapped = try _Stats(jsonUTF8Data: jsonData, options: options)
  }
  
  public init(jsonString: String, chain: MDBXChain, key: Data?) throws {
    self._chain = chain
    var options = JSONDecodingOptions()
    options.ignoreUnknownFields = true
    self._wrapped = try _Stats(jsonString: jsonString, options: options)
  }
  
  public static func array(fromJSONString string: String, chain: MDBXChain) throws -> [Self] {
    var options = JSONDecodingOptions()
    options.ignoreUnknownFields = true
    let objects = try _Stats.array(fromJSONString: string, options: options)
    return objects.lazy.map({ $0.wrapped(chain) })
  }
  
  public static func array(fromJSONData data: Data, chain: MDBXChain) throws -> [Self] {
    var options = JSONDecodingOptions()
    options.ignoreUnknownFields = true
    let objects = try _Stats.array(fromJSONUTF8Data: data, options: options)
    return objects.lazy.map({ $0.wrapped(chain) })
  }
  
  mutating public func merge(with object: MDBXObject) {
    let other = object as! Stats
    self._wrapped.owners               = other._wrapped.owners
    self._wrapped.count               = other._wrapped.count
    self._wrapped.market               = other._wrapped.market
  }
}

// MARK: - _Token + ProtoWrappedMessage

extension _Stats: ProtoWrappedMessage {
  func wrapped(_ chain: MDBXChain) -> Stats {
    return Stats(self, chain: chain)
  }
}

// MARK: - Token + Equitable

public extension Stats {
  static func ==(lhs: Stats, rhs: Stats) -> Bool {
    return lhs._chain == rhs._chain
        && lhs._wrapped == rhs._wrapped
  }
}

// MARK: - Token + ProtoWrapper

extension Stats: ProtoWrapper {
  init(_ wrapped: _Stats, chain: MDBXChain) {
    self._chain = chain
    self._wrapped = wrapped
  }
}
