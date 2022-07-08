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
  public enum Schema {
    case unknown
    case erc721
    case erc1155
    
    init(_ rawValue: String) {
      switch rawValue {
      case "ERC721":        self = .erc721
      case "ERC1155":       self = .erc1155
      default:              self = .unknown
      }
    }
  }
  
  public weak var database: WalletDB?
  var _wrapped: _NFTCollection
  var _chain: MDBXChain
  
  // MARK: - Private Properties
  
  private let _assets: MDBXRelationship<NFTAssetKey, NFTAsset> = .init(.nftAsset)
}

// MARK: - NFTCollection + Properties

extension NFTCollection {
  // MARK: - Relations
  
  public var assets: [NFTAsset] {
    get throws {
      let startKey = NFTAssetKey(collectionKey: self.key as? NFTCollectionKey, lowerRange: true)
      let endKey = NFTAssetKey(collectionKey: self.key as? NFTCollectionKey, lowerRange: false)
      return try _assets.getRangedRelationship(startKey: startKey, endKey: endKey, policy: .cacheOrLoad, database: self.database)
    }
  }
  
  // MARK: - Properties
  
  public var name: String { self._wrapped.name }
  public var description: String { self._wrapped.description_p }
  public var schema: Schema { Schema(self._wrapped.schemaType) }
  public var contract_address: Address { Address(rawValue: self._wrapped.contractAddress) }
  public var contract_name: String { self._wrapped.contractName }
  public var contract_symbol: String { self._wrapped.contractSymbol }
  public var image: URL? {
    guard !self._wrapped.image.isEmpty else { return nil }
    return URL(string: self._wrapped.image)
  }
  public var social: NFTSocial? {
    guard self._wrapped.hasSocial else { return nil }
    return self._wrapped.social.wrapped(_chain)
  }
  public var stats: NFTStats? {
    guard self._wrapped.hasStats else { return nil }
    return self._wrapped.stats.wrapped(_chain)
  }
}

// MARK: - NFTCollection + MDBXObject

extension NFTCollection: MDBXObject {

  public var serialized: Data {
    get throws {
      return try self._wrapped.serializedData()
    }
  }
  
  public var key: MDBXKey {
    return NFTCollectionKey(chain: _chain,
                            address: .unknown(self._wrapped.address),
                            contractAddress: .unknown(self._wrapped.contractAddress),
                            name: self._wrapped.name)
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
    return objects.lazy.map({$0.wrapped(chain)})
  }
  
  public static func array(fromJSONData data: Data, chain: MDBXChain) throws -> [Self] {
    var options = JSONDecodingOptions()
    options.ignoreUnknownFields = true
    let objects = try _NFTCollection.array(fromJSONUTF8Data: data, options: options)
    return objects.lazy.map({$0.wrapped(chain)})
  }
  
  public mutating func merge(with object: MDBXObject) {
    // TODO
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
    let assets = _wrapped._cleanAssets().map { $0.wrapped(chain, collection: self) }
    self._assets.updateData(assets)
  }
}

// MARK: - Array + NFTCollection

extension Array where Element == NFTCollection {
  var collectAssets: [NFTAsset] {
    get throws {
      try flatMap { try $0.assets }
    }
  }
  
  var collectMetas: [TokenMeta] {
    get throws {
      try collectAssets.compactMap { try $0.last_sale?.meta }
    }
  }
}
