//
//  File.swift
//  
//
//  Created by Nail Galiaskarov on 5/30/21.
//

import Foundation
import mdbx_ios

public enum MDBXProjectId: Data {
  case eth                = "0x00"
}

public enum MDBXTableName: String, CaseIterable {
  case price              = "Price_0"
  case dex                = "Dex_0"
  case orderedDex         = "OrderedDex_0"
  case tokenMeta          = "TokenMeta_0"
  case marketItem         = "Market_0"
  case rawTransaction     = "RawTransaction_0"
  case completedTransfer  = "CompletedTransfer_0"
  case pendingTransfer    = "PendingTransfer_0"
  case recipient          = "Recipient_0"
  case token              = "Token_0"
  case balance            = "Balance_0"
}

typealias MDBXTable = (name: MDBXTableName, db: MDBXDatabase)
