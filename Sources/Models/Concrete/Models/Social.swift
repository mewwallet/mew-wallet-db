//
//  File.swift
//  
//
//  Created by Sergey Kolokolnikov on 03.05.2022.
//

import Foundation
import SwiftProtobuf
import mdbx_ios

public struct Social: Equatable {
  public weak var database: WalletDB?
  var _wrapped: _Social
  var _chain: MDBXChain
    
  // MARK: - LifeCycle
    
  public init(chain: MDBXChain, website: String, discord: String, database: WalletDB? = nil) {
    self.database = database ?? MEWwalletDBImpl.shared
    self._wrapped = .with {
      $0.website = website
      $0.discord = discord
    }
    self._chain = chain
  }
}

// MARK: - Token + Properties

extension Social {

  // MARK: - Properties
  
  public var website: String { self._wrapped.website }
  public var discord: String { self._wrapped.discord }
}

// MARK: - Token + MDBXObject

extension Social: MDBXObject {
  public var serialized: Data {
    get throws {
      return try self._wrapped.serializedData()
    }
  }
  
  public var key: MDBXKey {
    return SocialKey(chain: _chain)
  }
  
  public var alternateKey: MDBXKey? { return nil }
  
  public init(serializedData data: Data, chain: MDBXChain, key: Data?) throws {
    self._chain = chain
    self._wrapped = try _Social(serializedData: data)
  }
  
  public init(jsonData: Data, chain: MDBXChain, key: Data?) throws {
    self._chain = chain
    var options = JSONDecodingOptions()
    options.ignoreUnknownFields = true
    self._wrapped = try _Social(jsonUTF8Data: jsonData, options: options)
  }
  
  public init(jsonString: String, chain: MDBXChain, key: Data?) throws {
    self._chain = chain
    var options = JSONDecodingOptions()
    options.ignoreUnknownFields = true
    self._wrapped = try _Social(jsonString: jsonString, options: options)
  }
  
  public static func array(fromJSONString string: String, chain: MDBXChain) throws -> [Self] {
    var options = JSONDecodingOptions()
    options.ignoreUnknownFields = true
    let objects = try _Social.array(fromJSONString: string, options: options)
    return objects.lazy.map({ $0.wrapped(chain) })
  }
  
  public static func array(fromJSONData data: Data, chain: MDBXChain) throws -> [Self] {
    var options = JSONDecodingOptions()
    options.ignoreUnknownFields = true
    let objects = try _Social.array(fromJSONUTF8Data: data, options: options)
    return objects.lazy.map({ $0.wrapped(chain) })
  }
  
  mutating public func merge(with object: MDBXObject) {
    let other = object as! Social
    self._wrapped.website               = other._wrapped.website
    self._wrapped.discord               = other._wrapped.discord
  }
}

// MARK: - _Token + ProtoWrappedMessage

extension _Social: ProtoWrappedMessage {
  func wrapped(_ chain: MDBXChain) -> Social {
    return Social(self, chain: chain)
  }
}

// MARK: - Token + Equitable

public extension Social {
  static func ==(lhs: Social, rhs: Social) -> Bool {
    return lhs._chain == rhs._chain
        && lhs._wrapped == rhs._wrapped
  }
}

// MARK: - Token + ProtoWrapper

extension Social: ProtoWrapper {
  init(_ wrapped: _Social, chain: MDBXChain) {
    self._chain = chain
    self._wrapped = wrapped
  }
}
