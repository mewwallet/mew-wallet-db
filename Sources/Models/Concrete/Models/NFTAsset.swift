//
//  Asset.swift
//  
//
//  Created by Sergey Kolokolnikov on 05.05.2022.
//

import Foundation
import SwiftProtobuf
import mdbx_ios

public struct NFTAsset: Equatable {
  public weak var database: WalletDB?
  var _wrapped: _Asset
  var _chain: MDBXChain
  var address: String?
  var contract_address: String?
  
  // MARK: - LifeCycle
    
  public init(chain: MDBXChain, id: String, name: String, description: String, urls: [URLType], opensea_url: String, database: WalletDB? = nil, address: String, contract_address: String) {
    self.database = database ?? MEWwalletDBImpl.shared
    self._wrapped = .with {
      $0.id = id
      $0.name = name
      $0.description_p = description
      $0.urls = urls.lazy.map({$0._wrapped})
      $0.openseaURL = opensea_url
    }
    self._chain = chain
    self.address = address
    self.contract_address = contract_address
  }
}

// MARK: - Asset + Properties

extension NFTAsset {

  // MARK: - Properties
  
  public var id: String { self._wrapped.id }
  public var name: String { self._wrapped.name }
  public var description: String { self._wrapped.description_p }
  public var urls: [URLType] {
    var result = [URLType]()
    for _urlType in self._wrapped.urls {
      let urlType = URLType(chain: self._chain, type: _urlType.type, url: _urlType.url, database: self.database)
      result.append(urlType)
    }
    return result
  }
  public var openseaURL: String { self._wrapped.openseaURL }
}

// MARK: - Asset + MDBXObject

extension NFTAsset: MDBXObject {

  public var serialized: Data {
    get throws {
      return try self._wrapped.serializedData()
    }
  }
  
  public var key: MDBXKey {
    return NFTAssetKey(chain: _chain, address: address ?? "", contractAddress: contract_address ?? "", id: id)
  }
  
  public var alternateKey: MDBXKey? { return nil }
  
  public init(serializedData data: Data, chain: MDBXChain, key: Data?) throws {
    self._chain = chain
    self._wrapped = try _Asset(serializedData: data)
  }
  
  public init(jsonData: Data, chain: MDBXChain, key: Data?) throws {
    self._chain = chain
    var options = JSONDecodingOptions()
    options.ignoreUnknownFields = true
    self._wrapped = try _Asset(jsonUTF8Data: jsonData, options: options)
  }
  
  public init(jsonString: String, chain: MDBXChain, key: Data?) throws {
    self._chain = chain
    var options = JSONDecodingOptions()
    options.ignoreUnknownFields = true
    self._wrapped = try _Asset(jsonString: jsonString, options: options)
  }
  
  public static func array(fromJSONString string: String, chain: MDBXChain) throws -> [Self] {
    var options = JSONDecodingOptions()
    options.ignoreUnknownFields = true
    let objects = try _Asset.array(fromJSONString: string, options: options)
    return objects.lazy.map({ $0.wrapped(chain) })
  }
  
  public static func array(fromJSONData data: Data, chain: MDBXChain) throws -> [Self] {
    var options = JSONDecodingOptions()
    options.ignoreUnknownFields = true
    let objects = try _Asset.array(fromJSONUTF8Data: data, options: options)
    return objects.lazy.map({ $0.wrapped(chain) })
  }
  
  mutating public func merge(with object: MDBXObject) {
    let other = object as! Asset
    self._wrapped.id                 = other._wrapped.id
    self._wrapped.name               = other._wrapped.name
    self._wrapped.description_p      = other._wrapped.description_p
    self._wrapped.openseaURL         = other._wrapped.openseaURL
    self._wrapped.urls               = other._wrapped.urls
  }
}

// MARK: - _Asset + ProtoWrappedMessage

extension _Asset: ProtoWrappedMessage {
  func wrapped(_ chain: MDBXChain) -> Asset {
    return Asset(self, chain: chain)
  }
}

// MARK: - Asset + Equitable

public extension NFTAsset {
  static func ==(lhs: NFTAsset, rhs: NFTAsset) -> Bool {
    return lhs._chain == rhs._chain
        && lhs._wrapped == rhs._wrapped
  }
}

// MARK: - Asset + ProtoWrapper

extension NFTAsset: ProtoWrapper {
  init(_ wrapped: _Asset, chain: MDBXChain) {
    self._chain = chain
    self._wrapped = wrapped
  }
}
