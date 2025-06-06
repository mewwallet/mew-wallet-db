//
//  File.swift
//  mew-wallet-db
//
//  Created by Mikhail Nikanorov on 3/28/25.
//

import Foundation

public enum NetworkType: Int, CaseIterable, Sendable, Equatable {
  case evm              = 0
  case bitcoin          = 1
  
  public var chain: MDBXChain {
    switch self {
    case .evm:               return .evm
    case .bitcoin:           return .bitcoin
    }
  }
  
  init(_ network: _NetworkType) {
    switch network {
    case .evm:               self = .evm
    case .bitcoin:           self = .bitcoin
    case .UNRECOGNIZED:      self = .evm
    }
  }
  
  init(_ address: Address) {
    if address.isBitcoinNetwork {
      self = .bitcoin
    } else {
      self = .evm
    }
  }
}
