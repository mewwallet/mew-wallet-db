//
//  File.swift
//  
//
//  Created by macbook on 1.02.2023.
//

import Foundation
import SwiftProtobuf

public struct MarketMoversItem: Equatable {
  public weak var database: WalletDB? = MEWwalletDBImpl.shared
  var _wrapped: _MarketMoversItem

  // MARK: - Lifecycle
  
  public init(
    contractAddress: String?,
    database: WalletDB? = nil
  ) {
    self.database = database ?? MEWwalletDBImpl.shared
    
    self._wrapped = .with {
      if let contractAddress {
        $0.contractAddress = contractAddress
      }
    }
  }
  
  init(
    database: WalletDB? = nil,
    _wrapped: _MarketMoversItem
  ) {
    self.database = database ?? MEWwalletDBImpl.shared
    self._wrapped = _wrapped
  }
}

// MARK: - MarketMoversItem + Equitable

public extension MarketMoversItem {
  static func ==(lhs: MarketMoversItem, rhs: MarketMoversItem) -> Bool {
    return lhs._wrapped == rhs._wrapped
  }
}

extension MarketMoversItem: MDBXObject {
  public var serialized: Data {
    get throws {
      try _wrapped.serializedData()
    }
  }
  
  public var key: MDBXKey {
    assertionFailure("not implemented")
    return MarketMoversItemKey(chain: .universal, currency: "", sort: "", index: 0)
  }
  
  public var alternateKey: MDBXKey? {
    nil
  }
  
  public init(serializedData data: Data, chain: MDBXChain, key: Data?) throws {
    self._wrapped = try _MarketMoversItem(serializedData: data)
  }
  
  public init(jsonData: Data, chain: MDBXChain, key: Data?) throws {
    var options = JSONDecodingOptions()
    options.ignoreUnknownFields = true
    self._wrapped = try _MarketMoversItem(jsonUTF8Data: jsonData, options: options)
  }
  
  public init(jsonString: String, chain: MDBXChain, key: Data?) throws {
    var options = JSONDecodingOptions()
    options.ignoreUnknownFields = true
    self._wrapped = try _MarketMoversItem(jsonString: jsonString, options: options)
  }
  
  public mutating func merge(with object: MDBXObject) {
    guard let other = object as? MarketMoversItem else {
      return
    }
    
    self._wrapped.contractAddress = other._wrapped.contractAddress
  }
  
  public static func array(fromJSONString string: String, chain: MDBXChain) throws -> [MarketMoversItem] {
    var options = JSONDecodingOptions()
    options.ignoreUnknownFields = true
    let objects = try _MarketMoversItem.array(fromJSONString: string, options: options)
    return objects.lazy.map({
      MarketMoversItem(_wrapped: $0)
    })
  }
  
  public static func array(fromJSONData data: Data, chain: MDBXChain) throws -> [MarketMoversItem] {
    var options = JSONDecodingOptions()
    options.ignoreUnknownFields = true
    let objects = try _MarketMoversItem.array(fromJSONUTF8Data: data, options: options)
    return objects.lazy.map({
      MarketMoversItem(_wrapped: $0)
    })
  }
}
