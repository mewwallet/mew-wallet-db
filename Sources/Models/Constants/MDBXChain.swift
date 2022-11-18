//
//  File.swift
//  
//
//  Created by Mikhail Nikanorov on 3/6/22.
//

import Foundation

private enum _MDBXChain: Data {
  case invalid       = "0x00000000000000000000000000000000"
  case eth           = "0x00000000000000000000000000000001"
  
  var chain: MDBXChain {
    switch self {
    case .invalid:    return .invalid
    case .eth:        return .eth
    }
  }
}

public enum MDBXChain {
  case invalid
  case eth
  case custom(Data)
  
  public var rawValue: Data {
    switch self {
    case .invalid:          return _MDBXChain.invalid.rawValue
    case .eth:              return _MDBXChain.eth.rawValue
    case .custom(let data): return data
    }
  }
  
  public init(rawValue: Data) {
    let data = rawValue.setLengthLeft(MDBXKeyLength.chain)
    guard let chain = _MDBXChain(rawValue: data) else {
      self = .custom(data)
      return
    }
    self = chain.chain
  }
  
  var name: String {
    switch self {
    case .eth:  return "Ethereum"
    default:    return ""
    }
  }
  
  var symbol: String {
    switch self {
    case .eth:  return "ETH"
    default:    return ""
    }
  }
  
  var decimals: Int32 {
    switch self {
    case .eth:  return 18
    default:    return 18
    }
  }
}

extension MDBXChain: Equatable {}

extension MDBXChain: @unchecked Sendable {}

extension MDBXChain: CustomDebugStringConvertible {
  public var debugDescription: String {
    self.rawValue.hexString
  }
}
