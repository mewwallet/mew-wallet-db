//
//  File.swift
//  
//
//  Created by Nail Galiaskarov on 5/10/21.
//

import Foundation
import mdbx_ios

public final class MEWwalletDBImpl: WalletDB {
  static weak var shared: MEWwalletDBImpl!
  
  internal var environment: MDBXEnvironment!
  internal var tables: [MDBXTableName: MDBXDatabase] = [:]
  internal var writer: Writer!
  
  public init() {
    MEWwalletDBImpl.shared = self
  }
  
  deinit {
    stop()
  }
}
