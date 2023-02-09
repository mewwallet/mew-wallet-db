//
//  File.swift
//  
//
//  Created by Mikhail Nikanorov on 6/8/22.
//

import Foundation

public enum Address: RawRepresentable, Equatable {
  public typealias RawValue = String
  case _primary             // "0xeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee"
  case _zktv2Primary        // "0x0000000000000000000000000000000000000000"
  
  case starkChain           // "0x1edc9ba729ef6fb017ef9c687b1a37d48b6a166c"
  case renBTC               // "0xeb4c2781e4eba804ce9a9803c67d0893436bb27d"
  case skale                // "0x00c83aecc790e8a4453e5dd3b0b4b3680501a7a7"
  case stEth                // "0xae7ab96520de3a18e5e111b5eaab095312d7fe84"
  case wBTC                 // "0x2260fac5e5542a773aa44fbcfedf7c193bc2c599"
  case usdc                 // "0xa0b86991c6218b36c1d19d4a2e9eb0ce3606eb48"
  case matic                // "0x7d1afa7b718fb893db30a3abc0cfc608aacfebb0"
  
  case zktv2BuidlPaymaster  // "0x7F904e350F27aF4D4A70994AE1f3bBC1dAfEe665"
  case zktv2Buidl           // "0xf551954D449eA3Ae4D6A2656a42d9B9081B137b4"
  
  case unknown(String)
  case invalid(String)
  
  public var isStarkChain: Bool      { self == .starkChain }
  public var isRenBTC: Bool          { self == .renBTC }
  public var isSkale: Bool           { self == .skale }
  public var isStEth: Bool           { self == .stEth }
  public var isPrimary: Bool         { self == ._primary || self == ._zktv2Primary }
  public var isWBTC: Bool            { self == .wBTC }
  public var isZK2Buidl: Bool        { self == .zktv2Buidl }
  
  public var isWrappedBitcoin: Bool  { self.isRenBTC || self.isWBTC }
  
  public init(_ rawValue: String) {
    self.init(rawValue: rawValue)
  }
  
  public init(rawValue: String) {
    let rawValue = rawValue.stringAddHexPrefix().lowercased()
    switch rawValue {
    case "0xeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee": self = ._primary
    case "0x0000000000000000000000000000000000000000": self = ._zktv2Primary
    
    case "0x1edc9ba729ef6fb017ef9c687b1a37d48b6a166c": self = .starkChain
    case "0xeb4c2781e4eba804ce9a9803c67d0893436bb27d": self = .renBTC
    case "0x00c83aecc790e8a4453e5dd3b0b4b3680501a7a7": self = .skale
    case "0xae7ab96520de3a18e5e111b5eaab095312d7fe84": self = .stEth
    case "0x2260fac5e5542a773aa44fbcfedf7c193bc2c599": self = .wBTC
    case "0xa0b86991c6218b36c1d19d4a2e9eb0ce3606eb48": self = .usdc
    case "0x7d1afa7b718fb893db30a3abc0cfc608aacfebb0": self = .matic
      
    case "0xf551954D449eA3Ae4D6A2656a42d9B9081B137b4": self = .zktv2Buidl
    case "0x7F904e350F27aF4D4A70994AE1f3bBC1dAfEe665": self = .zktv2BuidlPaymaster
    case _ where rawValue.count == 42:                 self = .unknown(rawValue)
    default:                                           self = .invalid(rawValue)
    }
  }
  
  public var rawValue: String {
    switch self {
    case ._primary:                                   return "0xeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee"
    case ._zktv2Primary:                              return "0x0000000000000000000000000000000000000000"
      
    case .starkChain:                                 return "0x1edc9ba729ef6fb017ef9c687b1a37d48b6a166c"
    case .renBTC:                                     return "0xeb4c2781e4eba804ce9a9803c67d0893436bb27d"
    case .skale:                                      return "0x00c83aecc790e8a4453e5dd3b0b4b3680501a7a7"
    case .stEth:                                      return "0xae7ab96520de3a18e5e111b5eaab095312d7fe84"
    case .wBTC:                                       return "0x2260fac5e5542a773aa44fbcfedf7c193bc2c599"
    case .usdc:                                       return "0xa0b86991c6218b36c1d19d4a2e9eb0ce3606eb48"
    case .matic:                                      return "0x7d1afa7b718fb893db30a3abc0cfc608aacfebb0"
      
    case .zktv2Buidl:                                 return "0xf551954D449eA3Ae4D6A2656a42d9B9081B137b4"
    case .zktv2BuidlPaymaster:                        return "0x7F904e350F27aF4D4A70994AE1f3bBC1dAfEe665"
      
    case .unknown(let address):                       return address.lowercased()
    case .invalid(let address):                       return address.lowercased()
    }
  }
}

extension Address: ExpressibleByStringLiteral {
  public init(stringLiteral value: StringLiteralType) {
    self.init(rawValue: value)
  }
}

extension Address: Comparable {
  public static func ==(lhs: Address, rhs: Address) -> Bool {
    return lhs.rawValue.lowercased() == rhs.rawValue.lowercased()
  }
  
  public static func ==(lhs: Address, rhs: String) -> Bool {
    return lhs == .unknown(rhs)
  }
  
  public static func ==(lhs: String, rhs: Address) -> Bool {
    return .unknown(lhs) == rhs
  }
}

extension Address: Hashable {}
