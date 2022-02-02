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
  var environment: MDBXEnvironment!
  
  internal var tables: [MDBXTable : MDBXDatabase] = [:]
  
  internal let writeWorker: BackgroundWorker = .init()
  internal var writeTransaction: MDBXTransaction!
  
  internal let readWorker: BackgroundWorker = .init()
  internal var readTransaction: MDBXTransaction!
  
  internal let encoder: JSONEncoder
  internal let decoder: JSONDecoder
  
  public init(encoder: JSONEncoder, decoder: JSONDecoder) {
    self.encoder = encoder
    self.decoder = decoder
    writeWorker.name = "writer"
    readWorker.name = "reader"
  }
  
  deinit {
    stop()
  }
}
