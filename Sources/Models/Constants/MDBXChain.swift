//
//  File.swift
//  
//
//  Created by Mikhail Nikanorov on 3/6/22.
//

import Foundation

private enum _MDBXChain: Data {
  case invalid            = "0x00000000000000000000000000000000" // 0
  case eth                = "0x00000000000000000000000000000001" // 1
  case polygon_mainnet    = "0x00000000000000000000000000000089" // 137
  case polygon_mumbai     = "0x00000000000000000000000000013881" // 80001
  case zksync_v2_mainnet  = "0x00000000000000000000000000000144" // 324
  case zksync_v2_testnet  = "0x00000000000000000000000000000118" // 280
  
  var chain: MDBXChain {
    switch self {
    case .invalid:            return .invalid
    case .eth:                return .eth
    case .polygon_mainnet:    return .polygon_mainnet
    case .polygon_mumbai:     return .polygon_mumbai
    case .zksync_v2_mainnet:  return .zksync_v2_mainnet
    case .zksync_v2_testnet:  return .zksync_v2_testnet
    }
  }
}

public enum MDBXChain: CaseIterable {
  public static var allCases: [MDBXChain] = [
    .eth,
    .polygon_mainnet,
    .polygon_mumbai,
    .zksync_v2_mainnet,
    .zksync_v2_testnet
  ]
  
  // MARK: - MDBXChain + Supported

  public static var supported: [MDBXChain] = [
    .eth,
    .polygon_mainnet
  ]
  
  case invalid
  /// Convenient `MDBXChain` == `.eth`
  case universal
  case eth
  case polygon_mainnet
  case polygon_mumbai
  case zksync_v2_mainnet
  case zksync_v2_testnet
  case custom(Data)
  
  public var rawValue: Data {
    switch self {
    case .invalid:            return _MDBXChain.invalid.rawValue
    case .universal:          return _MDBXChain.eth.rawValue
    case .eth:                return _MDBXChain.eth.rawValue
    case .polygon_mainnet:    return _MDBXChain.polygon_mainnet.rawValue
    case .polygon_mumbai:     return _MDBXChain.polygon_mumbai.rawValue
    case .zksync_v2_mainnet:  return _MDBXChain.zksync_v2_mainnet.rawValue
    case .zksync_v2_testnet:  return _MDBXChain.zksync_v2_testnet.rawValue
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
  
  public var name: String {
    switch self {
    case .eth:                return "Ethereum"
    case .polygon_mainnet:    return "Polygon"
    case .polygon_mumbai:     return "Polygon - Mumbai"
    case .zksync_v2_mainnet:  return "zkSync mainnet"
    case .zksync_v2_testnet:  return "zkSync alpha testnet"
    default:    return ""
    }
  }
  
  public var symbol: String {
    switch self {
    case .eth:                return "ETH"
    case .polygon_mainnet:    return "MATIC"
    case .polygon_mumbai:     return "MATIC"
    case .zksync_v2_mainnet:  return "ETH"
    case .zksync_v2_testnet:  return "ETH"
    default:    return ""
    }
  }
  
  public var decimals: Int32 {
    switch self {
    case .eth:                return 18
    case .polygon_mainnet:    return 18
    case .polygon_mumbai:     return 18
    case .zksync_v2_mainnet:  return 18
    case .zksync_v2_testnet:  return 18
    default:                  return 18
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
