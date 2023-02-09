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

  // MARK: - Lifecycle
  
  public init(
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
  }
}

// MARK: - MarketCollectionItem + Equitable

public extension MarketCollectionItem {
  static func ==(lhs: MarketCollectionItem, rhs: MarketCollectionItem) -> Bool {
    return lhs._wrapped == rhs._wrapped
  }
}
