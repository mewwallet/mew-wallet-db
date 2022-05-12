//
//  Social.swift
//  
//
//  Created by Sergey Kolokolnikov on 03.05.2022.
//

import Foundation
import SwiftProtobuf
import mdbx_ios

public struct Social: Equatable {
  public weak var database: WalletDB?
  var _wrapped: _Social
  var _chain: MDBXChain
    
  // MARK: - LifeCycle
    
  public init(chain: MDBXChain, website: String, discord: String, database: WalletDB? = nil) {
    self.database = database ?? MEWwalletDBImpl.shared
    self._wrapped = .with {
      $0.website = website
      $0.discord = discord
    }
    self._chain = chain
  }
}

// MARK: - Social + Properties

extension Social {

  // MARK: - Properties
  
  public var website: String { self._wrapped.website }
  public var discord: String { self._wrapped.discord }
}

// MARK: - Social + Equitable

public extension Social {
  static func ==(lhs: Social, rhs: Social) -> Bool {
    return lhs._chain == rhs._chain
        && lhs._wrapped == rhs._wrapped
  }
}
