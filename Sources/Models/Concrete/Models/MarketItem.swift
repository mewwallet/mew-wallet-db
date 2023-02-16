//
//  File.swift
//  
//
//  Created by macbook on 1.02.2023.
//

import Foundation

import Foundation
import SwiftProtobuf

public struct MarketItem: Equatable {
  public weak var database: WalletDB? = MEWwalletDBImpl.shared
  var _wrapped: _MarketItem
  
  // MARK: - Lifecycle
  
  public init(
    circulatingSupply: Decimal?,
    contractAddress: String?,
    marketCap: Decimal?,
    totalSupply: Decimal?,
    volume24h: Decimal?,
    database: WalletDB? = nil
  ) {
    self.database = database ?? MEWwalletDBImpl.shared
    
    self._wrapped = .with {
      if let circulatingSupply {
        $0.circulatingSupply = circulatingSupply.hexString
      }
      if let contractAddress {
        $0.contractAddress = contractAddress
      }
      
      if let marketCap {
        $0.marketCap = marketCap.hexString
      }
      if let totalSupply {
        $0.totalSupply = totalSupply.hexString
      }
      if let volume24h {
        $0.volume24H = volume24h.hexString
      }
    }
  }
  
  init(database: WalletDB? = nil, _wrapped: _MarketItem) {
    self._wrapped = _wrapped
  }
}

// MARK: - MarketMoversItem + Equitable

public extension MarketItem {
  static func ==(lhs: MarketItem, rhs: MarketItem) -> Bool {
    return lhs._wrapped == rhs._wrapped
  }
}

// MARK: - Properties
extension MarketItem {
  public var marketCap: Decimal {
    Decimal(hex: _wrapped.marketCap)
  }
  
  public var contractAddres: String {
    _wrapped.contractAddress
  }
  
  public var circulatingSupply: Decimal {
    Decimal(hex: _wrapped.circulatingSupply)
  }
  
  public var totalSupply: Decimal {
    Decimal(hex: _wrapped.totalSupply)
  }
  
  public var volume24h: Decimal {
    Decimal(hex: _wrapped.volume24H)
  }
}

extension MarketItem: MDBXObject {
  public var serialized: Data {
    get throws {
      try _wrapped.serializedData()
    }
  }
  
  public var key: MDBXKey {
    assertionFailure("not implemented")
    return MarketCollectionItemKey(chain: .universal, index: 0)
  }
  
  public var alternateKey: MDBXKey? {
    nil
  }
  
  public init(serializedData: Data, chain: MDBXChain, key: Data?) throws {
    self._wrapped = try _MarketItem(serializedData: serializedData)
  }
  
  public init(jsonString: String, chain: MDBXChain, key: Data?) throws {
    var options = JSONDecodingOptions()
    options.ignoreUnknownFields = true
    self._wrapped = try _MarketItem(jsonString: jsonString, options: options)
  }
  
  public init(jsonData: Data, chain: MDBXChain, key: Data?) throws {
    var options = JSONDecodingOptions()
    options.ignoreUnknownFields = true
    self._wrapped = try _MarketItem(jsonUTF8Data: jsonData, options: options)
  }
  
  public static func array(fromJSONString string: String, chain: MDBXChain) throws -> [MarketItem] {
    var options = JSONDecodingOptions()
    options.ignoreUnknownFields = true
    let objects = try _MarketItem.array(fromJSONString: string, options: options)
    return objects.lazy.map({
      MarketItem(_wrapped: $0)
    })
  }
  
  public static func array(fromJSONData data: Data, chain: MDBXChain) throws -> [MarketItem] {
    var options = JSONDecodingOptions()
    options.ignoreUnknownFields = true
    let objects = try _MarketItem.array(fromJSONUTF8Data: data, options: options)
    return objects.lazy.map({
      MarketItem(_wrapped: $0)
    })
  }
  
  public mutating func merge(with object: MDBXObject) {
    guard let other = object as? MarketItem else {
      return
    }
    
    self._wrapped.contractAddress = other._wrapped.contractAddress
    self._wrapped.volume24H = other._wrapped.volume24H
    self._wrapped.marketCap = other._wrapped.marketCap
    self._wrapped.circulatingSupply = other._wrapped.circulatingSupply
    self._wrapped.totalSupply = other._wrapped.totalSupply
  }
}
