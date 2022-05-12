//
//  URLType.swift
//  
//
//  Created by Sergey Kolokolnikov on 05.05.2022.
//

import Foundation
import SwiftProtobuf
import mdbx_ios

public struct URLType: Equatable {
  public weak var database: WalletDB?
  var _wrapped: _URLType
  var _chain: MDBXChain
    
  // MARK: - LifeCycle
    
  public init(chain: MDBXChain, type: String, url: String, database: WalletDB? = nil) {
    self.database = database ?? MEWwalletDBImpl.shared
    self._wrapped = .with {
      $0.type = type
      $0.url = url
    }
    self._chain = chain
  }
}

// MARK: - URLType + Properties

extension URLType {

  // MARK: - Properties
  
  public var type: String { self._wrapped.type }
  public var url: String { self._wrapped.url }
}
