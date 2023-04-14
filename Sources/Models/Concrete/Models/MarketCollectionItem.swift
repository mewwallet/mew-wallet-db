//
//  File.swift
//  
//
//  Created by macbook on 1.02.2023.
//

import Foundation
import SwiftProtobuf

public struct MarketCollectionItem: Equatable {
  public weak var database: WalletDB? = MEWwalletDBImpl.shared
  var _wrapped: _MarketCollectionItem
  var _chain: MDBXChain

  @SubProperty<[_TokenMeta], [TokenMeta]> var _tokens: [_TokenMeta]?

  // MARK: - Lifecycle
  
  public init(
    chain: MDBXChain,
    actionLocalizationKey: String?,
    actionTitle: String?,
    actionURL: String?,
    bannerBig: String?,
    bannerSmall: String?,
    descriptionLocalizationKey: String?,
    descriptionText: String?,
    entryTitle: String?,
    rank: Int32,
    shortDescriptionLocalizationKey: String?,
    shortDescriptionText: String?,
    shortTitleLocalizationKey: String?,
    shortTitleText: String?,
    theme: String?,
    titleLocalizationKey: String?,
    titleText: String?,
    database: WalletDB? = nil
  ) {
    self.database = database ?? MEWwalletDBImpl.shared
    self._chain = chain
    self._wrapped = .with {
      $0.action = .with {
        $0.localizationKey = actionLocalizationKey ?? ""
        $0.text = actionTitle ?? ""
        $0.url = actionURL ?? ""
      }
      $0.banner = .with {
        $0.big = bannerBig ?? ""
        $0.small = bannerSmall ?? ""
      }
      
      $0.description_p = .with {
        $0.localizationKey = descriptionLocalizationKey ?? ""
        $0.text = descriptionText ?? ""
      }
      
      if let entryTitle {
        $0.entryTitle = entryTitle
      }
      $0.shortDescription = .with {
        $0.localizationKey = shortDescriptionLocalizationKey ?? ""
        $0.text = shortDescriptionText ?? ""
      }
      $0.shortTitle = .with {
        $0.localizationKey = shortTitleLocalizationKey ?? ""
        $0.text = shortTitleText ?? ""
      }
      $0.theme = theme ?? ""
      $0.title = .with {
        $0.localizationKey = titleLocalizationKey ?? ""
        $0.text = titleText ?? ""
      }
    }
    commonInit(chain: chain, key: nil)
  }
  
  init(database: WalletDB? = nil, _wrapped: _MarketCollectionItem, chain: MDBXChain) {
    self.database = database ?? MEWwalletDBImpl.shared
    self._wrapped = _wrapped
    self._chain = chain
    commonInit(chain: chain, key: nil)
  }
}

// MARK: - MarketCollectionItem + Equitable

public extension MarketCollectionItem {
  static func ==(lhs: MarketCollectionItem, rhs: MarketCollectionItem) -> Bool {
    return lhs._wrapped == rhs._wrapped
  }
}

extension MarketCollectionItem {
  var description: MarketCollectionTitle {
    return .init(
      database: database,
      _wrapped: _wrapped.description_p
    )
  }
  
  var shortDescription: MarketCollectionTitle {
    return .init(
      database: database,
      _wrapped: _wrapped.shortDescription
    )
  }
  
  var title: MarketCollectionTitle {
    return .init(
      database: database,
      _wrapped: _wrapped.title
    )
  }
  
  var shortTitle: MarketCollectionTitle {
    return .init(
      database: database,
      _wrapped: _wrapped.shortTitle
    )
  }
  
  var banner: MarketCollectionBanner {
    return .init(
      database: database,
      _wrapped: _wrapped.banner
    )
  }
  
  var action: MarketCollectionAction {
    return .init(
      database: database,
      _wrapped: _wrapped.action
    )
  }
  
  var filters: [MarketCollectionFilter] {
    return _wrapped.filters.map {
      MarketCollectionFilter(database: database, _wrapped: $0)
    }
  }
  
  var tokens: [TokenMeta] {
    guard !_wrapped.tokens.isEmpty else {
      return []
    }
    return $_tokens ?? []
  }
}

extension MarketCollectionItem: MDBXObject {
  public var serialized: Data {
    get throws {
      try _wrapped.serializedData()
    }
  }
  
  public var chain: MDBXChain { _chain }

  public var key: MDBXKey {
    assertionFailure("not implemented")
    return MarketCollectionItemKey(chain: .universal, index: 0)
  }
  
  public var alternateKey: MDBXKey? {
    nil
  }
  
  public init(serializedData data: Data, chain: MDBXChain, key: Data?) throws {
    self._wrapped = try _MarketCollectionItem(serializedData: data)
    self._chain = chain
    commonInit(chain: chain, key: key)
  }
  
  public init(jsonData: Data, chain: MDBXChain, key: Data?) throws {
    var options = JSONDecodingOptions()
    options.ignoreUnknownFields = true
    self._wrapped = try _MarketCollectionItem(jsonUTF8Data: jsonData, options: options)
    self._chain = chain
    commonInit(chain: chain, key: key)
  }
  
  public init(jsonString: String, chain: MDBXChain, key: Data?) throws {
    var options = JSONDecodingOptions()
    options.ignoreUnknownFields = true
    self._wrapped = try _MarketCollectionItem(jsonString: jsonString, options: options)
    self._chain = chain
    commonInit(chain: chain, key: key)
  }
  
  public mutating func merge(with object: MDBXObject) {
    guard let other = object as? MarketCollectionItem else {
      return
    }
    
    self._wrapped.title = other._wrapped.title
    self._wrapped.shortTitle = other._wrapped.shortTitle
    if other._wrapped.hasShortDescription {
      self._wrapped.shortDescription = other._wrapped.shortDescription
    }
    if other._wrapped.hasDescription_p {
      self._wrapped.description_p = other._wrapped.description_p
    }
    self._wrapped.action = other._wrapped.action
    self._wrapped.filters = other._wrapped.filters
    self._wrapped.banner = other._wrapped.banner
    self._wrapped.tokens = other._wrapped.tokens
  }
}

extension MarketCollectionItem {
  public static func array(fromJSONString string: String, chain: MDBXChain) throws -> [Self] {
    var options = JSONDecodingOptions()
    options.ignoreUnknownFields = true
    let objects = try _MarketCollectionItem.array(fromJSONString: string, options: options)
    return objects.lazy.map({
      MarketCollectionItem(_wrapped: $0, chain: chain)
    })
  }
  
  public static func array(fromJSONData data: Data, chain: MDBXChain) throws -> [Self] {
    var options = JSONDecodingOptions()
    options.ignoreUnknownFields = true
    let objects = try _MarketCollectionItem.array(fromJSONUTF8Data: data, options: options)
    return objects.lazy.map({
      MarketCollectionItem(_wrapped: $0, chain: chain)
    })
  }
}

// MARK: - MarketCollectionItem + CommonInit

private extension MarketCollectionItem {
  mutating func commonInit(chain: MDBXChain, key: Data?) {
    //tryRestoreCollectionKey(key) ??
    
    // Wrappers
    __tokens.chain = chain
    __tokens.wrappedValue = _wrapped.tokens
        
    self.populateDB()
  }
  
  func populateDB() {
    __tokens.database = database
  }
}
