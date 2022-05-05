//
//  URLType.swift
//  
//
//  Created by Sergey Kolokolnikov on 05.05.2022.
//

import Foundation
import SwiftProtobuf
import mdbx_ios

public struct URLType: Equatable {
  public weak var database: WalletDB?
  var _wrapped: _URLType
  var _chain: MDBXChain
    
  // MARK: - LifeCycle
    
  public init(chain: MDBXChain, type: String, url: String, database: WalletDB? = nil) {
    self.database = database ?? MEWwalletDBImpl.shared
    self._wrapped = .with {
      $0.type = type
      $0.url = url
    }
    self._chain = chain
  }
}

// MARK: - Token + Properties

extension URLType {

  // MARK: - Properties
  
  public var type: String { self._wrapped.type }
  public var url: String { self._wrapped.url }
}

// MARK: - Token + MDBXObject

extension URLType: MDBXObject {
  public var serialized: Data {
    get throws {
      return try self._wrapped.serializedData()
    }
  }
  
  public var key: MDBXKey {
    return URLTypeKey(chain: _chain)
  }
  
  public var alternateKey: MDBXKey? { return nil }
  
  public init(serializedData data: Data, chain: MDBXChain, key: Data?) throws {
    self._chain = chain
    self._wrapped = try _URLType(serializedData: data)
  }
  
  public init(jsonData: Data, chain: MDBXChain, key: Data?) throws {
    self._chain = chain
    var options = JSONDecodingOptions()
    options.ignoreUnknownFields = true
    self._wrapped = try _URLType(jsonUTF8Data: jsonData, options: options)
  }
  
  public init(jsonString: String, chain: MDBXChain, key: Data?) throws {
    self._chain = chain
    var options = JSONDecodingOptions()
    options.ignoreUnknownFields = true
    self._wrapped = try _URLType(jsonString: jsonString, options: options)
  }
  
  public static func array(fromJSONString string: String, chain: MDBXChain) throws -> [Self] {
    var options = JSONDecodingOptions()
    options.ignoreUnknownFields = true
    let objects = try _URLType.array(fromJSONString: string, options: options)
    return objects.lazy.map({ $0.wrapped(chain) })
  }
  
  public static func array(fromJSONData data: Data, chain: MDBXChain) throws -> [Self] {
    var options = JSONDecodingOptions()
    options.ignoreUnknownFields = true
    let objects = try _URLType.array(fromJSONUTF8Data: data, options: options)
    return objects.lazy.map({ $0.wrapped(chain) })
  }
  
  mutating public func merge(with object: MDBXObject) {
    let other = object as! URLType
    self._wrapped.type               = other._wrapped.type
    self._wrapped.url               = other._wrapped.url
  }
}

// MARK: - _Token + ProtoWrappedMessage

extension _URLType: ProtoWrappedMessage {
  func wrapped(_ chain: MDBXChain) -> URLType {
    return URLType(self, chain: chain)
  }
}

// MARK: - Token + Equitable

public extension URLType {
  static func ==(lhs: URLType, rhs: URLType) -> Bool {
    return lhs._chain == rhs._chain
        && lhs._wrapped == rhs._wrapped
  }
}

// MARK: - Token + ProtoWrapper

extension URLType: ProtoWrapper {
  init(_ wrapped: _URLType, chain: MDBXChain) {
    self._chain = chain
    self._wrapped = wrapped
  }
}
