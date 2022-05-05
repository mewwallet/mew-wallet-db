//
//  Market.swift
//  
//
//  Created by Sergey Kolokolnikov on 05.05.2022.
//

import Foundation
import SwiftProtobuf
import mdbx_ios

public struct Market: Equatable {
  public weak var database: WalletDB?
  var _wrapped: _Market
  var _chain: MDBXChain
    
  // MARK: - LifeCycle
    
  public init(chain: MDBXChain, floor: Floor, database: WalletDB? = nil) {
    self.database = database ?? MEWwalletDBImpl.shared
    self._wrapped = .with {
      $0.floor = floor._wrapped
    }
    self._chain = chain
  }
}

// MARK: - Token + Properties

extension Market {

  // MARK: - Properties
  
  //public var floor: String { self._wrapped.floor }
}

// MARK: - Token + MDBXObject

extension Market: MDBXObject {
  public var serialized: Data {
    get throws {
      return try self._wrapped.serializedData()
    }
  }
  
  public var key: MDBXKey {
    return MarketKey(chain: _chain)
  }
  
  public var alternateKey: MDBXKey? { return nil }
  
  public init(serializedData data: Data, chain: MDBXChain, key: Data?) throws {
    self._chain = chain
    self._wrapped = try _Market(serializedData: data)
  }
  
  public init(jsonData: Data, chain: MDBXChain, key: Data?) throws {
    self._chain = chain
    var options = JSONDecodingOptions()
    options.ignoreUnknownFields = true
    self._wrapped = try _Market(jsonUTF8Data: jsonData, options: options)
  }
  
  public init(jsonString: String, chain: MDBXChain, key: Data?) throws {
    self._chain = chain
    var options = JSONDecodingOptions()
    options.ignoreUnknownFields = true
    self._wrapped = try _Market(jsonString: jsonString, options: options)
  }
  
  public static func array(fromJSONString string: String, chain: MDBXChain) throws -> [Self] {
    var options = JSONDecodingOptions()
    options.ignoreUnknownFields = true
    let objects = try _Market.array(fromJSONString: string, options: options)
    return objects.lazy.map({ $0.wrapped(chain) })
  }
  
  public static func array(fromJSONData data: Data, chain: MDBXChain) throws -> [Self] {
    var options = JSONDecodingOptions()
    options.ignoreUnknownFields = true
    let objects = try _Market.array(fromJSONUTF8Data: data, options: options)
    return objects.lazy.map({ $0.wrapped(chain) })
  }
  
  mutating public func merge(with object: MDBXObject) {
    let other = object as! Market
    self._wrapped.floor               = other._wrapped.floor
  }
}

// MARK: - _Token + ProtoWrappedMessage

extension _Market: ProtoWrappedMessage {
  func wrapped(_ chain: MDBXChain) -> Market {
    return Market(self, chain: chain)
  }
}

// MARK: - Token + Equitable

public extension Market {
  static func ==(lhs: Market, rhs: Market) -> Bool {
    return lhs._chain == rhs._chain
        && lhs._wrapped == rhs._wrapped
  }
}

// MARK: - Token + ProtoWrapper

extension Market: ProtoWrapper {
  init(_ wrapped: _Market, chain: MDBXChain) {
    self._chain = chain
    self._wrapped = wrapped
  }
}
