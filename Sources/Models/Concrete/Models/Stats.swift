//
//  Stats.swift
//  
//
//  Created by Sergey Kolokolnikov on 05.05.2022.
//

import Foundation
import SwiftProtobuf
import mdbx_ios

public struct Stats: Equatable {
  public weak var database: WalletDB?
  var _wrapped: _Stats
  var _chain: MDBXChain
    
  // MARK: - LifeCycle
    
  public init(chain: MDBXChain, count: String, owners: String, market: Market, database: WalletDB? = nil) {
    self.database = database ?? MEWwalletDBImpl.shared
    self._wrapped = .with {
      $0.count = count
      $0.owners = owners
      $0.market = market._wrapped
    }
    self._chain = chain
  }
}

// MARK: - Stats + Properties

extension Stats {

  // MARK: - Properties
  
  public var count: String { self._wrapped.count }
  public var owners: String { self._wrapped.owners }
}
