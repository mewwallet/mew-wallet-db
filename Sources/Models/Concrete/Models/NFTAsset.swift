//
//  NFTAsset.swift
//  
//
//  Created by Sergey Kolokolnikov on 05.05.2022.
//

import Foundation
import SwiftProtobuf
import mdbx_ios

public struct NFTAsset: Equatable {
  public weak var database: (any WalletDB)? 
  var _wrapped: _NFTAsset
  var _chain: MDBXChain
  
  // MARK: - Private Properties
  
  fileprivate var _collectionKey: NFTCollectionKey?
  fileprivate let _collection: MDBXPointer<NFTCollectionKey, NFTCollection> = .init(.nftCollection)
  fileprivate let _account: MDBXPointer<AccountKey, Account> = .init(.account)
  
  // MARK: - Private
  
  mutating private func tryRestoreCollectionKey(_ key: Data?) {
    guard let key = key else { return }
    if let key = NFTAssetKey(data: key) {
      _collectionKey = key.collectionKey
    }
  }
  
  @SubProperty<[_NFTAssetTrait], [NFTAssetTrait]>   var _traits: [_NFTAssetTrait]?
  @SubProperty<[_NFTAssetUrl], [NFTAssetURL]>       var _urls: [_NFTAssetUrl]?
  @SubProperty<_NFTAssetLastSale, NFTAssetLastSale> var _last_sale: _NFTAssetLastSale?
}

// MARK: - NFTAsset + Properties

extension NFTAsset {
  // MARK: - Relations
  
  public var collection: NFTCollection? {
    get throws {
      guard let key = _collectionKey else { return nil }
      return try _collection.getData(key: key, policy: .cacheOrLoad, chain: _chain, database: self.database)
    }
  }
  
  public var account: Account? {
    get throws {
      guard let collectionKey = _collectionKey else { return nil }
      let key = AccountKey(chain: .evm, address: collectionKey.address)
      return try _account.getData(key: key, policy: .ignoreCache, chain: .evm, database: self.database)
    }
  }

  // MARK: - Properties
  
  public var token_id: String { _wrapped.tokenID }
  public var contract_address: Address { Address(rawValue: self._wrapped.contractAddress) }
  public var name: String? { _wrapped.name }
  public var description: String? {
    guard _wrapped.hasDescription_p else { return nil }
    return _wrapped.description_p
  }
  public var traits: [NFTAssetTrait] {
    guard !_wrapped.traits.isEmpty else { return [] }
    return self.$_traits ?? []
  }
  public var urls: [NFTAssetURL] {
    guard !_wrapped.urls.isEmpty else { return [] }
    return self.$_urls ?? []
  }
  public var last_sale: NFTAssetLastSale? {
    guard _wrapped.hasLastSale else { return nil }
    return self.$_last_sale
  }
  public var opensea_url: URL? {
    guard self._wrapped.hasOpenseaURL else { return nil }
    return URL(string: self._wrapped.openseaURL)
  }
  public var displayType: NFTAssetURL.DisplayType? {
    guard !self.urls.isEmpty else { return nil }
    if let video = self.urls.first(where: { $0.type == .video }) {
      return video.displayType
    } else if let audio = self.urls.first(where: { $0.type == .audio }) {
      return audio.displayType
    } else if let media = self.urls.first(where: { $0.type == .media }) {
      return media.displayType
    } else if let image = self.urls.first(where: { $0.type == .image }) {
      return image.displayType
    } else if let preview = self.urls.first(where: { $0.type == .preview }) {
      return preview.displayType
    }
    return nil
  }
  public var fallbackDisplayType: NFTAssetURL.DisplayType? {
    guard !self.urls.isEmpty else { return nil }
    if let media = self.urls.first(where: { $0.type == .media }) {
      return media.displayType
    } else if let image = self.urls.first(where: { $0.type == .image }) {
      return image.displayType
    } else if let preview = self.urls.first(where: { $0.type == .preview }) {
      return preview.displayType
    }
    return nil
  }
  
  public var image_url: URL? {
    self.urls.first { $0.type == .image }?.url ?? preview_url
  }
  public var preview_url: URL? {
    self.urls.first { $0.type == .preview }?.url
  }
  public func isFavorite(chain: MDBXChain) -> Bool {
    guard let account = try? account, let key = self.key as? NFTAssetKey else { return false }
    return account.nftFavoriteKeys(chain: chain).contains(key)
  }
  public func isHidden(chain: MDBXChain) -> Bool {
    guard let account = try? account, let key = self.key as? NFTAssetKey else { return false }
    return account.nftHiddenKeys(chain: chain).contains(key)
  }
  public var ownerAddress: Address? {
    guard let collectionKey = _collectionKey else { return nil }
    return collectionKey.address
  }
  public var last_acquired_date: String {
    set { _wrapped.lastAcquiredDate = newValue }
    get { _wrapped.lastAcquiredDate }
  }
  
  // MARK: - Methods
  
  /// Toggles favorite flag of NFT
  /// - Returns: Updated Account that needs to be send back to DB
  public func toggleFavorite() -> Account? {
    guard var account = try? account, let key = self.key as? NFTAssetKey else { return nil }
    account.toggleNFTIsFavorite(key)
    return account
  }
  
  /// Toggles hidden flag of NFT
  /// - Returns: Updated Account that needs to be send back to DB
  public func toggleHidden() -> Account? {
    guard var account = try? account, let key = self.key as? NFTAssetKey else { return nil }
    account.toggleNFTIsHidden(key)
    return account
  }
}

// MARK: - NFTAsset + MDBXObject

extension NFTAsset: MDBXObject {

  public var serialized: Data {
    get throws {
      return try self._wrapped.serializedData()
    }
  }
  
  public var key: any MDBXKey {
    NFTAssetKey(collectionKey: _collectionKey,
                date: _wrapped.lastAcquiredDate,
                contractAddress: Address(_wrapped.contractAddress),
                id: _wrapped.tokenID)
  }
  
  public var alternateKey: (any MDBXKey)? { return nil }
  
  public init(serializedData data: Data, chain: MDBXChain, key: Data?) throws {
    self._chain = chain
    self._wrapped = try _NFTAsset(serializedBytes: data)
    commonInit(chain: chain, key: key)
  }
  
  public init(jsonData: Data, chain: MDBXChain, key: Data?) throws {
    self._chain = chain
    var options = JSONDecodingOptions()
    options.ignoreUnknownFields = true
    self._wrapped = try _NFTAsset(jsonUTF8Data: jsonData, options: options)
    commonInit(chain: chain, key: key)
  }
  
  public init(jsonString: String, chain: MDBXChain, key: Data?) throws {
    self._chain = chain
    var options = JSONDecodingOptions()
    options.ignoreUnknownFields = true
    self._wrapped = try _NFTAsset(jsonString: jsonString, options: options)
    commonInit(chain: chain, key: key)
  }
  
  public static func array(fromJSONString string: String, chain: MDBXChain) throws -> [Self] {
    var options = JSONDecodingOptions()
    options.ignoreUnknownFields = true
    let objects = try _NFTAsset.array(fromJSONString: string, options: options)
    return objects.lazy.map({ $0.wrapped(chain) })
  }
  
  public static func array(fromJSONData data: Data, chain: MDBXChain) throws -> [Self] {
    var options = JSONDecodingOptions()
    options.ignoreUnknownFields = true
    let objects = try _NFTAsset.array(fromJSONUTF8Data: data, options: options)
    return objects.lazy.map({ $0.wrapped(chain) })
  }
  
  mutating public func merge(with object: any MDBXObject) {
    let other = object as! NFTAsset
    
    self._wrapped.tokenID = other._wrapped.tokenID
    self._wrapped.contractAddress = other._wrapped.contractAddress
    if other._wrapped.hasName {
      self._wrapped.name = other._wrapped.name
    }
    if other._wrapped.hasDescription_p {
      self._wrapped.description_p = other._wrapped.description_p
    }
    self._wrapped.traits = other._wrapped.traits
    self._wrapped.urls = other._wrapped.urls
    if other._wrapped.hasLastSale {
      self._wrapped.lastSale = other._wrapped.lastSale
    }
    if other._wrapped.hasOpenseaURL {
      self._wrapped.openseaURL = other._wrapped.openseaURL
    }
  }
}

// MARK: - _NFTAsset + ProtoWrappedMessage

extension _NFTAsset: ProtoWrappedMessage {
  func wrapped(_ chain: MDBXChain) -> NFTAsset {
    return NFTAsset(self, chain: chain)
  }
  
  func wrapped(_ chain: MDBXChain, collection: NFTCollection) -> NFTAsset {
    var asset = NFTAsset(self, chain: chain)
    asset._collectionKey = collection.key as? NFTCollectionKey
    asset._collection.updateData(collection, chain: chain)
    asset.commonInit(chain: chain, key: nil)
    return asset
  }
}

// MARK: - NFTAsset + Equitable

public extension NFTAsset {
  static func ==(lhs: NFTAsset, rhs: NFTAsset) -> Bool {
    return lhs._chain == rhs._chain
        && lhs._wrapped == rhs._wrapped
  }
}

// MARK: - NFTAsset + Hashable

extension NFTAsset: Hashable {
  public func hash(into hasher: inout Hasher) {
    hasher.combine(_wrapped)
  }
}

// MARK: - NFTAsset + ProtoWrapper

extension NFTAsset: ProtoWrapper {
  init(_ wrapped: _NFTAsset, chain: MDBXChain) {
    self._chain = chain
    self._wrapped = wrapped
    commonInit(chain: chain, key: nil)
  }
}

// MARK: - NFTAsset + CommonInit

extension NFTAsset {
  mutating func commonInit(chain: MDBXChain, key: Data?) {
    tryRestoreCollectionKey(key)
    
    // Wrappers
    __last_sale.chain = chain
    __last_sale.refreshProjected(wrapped: _wrapped.lastSale)
    
    __urls.chain = chain
    __urls.refreshProjected(wrapped: _wrapped.urls)
    
    __traits.chain = chain
    __traits.refreshProjected(wrapped: _wrapped.traits)
    
    if let tokenMeta = _wrapped._cleanLastSale(chain) {
      $_last_sale?._meta.updateData(tokenMeta.wrapped(chain), chain: chain)
    }
  }
}

