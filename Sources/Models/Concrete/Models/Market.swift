//
//  Market.swift
//  
//
//  Created by Sergey Kolokolnikov on 05.05.2022.
//

import Foundation
import SwiftProtobuf
import mdbx_ios

public struct Market: Equatable {
  public weak var database: WalletDB?
  var _wrapped: _Market
  var _chain: MDBXChain
    
  // MARK: - LifeCycle
    
  public init(chain: MDBXChain, floor: Floor, database: WalletDB? = nil) {
    self.database = database ?? MEWwalletDBImpl.shared
    self._wrapped = .with {
      $0.floor = floor._wrapped
    }
    self._chain = chain
  }
}

// MARK: - Market + Properties

extension Market {

  // MARK: - Properties
  
  //public var floor: Floor { self._wrapped.floor }
}

// MARK: - Market + Equitable

public extension Market {
  static func ==(lhs: Market, rhs: Market) -> Bool {
    return lhs._chain == rhs._chain
        && lhs._wrapped == rhs._wrapped
  }
}
