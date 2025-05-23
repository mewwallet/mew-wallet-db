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
  case arbitrum           = "0x0000000000000000000000000000A4B1" // 42161
  case optimism           = "0x0000000000000000000000000000000A" // 10
  case bitcoin            = "0x00000000000000000000bcbcbcbcbcbc" // 207518806359228 fake chain id, since real one is 0x000000000019d6689c085ae165831e934ff763ae46a2a6c172b3f1b60a8ce26f and too big for type (219091820017965452120151157118720403)
  
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
    case .arbitrum:           return .arbitrum
    case .optimism:           return .optimism
    case .bitcoin:            return .bitcoin
    }
  }
  
  var networkChain: MDBXChain {
    switch self {
    case .bitcoin:            return .bitcoin
    default:                  return .evm
    }
  }
}

public enum MDBXChain: CaseIterable, Sendable {
  fileprivate static let _chainsMap: [UInt64: MDBXChain] = [
    1:      .eth,
    5:      .goerli,
    137:    .polygon_mainnet,
    80001:  .polygon_mumbai,
    324:    .zksync_v2_mainnet,
    280:    .zksync_v2_testnet,
    7700:   .canto,
    56:     .bsc,
    8453:   .base,
    42161:  .arbitrum,
    10:     .optimism,
    207518806359228: .bitcoin
  ]
  
  @available(*, deprecated, renamed: "evmCases", message: "No longer supported")
  public static let allCases: [MDBXChain] = []
  
  public static let evmCases: [MDBXChain] = [
    .eth,
    .goerli,
    .polygon_mainnet,
    .polygon_mumbai,
    .zksync_v2_mainnet,
    .zksync_v2_testnet,
    .canto,
    .bsc,
    .base,
    .arbitrum,
    .optimism
  ]
  
  public static let bitcoinCases: [MDBXChain] = [
    .bitcoin
  ]
  
  case invalid
  /// Convenient `MDBXChain` == `.eth`
  case evm
  case eth
  case goerli
  case polygon_mainnet
  case polygon_mumbai
  case zksync_v2_mainnet
  case zksync_v2_testnet
  case canto
  case bsc
  case base
  case arbitrum
  case optimism
  case bitcoin
  case custom(Data)
  
  public var value: UInt64 {
    switch self {
    case .evm:                        return 1
    case .invalid:                    return 0
    case .eth:                        return 1
    case .goerli:                     return 5
    case .polygon_mainnet:            return 137
    case .polygon_mumbai:             return 80001
    case .zksync_v2_mainnet:          return 324
    case .zksync_v2_testnet:          return 280
    case .canto:                      return 7700
    case .bsc:                        return 56
    case .base:                       return 8453
    case .arbitrum:                   return 42161
    case .optimism:                   return 10
    case .bitcoin:                    return 207518806359228
    case .custom(let data):           return data.withUnsafeBytes { $0.load(as: UInt64.self) }
    }
  }
  
  public var rawValue: Data {
    switch self {
    case .invalid:            return _MDBXChain.invalid.rawValue
    case .evm:                return _MDBXChain.eth.rawValue
    case .eth:                return _MDBXChain.eth.rawValue
    case .goerli:             return _MDBXChain.goerli.rawValue
    case .polygon_mainnet:    return _MDBXChain.polygon_mainnet.rawValue
    case .polygon_mumbai:     return _MDBXChain.polygon_mumbai.rawValue
    case .zksync_v2_mainnet:  return _MDBXChain.zksync_v2_mainnet.rawValue
    case .zksync_v2_testnet:  return _MDBXChain.zksync_v2_testnet.rawValue
    case .canto:              return _MDBXChain.canto.rawValue
    case .bsc:                return _MDBXChain.bsc.rawValue
    case .base:               return _MDBXChain.base.rawValue
    case .arbitrum:           return _MDBXChain.arbitrum.rawValue
    case .optimism:           return _MDBXChain.optimism.rawValue
    case .bitcoin:            return _MDBXChain.bitcoin.rawValue
    case .custom(let data): return data
    }
  }
  
  public init(networkRawValue: Data) {
    let data = networkRawValue.setLengthLeft(MDBXKeyLength.chain)
    guard let chain = _MDBXChain(rawValue: data) else {
      self = .custom(data)
      return
    }
    self = chain.networkChain
  }
  
  public init(rawValue: Data) {
    let data = rawValue.setLengthLeft(MDBXKeyLength.chain)
    guard let chain = _MDBXChain(rawValue: data) else {
      self = .custom(data)
      return
    }
    self = chain.chain
  }
  
  public init(rawValue: UInt64) {
    if let chain = Self._chainsMap[rawValue] {
      self = chain
      return
    }
    let data = withUnsafeBytes(of: rawValue) { Data($0) }
    self.init(rawValue: data)
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
    case "ZKSYNC_MAINNET":    self = .zksync_v2_mainnet
    case "ARB":               self = .arbitrum
    case "OP":                self = .optimism
    case "BTC":               self = .bitcoin
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
    case .arbitrum:           return "Arbitrum"
    case .optimism:           return "Optimism"
    case .bitcoin:            return "Bitcoin"
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
    case .arbitrum:           return "ETH"
    case .optimism:           return "ETH"
    case .bitcoin:            return "BTC"
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
    case .arbitrum:           return 18
    case .optimism:           return 18
    case .bitcoin:            return 8
    default:                  return 18
    }
  }
  
  public var primary: Address {
    return ._primary
  }
  
  public var isZKSync: Bool {
    let zkChains: [MDBXChain] = [.zksync_v2_testnet, .zksync_v2_mainnet]
    return zkChains.contains(self)
  }
  
  public var isBitcoinNetwork: Bool {
    return self == .bitcoin
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
    case .evm:                return "0x00000000000000000000000000000001" // 1
    case .canto:              return "0x00000000000000000000000000001e14" // 7700
    case .bsc:                return "0x00000000000000000000000000000038" // 56
    case .base:               return "0x00000000000000000000000000002105" // 8453
    case .arbitrum:           return "0x0000000000000000000000000000A4B1" // 42161
    case .optimism:           return "0x0000000000000000000000000000000A" // 10
    case .bitcoin:            return "0x00000000000000000000bcbcbcbcbcbc" // 207518806359228 fake chain id, since real one is 0x000000000019d6689c085ae165831e934ff763ae46a2a6c172b3f1b60a8ce26f and too big for type (219091820017965452120151157118720403)
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

extension MDBXChain: MDBXKeyComponent {
  public init(encodedData: Data) {
    self.init(rawValue: encodedData)
  }
  
  public var encodedData: Data {
    self.rawValue.setLengthLeft(MDBXKeyLength.chain)
  }
}
