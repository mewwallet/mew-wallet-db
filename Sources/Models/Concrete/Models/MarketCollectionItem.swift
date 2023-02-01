//
//  File.swift
//  
//
//  Created by macbook on 1.02.2023.
//

import Foundation

public struct MarketCollectionItem: Equatable {
  public weak var database: WalletDB? = MEWwalletDBImpl.shared
  var _wrapped: _MarketCollectionItem
  var _chain: MDBXChain

  // MARK: - Lifecycle
  
  public init(
    chain: String,
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
    theme: Int32,
    titleLocalizationKey: String?,
    titleText: String?,
    database: WalletDB? = nil
  ) {
    self.database = database ?? MEWwalletDBImpl.shared
    self._chain = .init(rawValue: chain)
    
    self._wrapped = .with {
      $0.chain = chain
      if let actionLocalizationKey {
        $0.actionLocalizationKey = actionLocalizationKey
      }
      if let actionTitle {
        $0.actionTitle = actionTitle
      }
      if let actionURL {
        $0.actionURL = actionURL
      }
      if let bannerBig {
        $0.bannerBig = bannerBig
      }
      if let bannerSmall {
        $0.bannerSmall = bannerSmall
      }
      if let descriptionLocalizationKey {
        $0.descriptionLocalizationKey = descriptionLocalizationKey
      }
      if let descriptionText {
        $0.descriptionText = descriptionText
      }
      if let entryTitle {
        $0.entryTitle = entryTitle
      }
      $0.rank = rank
      if let shortDescriptionLocalizationKey {
        $0.shortDescriptionLocalizationKey = shortDescriptionLocalizationKey
      }
      if let shortDescriptionText {
        $0.shortDescriptionText = shortDescriptionText
      }
      if let shortTitleLocalizationKey {
        $0.shortTitleLocalizationKey = shortTitleLocalizationKey
      }
      if let shortTitleText {
        $0.shortTitleText = shortTitleText
      }
      $0.theme = theme
      if let titleLocalizationKey {
        $0.titleLocalizationKey = titleLocalizationKey
      }
      if let titleText {
        $0.titleText = titleText
      }
    }
  }
}

// MARK: - MarketCollectionItem + Equitable

public extension MarketCollectionItem {
  static func ==(lhs: MarketCollectionItem, rhs: MarketCollectionItem) -> Bool {
    return lhs._chain == rhs._chain &&
           lhs._wrapped == rhs._wrapped
  }
}
