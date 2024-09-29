//
//  File.swift
//  
//
//  Created by Mikhail Nikanorov on 3/6/22.
//

import Foundation

private enum _MDBXChain: Data, Sendable {
  case invalid            = "0x00000000000000000000000000000000" // 0
  case eth                = "0x00000000000000000000000000000001" // 1
  case goerli             = "0x00000000000000000000000000000005" // 5
  case polygon_mainnet    = "0x00000000000000000000000000000089" // 137
  case polygon_mumbai     = "0x00000000000000000000000000013881" // 80001
  case zksync_v2_mainnet  = "0x00000000000000000000000000000144" // 324
  case zksync_v2_testnet  = "0x00000000000000000000000000000118" // 280
  case canto              = "0x00000000000000000000000000001e14" // 7700
  case bsc                = "0x00000000000000000000000000000038" // 56
  case base               = "0x00000000000000000000000000002105" // 8453
  
  var chain: MDBXChain {
    switch self {
    case .invalid:            return .invalid
    case .eth:                return .eth
    case .goerli:             return .goerli
    case .polygon_mainnet:    return .polygon_mainnet
    case .polygon_mumbai:     return .polygon_mumbai
    case .zksync_v2_mainnet:  return .zksync_v2_mainnet
    case .zksync_v2_testnet:  return .zksync_v2_testnet
    case .canto:              return .canto
    case .bsc:                return .bsc
    case .base:               return .base
    }
  }
}

public enum MDBXChain: CaseIterable, Sendable {
  public static let allCases: [MDBXChain] = [
    .eth,
    .goerli,
    .polygon_mainnet,
    .polygon_mumbai,
    .zksync_v2_mainnet,
    .zksync_v2_testnet,
    .canto,
    .bsc,
    .base
  ]
  
  case invalid
  /// Convenient `MDBXChain` == `.eth`
  case universal
  case eth
  case goerli
  case polygon_mainnet
  case polygon_mumbai
  case zksync_v2_mainnet
  case zksync_v2_testnet
  case canto
  case bsc
  case base
  case custom(Data)
  
  public var rawValue: Data {
    switch self {
    case .invalid:            return _MDBXChain.invalid.rawValue
    case .universal:          return _MDBXChain.eth.rawValue
    case .eth:                return _MDBXChain.eth.rawValue
    case .goerli:             return _MDBXChain.goerli.rawValue
    case .polygon_mainnet:    return _MDBXChain.polygon_mainnet.rawValue
    case .polygon_mumbai:     return _MDBXChain.polygon_mumbai.rawValue
    case .zksync_v2_mainnet:  return _MDBXChain.zksync_v2_mainnet.rawValue
    case .zksync_v2_testnet:  return _MDBXChain.zksync_v2_testnet.rawValue
    case .canto:              return _MDBXChain.canto.rawValue
    case .bsc:                return _MDBXChain.bsc.rawValue
    case .base:               return _MDBXChain.base.rawValue
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
  
  /// Uses to recover chain for HistoryPurchase
  /// - Parameter rawValue: raw chain name from API
  public init(rawValue: String) {
    switch rawValue.uppercased() {
    case "ETH":               self = .eth
    case "MATIC":             self = .polygon_mainnet
    case "POL":               self = .polygon_mainnet
    case "CANTO":             self = .canto
    case "BSC":               self = .bsc
    case "BASE":              self = .base
    case "ZKSYNC":            self = .zksync_v2_mainnet
    default:                  self = .eth
    }
  }
  
  public var name: String {
    switch self {
    case .eth:                return "Ethereum"
    case .goerli:             return "Goerli"
    case .polygon_mainnet:    return "Polygon"
    case .polygon_mumbai:     return "Polygon"
    case .zksync_v2_mainnet:  return "zkSync Era"
    case .zksync_v2_testnet:  return "Ethereum"
    case .canto:              return "CANTO"
    case .bsc:                return "BSC"
    case .base:               return "Base"
    default:    return ""
    }
  }
  
  public var symbol: String {
    switch self {
    case .eth:                return "ETH"
    case .goerli:             return "ETH"
    case .polygon_mainnet:    return "MATIC"
    case .polygon_mumbai:     return "MATIC"
    case .zksync_v2_mainnet:  return "ETH"
    case .zksync_v2_testnet:  return "ETH"
    case .canto:              return "CANTO"
    case .bsc:                return "BSC"
    case .base:               return "ETH"
    default:    return ""
    }
  }
  
  public var decimals: Int32 {
    switch self {
    case .eth:                return 18
    case .goerli:             return 18
    case .polygon_mainnet:    return 18
    case .polygon_mumbai:     return 18
    case .zksync_v2_mainnet:  return 18
    case .zksync_v2_testnet:  return 18
    case .canto:              return 18
    case .bsc:                return 18
    case .base:               return 18
    default:                  return 18
    }
  }
  
  public var primary: Address {
    switch self {
    case .zksync_v2_testnet:  return ._zktv2Primary
    case .zksync_v2_mainnet:  return ._zktv2Primary
    default:                  return ._primary
    }
  }
  
  public var isZKSync: Bool {
    let zkChains: [MDBXChain] = [.zksync_v2_testnet, .zksync_v2_mainnet]
    return zkChains.contains(self)
  }
  
  internal var hexString: String {
    switch self {
    case .invalid:            return "0x00000000000000000000000000000000" // 0
    case .eth:                return "0x00000000000000000000000000000001" // 1
    case .goerli:             return "0x00000000000000000000000000000005" // 5
    case .polygon_mainnet:    return "0x00000000000000000000000000000089" // 137
    case .polygon_mumbai:     return "0x00000000000000000000000000013881" // 80001
    case .zksync_v2_mainnet:  return "0x00000000000000000000000000000144" // 324
    case .zksync_v2_testnet:  return "0x00000000000000000000000000000118" // 280
    case .universal:          return "0x00000000000000000000000000000001" // 1
    case .canto:              return "0x00000000000000000000000000001e14" // 7700
    case .bsc:                return "0x00000000000000000000000000000038" // 56
    case .base:               return "0x00000000000000000000000000002105" // 8453
    case .custom(let chain):  return chain.hexString
    }
  }
}

extension MDBXChain: Equatable {}

extension MDBXChain: Hashable {}

extension MDBXChain: CustomDebugStringConvertible {
  public var debugDescription: String {
    self.rawValue.hexString
  }
}
