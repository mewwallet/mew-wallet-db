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
    
  var address: String = ""
  // MARK: - LifeCycle
   
  public init(chain: MDBXChain, contractAddress: String, name: String, symbol: String, icon: String, description: String, schema_type: String, social: Social, stats: Stats, assets: [NFTAsset], address: String) {
    self.database = database ?? MEWwalletDBImpl.shared
    self._wrapped = .with {
      $0.contractAddress = contractAddress
      $0.name = name
      $0.symbol = symbol
      $0.icon = icon
      $0.description_p = description
      $0.schemaType = schema_type
      $0.social = social._wrapped
      $0.stats = stats._wrapped
      $0.assets = assets.lazy.map({$0._wrapped})
    }
    self.address = address
    self._chain = chain
  }
}

// MARK: - NFTCollection + Properties

extension NFTCollection {
  // MARK: - Properties
  public var contract_address: String { self._wrapped.contractAddress }
  public var name: String { self._wrapped.name }
  public var symbol: String { self._wrapped.symbol }
  public var icon: String { self._wrapped.icon }
  public var description: String { self._wrapped.description_p }
  public var schemaType: String { self._wrapped.schemaType }
  public var assets: [NFTAsset] {
    var result = [NFTAsset]()
    for item in self._wrapped.assets {
      var urlsType = [URLType]()
      for _urltype in item.urls {
        let urltype = URLType(chain: self._chain, type: _urltype.type, url: _urltype.url, database: self.database)
        urlsType.append(urltype)
      }
      let asset = NFTAsset(chain: self._chain, id: item.id, name: item.name, description: item.description_p, urls: urlsType, opensea_url: item.openseaURL, database: self.database, address: self.address, contract_address: self.contract_address)
      result.append(asset)
    }
    return result
  }
  public var account_address: String { self.address }
}

// MARK: - NFTCollection + MDBXObject

extension NFTCollection: MDBXObject {

  public var serialized: Data {
    get throws {
      return try self._wrapped.serializedData()
    }
  }
  
  public var key: MDBXKey {
    return NFTCollectionKey(chain: _chain, address: self.address, contractAddress: self.contract_address)
  }
  
  public var alternateKey: MDBXKey? { return nil }
  
  public init(serializedData data: Data, chain: MDBXChain, key: Data?, address: String?) throws {
    self._chain = chain
    self._wrapped = try _NFTCollection(serializedData: data)
    self.address = address
  }
  
  public init(jsonData: Data, chain: MDBXChain, key: Data?, address: String?) throws {
    var options = JSONDecodingOptions()
    options.ignoreUnknownFields = true
    self._chain = chain
    self._wrapped = try _NFTCollection(jsonUTF8Data: jsonData, options: options)
    self.address = address
  }
  
  public init(jsonString: String, chain: MDBXChain, key: Data?, address: String?) throws {
    var options = JSONDecodingOptions()
    options.ignoreUnknownFields = true
    self._chain = chain
    self._wrapped = try _NFTCollection(jsonString: jsonString, options: options)
    self.address = address
  }
  
  public static func array(fromJSONString string: String, chain: MDBXChain) throws -> [Self] {
    var options = JSONDecodingOptions()
    options.ignoreUnknownFields = true
    let objects = try _NFTCollection.array(fromJSONString: string, options: options)
    return objects.lazy.map({$0.wrapped(chain)})
  }
  
  public static func array(fromJSONData data: Data, chain: MDBXChain) throws -> [Self] {
    var options = JSONDecodingOptions()
    options.ignoreUnknownFields = true
    let objects = try _NFTCollection.array(fromJSONUTF8Data: data, options: options)
    return objects.lazy.map({$0.wrapped(chain)})
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
