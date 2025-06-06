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
  
  public weak var database: (any WalletDB)?
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
      guard let key = self.key as? NFTCollectionKey else { return [] }
      let range = NFTAssetKey.range(collectionKey: key)
      return try _assets.getRelationship(range, policy: .cacheOrLoad, order: .asc, chain: _chain, database: self.database)
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
  public var cursor: String? {
    guard self._wrapped.hasCursor else { return nil }
    return self._wrapped.cursor
  }
}

// MARK: - NFTCollection + MDBXObject

extension NFTCollection: MDBXObject {

  public var serialized: Data {
    get throws {
      return try self._wrapped.serializedData()
    }
  }
  
  public var key: any MDBXKey {
    return NFTCollectionKey(chain: _chain,
                            address: Address(self._wrapped.address),
                            contractAddress: Address(self._wrapped.contractAddress),
                            name: self._wrapped.name)
  }
  
  public var alternateKey: (any MDBXKey)? { return nil }
  
  public init(serializedData data: Data, chain: MDBXChain, key: Data?) throws {
    self._chain = chain
    self._wrapped = try _NFTCollection(serializedBytes: data)
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
  
  public mutating func merge(with object: any MDBXObject) {
    let other = object as! NFTCollection
    
    self._wrapped.address = other._wrapped.address
    self._wrapped.name = other._wrapped.name
    self._wrapped.description_p = other._wrapped.description_p
    self._wrapped.image = other._wrapped.image
    self._wrapped.schemaType = other._wrapped.schemaType
    self._wrapped.contractAddress = other._wrapped.contractAddress
    self._wrapped.contractName = other._wrapped.contractName
    self._wrapped.contractSymbol = other._wrapped.contractSymbol
    if other._wrapped.hasSocial {
      self._wrapped.social = other._wrapped.social
    }
    if other._wrapped.hasStats {
      self._wrapped.stats = other._wrapped.stats
    }
  }
}

// MARK: - _NFTCollection + ProtoWrappedMessage

extension _NFTCollection: ProtoWrappedMessage {
  func wrapped(_ chain: MDBXChain) -> NFTCollection {
    return NFTCollection(self, chain: chain)
  }
}

// MARK: - NFTCollection + Equatable

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
    self._assets.updateData(assets, chain: chain)
  }
}

// MARK: - Array + NFTCollection

extension Array where Element == NFTCollection {
  public var collectAssets: [NFTAsset] {
    get throws {
      return try flatMap { try $0.assets }
    }
  }
  
  public func collectMetas(chain: MDBXChain) throws -> [TokenMeta] {
    try collectAssets.compactMap { try $0.last_sale?.meta(chain: chain) }
  }
}
