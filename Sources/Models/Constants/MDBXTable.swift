//
//  File.swift
//  
//
//  Created by Nail Galiaskarov on 5/30/21.
//

import Foundation
@preconcurrency import mdbx_ios

public enum MDBXTableName: String, CaseIterable, Sendable {
  case account                = "Account_0"
  case dex                    = "Dex_0"
  case orderedDex             = "OrderedDex_0"
  case featuredDex            = "FeaturedDex_0"
  case crossChainDex          = "CrossChainDex_0"
  case tokenMeta              = "TokenMeta_0"
  case token                  = "Token_0"
  case rawTransaction         = "RawTransaction_0"
  case rawBTCTransaction      = "RawBTCTransaction_0"
  case rawSOLTransaction      = "RawSOLTransaction_0"
  case dappLists              = "DAppLists_0"
  case dappRecord             = "DAppRecord_1"
  case dappRecordRecent       = "DAppRecordRecent_1"
  case dappRecordFavorite     = "DAppRecordFavorite_1"
  case dappRecordMeta         = "DAppRecordMeta_1"
  case dappRecordHistory      = "DAppRecordHistory_1"
  case nftCollection          = "nftCollection_1"
  case nftAsset               = "nftAsset_0"
  case transfer               = "Transfer_1"
  case historySwap            = "HistorySwap_0"
  case historyPurchase        = "HistoryPurchase_0"
  case profile                = "Profile_0"
  case staked                 = "Staked_0"
  case energyReceipts         = "EnergyReceipts_0"
  case purchaseProviders      = "PurchaseProviders_0"
  case purchaseTokens         = "PurchaseTokens_0"
  case purchaseOrderedTokens  = "PurchaseOrderedTokens_0"
}

typealias MDBXTable = (name: MDBXTableName, db: MDBXDatabase)
