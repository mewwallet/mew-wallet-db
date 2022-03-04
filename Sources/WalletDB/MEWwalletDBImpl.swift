//
//  File.swift
//  
//
//  Created by Nail Galiaskarov on 5/10/21.
//

import Foundation
import mdbx_ios

public enum MDBXWriteAction {
  case `break`
  case abort
  case commit
  case none
}

public final class MEWwalletDBImpl: WalletDB {
  internal var environment: MDBXEnvironment!
  internal var tables: [MDBXTableName: MDBXDatabase] = [:]
  internal var writer: Writer!
  
  internal let encoder: JSONEncoder
  internal let decoder: JSONDecoder
  
  public init(encoder: JSONEncoder, decoder: JSONDecoder) {
    self.encoder = encoder
    self.decoder = decoder
  }
  
  deinit {
    stop()
  }
}
