//
//  File.swift
//  
//
//  Created by Nail Galiaskarov on 5/30/21.
//

import Foundation
import mdbx_ios

public enum MDBXTableName: String, CaseIterable {
  case dex                = "Dex_0"
  case orderedDex         = "OrderedDex_0"
  case tokenMeta          = "TokenMeta_0"
  case token              = "Token_0"
  case rawTransaction     = "RawTransaction_0"
  case dappRecord         = "DAppRecord_0"
  case dappRecordRecent   = "DAppRecordRecent_0"
  case dappRecordFavorite = "DAppRecordFavorite_0"
  case nftCollection      = "nftCollection_0"
  case asset              = "asset_0"
}

typealias MDBXTable = (name: MDBXTableName, db: MDBXDatabase)
