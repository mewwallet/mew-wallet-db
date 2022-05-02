//
//  File.swift
//  
//
//  Created by Sergey Kolokolnikov on 29.04.2022.
//

import Foundation
import SwiftProtobuf
import mdbx_ios

public struct NFTCollection: Equatable {
  public weak var database: WalletDB?
  var _wrapped: _NFTCollection
  var _chain: MDBXChain
    
  var accountAddress: String = ""
  // MARK: - LifeCycle
   
  public init(chain: MDBXChain, contractAddress: String, name: String = "No Token Name", symbol: String = "MNKY", icon: String = "https://", description: String = "", schema_type: String = "", social: [String: String]) {
    self.database = database ?? MEWwalletDBImpl.shared
    self._wrapped = .with {
      $0.contractAddress = contractAddress
      $0.name = name
      $0.symbol = symbol
      $0.icon = icon
      $0.description_p = description
      $0.schemaType = schema_type
      $0.social = social
    }
    self._chain = chain
  }
}

// MARK: - NFTCollection + Properties

extension NFTCollection {
  // MARK: - Properties
  public var contract_address: String { self._wrapped.contractAddress }
  public var name: String { self._wrapped.name }
  public var symbol: String { self._wrapped.symbol }
  public var icon: String { String(self._wrapped.icon) }
  public var schemaType: String { String(self._wrapped.schemaType) }
}

// MARK: - NFTCollection + MDBXObject

extension NFTCollection: MDBXObject {
  
  public var serialized: Data {
    get throws {
      return try self._wrapped.serializedData()
    }
  }
  
  public var key: MDBXKey {
    return NFTCollectionKey(chain: _chain, contractAddress: self.contract_address, accountAddress: self.accountAddress)
  }
  
  public var alternateKey: MDBXKey? { return nil }
  
  public init(serializedData data: Data, chain: MDBXChain, key: Data?) throws {
    self._chain = chain
    self._wrapped = try _NFTCollection(serializedData: data)
  }
  
  public init(jsonData: Data, chain: MDBXChain, key: Data?) throws {
    var options = JSONDecodingOptions()
    options.ignoreUnknownFields = true
    self._chain = chain
    self._wrapped = try _NFTCollection(jsonUTF8Data: jsonData, options: options)
  }
  
  public init(jsonString: String, chain: MDBXChain, key: Data?) throws {
    var options = JSONDecodingOptions()
    options.ignoreUnknownFields = true
    self._chain = chain
    self._wrapped = try _NFTCollection(jsonString: jsonString, options: options)
  }
  
  public static func array(fromJSONString string: String, chain: MDBXChain) throws -> [Self] {
    var options = JSONDecodingOptions()
    options.ignoreUnknownFields = true
    let objects = try _NFTCollection.array(fromJSONString: string, options: options)
    return objects.lazy.map({ $0.wrapped(chain) })
  }
  
  public static func array(fromJSONData data: Data, chain: MDBXChain) throws -> [Self] {
    var options = JSONDecodingOptions()
    options.ignoreUnknownFields = true
    let objects = try _NFTCollection.array(fromJSONUTF8Data: data, options: options)
    return objects.lazy.map({ $0.wrapped(chain) })
  }
  
  public mutating func merge(with object: MDBXObject) {
    
  }

}

// MARK: - _NFTCollection + ProtoWrappedMessage

extension _NFTCollection: ProtoWrappedMessage {
  func wrapped(_ chain: MDBXChain) -> NFTCollection {
    return NFTCollection(self, chain: chain)
  }
}

// MARK: - NFTCollection + Equitable

public extension NFTCollection {
  static func ==(lhs: NFTCollection, rhs: NFTCollection) -> Bool {
    return lhs._chain == rhs._chain
        && lhs._wrapped == rhs._wrapped
  }
}

// MARK: - NFTCollection + ProtoWrapper

extension NFTCollection: ProtoWrapper {
  init(_ wrapped: _NFTCollection, chain: MDBXChain) {
    self._chain = chain
    self._wrapped = wrapped
  }
}
