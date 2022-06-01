//
//  Floor.swift
//  
//
//  Created by Sergey Kolokolnikov on 05.05.2022.
//

import Foundation
import SwiftProtobuf
import mdbx_ios

public struct Floor: Equatable {
  public weak var database: WalletDB?
  var _wrapped: _Floor
  var _chain: MDBXChain
    
  // MARK: - LifeCycle
    
  public init(chain: MDBXChain, price: String, token: TokenMeta, database: WalletDB? = nil) {
    self.database = database ?? MEWwalletDBImpl.shared
    self._wrapped = .with {
      $0.price = price
      $0.token = token._wrapped
    }
    self._chain = chain
  }
}

// MARK: - Floor + Properties

extension Floor {

  // MARK: - Properties
  
  public var price: String { self._wrapped.price }
  //public var token: [_TokenMeta] { self._wrapped.token }
}

// MARK: - Floor + Equitable

public extension Floor {
  static func ==(lhs: Floor, rhs: Floor) -> Bool {
    return lhs._chain == rhs._chain
        && lhs._wrapped == rhs._wrapped
  }
}
