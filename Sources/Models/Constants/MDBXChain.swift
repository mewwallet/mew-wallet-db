//
//  File.swift
//  
//
//  Created by Mikhail Nikanorov on 3/6/22.
//

import Foundation

private enum _MDBXChain: Data {
  case eth           = "0x00000000000000000000000000000001"
  
  var chain: MDBXChain {
    switch self {
    case .eth: return .eth
    }
  }
}

public enum MDBXChain {
  case eth
  case custom(Data)
  
  var rawValue: Data {
    switch self {
    case .eth:              return _MDBXChain.eth.rawValue
    case .custom(let data): return data
    }
  }
  
  init(rawValue: Data) {
    let data = rawValue.setLengthLeft(MDBXKeyLength.chain)
    guard let chain = _MDBXChain(rawValue: data) else {
      self = .custom(data)
      return
    }
    self = chain.chain
  }
}

extension MDBXChain: Equatable {}
