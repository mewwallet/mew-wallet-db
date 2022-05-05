//
//  Floor.swift
//  
//
//  Created by Sergey Kolokolnikov on 05.05.2022.
//

import Foundation
import SwiftProtobuf
import mdbx_ios

public struct Floor: Equatable {
  public weak var database: WalletDB?
  var _wrapped: _Floor
  var _chain: MDBXChain
    
  // MARK: - LifeCycle
    
  public init(chain: MDBXChain, price: String, token: TokenMeta, database: WalletDB? = nil) {
    self.database = database ?? MEWwalletDBImpl.shared
    self._wrapped = .with {
      $0.price = price
      $0.token = token._wrapped
    }
    self._chain = chain
  }
}

// MARK: - Token + Properties

extension Floor {

  // MARK: - Properties
  
  public var price: String { self._wrapped.price }
  //public var token: [_TokenMeta] { self._wrapped.token }
}

// MARK: - Token + MDBXObject

extension Floor: MDBXObject {
  public var serialized: Data {
    get throws {
      return try self._wrapped.serializedData()
    }
  }
  
  public var key: MDBXKey {
    return FloorKey(chain: _chain)
  }
  
  public var alternateKey: MDBXKey? { return nil }
  
  public init(serializedData data: Data, chain: MDBXChain, key: Data?) throws {
    self._chain = chain
    self._wrapped = try _Floor(serializedData: data)
  }
  
  public init(jsonData: Data, chain: MDBXChain, key: Data?) throws {
    self._chain = chain
    var options = JSONDecodingOptions()
    options.ignoreUnknownFields = true
    self._wrapped = try _Floor(jsonUTF8Data: jsonData, options: options)
  }
  
  public init(jsonString: String, chain: MDBXChain, key: Data?) throws {
    self._chain = chain
    var options = JSONDecodingOptions()
    options.ignoreUnknownFields = true
    self._wrapped = try _Floor(jsonString: jsonString, options: options)
  }
  
  public static func array(fromJSONString string: String, chain: MDBXChain) throws -> [Self] {
    var options = JSONDecodingOptions()
    options.ignoreUnknownFields = true
    let objects = try _Floor.array(fromJSONString: string, options: options)
    return objects.lazy.map({ $0.wrapped(chain) })
  }
  
  public static func array(fromJSONData data: Data, chain: MDBXChain) throws -> [Self] {
    var options = JSONDecodingOptions()
    options.ignoreUnknownFields = true
    let objects = try _Floor.array(fromJSONUTF8Data: data, options: options)
    return objects.lazy.map({ $0.wrapped(chain) })
  }
  
  mutating public func merge(with object: MDBXObject) {
    let other = object as! Floor
    self._wrapped.price               = other._wrapped.price
    self._wrapped.token               = other._wrapped.token
  }
}

// MARK: - _Token + ProtoWrappedMessage

extension _Floor: ProtoWrappedMessage {
  func wrapped(_ chain: MDBXChain) -> Floor {
    return Floor(self, chain: chain)
  }
}

// MARK: - Token + Equitable

public extension Floor {
  static func ==(lhs: Floor, rhs: Floor) -> Bool {
    return lhs._chain == rhs._chain
        && lhs._wrapped == rhs._wrapped
  }
}

// MARK: - Token + ProtoWrapper

extension Floor: ProtoWrapper {
  init(_ wrapped: _Floor, chain: MDBXChain) {
    self._chain = chain
    self._wrapped = wrapped
  }
}
