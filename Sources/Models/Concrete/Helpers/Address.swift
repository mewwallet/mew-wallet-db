//
//  File.swift
//  
//
//  Created by Mikhail Nikanorov on 6/8/22.
//

import Foundation

public enum Address: RawRepresentable, Equatable {
  public typealias RawValue = String
  
  case primary    // "0xeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee"
  case starkChain // "0x1edc9ba729ef6fb017ef9c687b1a37d48b6a166c"
  case renBTC     // "0xeb4c2781e4eba804ce9a9803c67d0893436bb27d"
  case skale      // "0x00c83aecc790e8a4453e5dd3b0b4b3680501a7a7"
  case stEth      // "0xae7ab96520de3a18e5e111b5eaab095312d7fe84"
  case wBTC       // "0x2260fac5e5542a773aa44fbcfedf7c193bc2c599"
  case unknown(String)
  case invalid(String)
  
  public var isStarkChain: Bool      { self == .starkChain }
  public var isRenBTC: Bool          { self == .renBTC }
  public var isSkale: Bool           { self == .skale }
  public var isStEth: Bool           { self == .stEth }
  public var isPrimary: Bool         { self == .primary }
  public var isWBTC: Bool            { self == .wBTC }
  
  public var isWrappedBitcoin: Bool  { self.isRenBTC || self.isWBTC }
  
  init() {
    self = .primary
  }
  
  public init(rawValue: String) {
    let rawValue = rawValue.stringAddHexPrefix().lowercased()
    switch rawValue {
    case "0xeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee": self = .primary
    case "0x1edc9ba729ef6fb017ef9c687b1a37d48b6a166c": self = .starkChain
    case "0xeb4c2781e4eba804ce9a9803c67d0893436bb27d": self = .renBTC
    case "0x00c83aecc790e8a4453e5dd3b0b4b3680501a7a7": self = .skale
    case "0xae7ab96520de3a18e5e111b5eaab095312d7fe84": self = .stEth
    case "0x2260fac5e5542a773aa44fbcfedf7c193bc2c599": self = .wBTC
    case _ where rawValue.count == 42:                 self = .unknown(rawValue)
    default:                                           self = .invalid(rawValue)
    }
  }
  
  public var rawValue: String {
    switch self {
    case .primary:                                    return "0xeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee"
    case .starkChain:                                 return "0x1edc9ba729ef6fb017ef9c687b1a37d48b6a166c"
    case .renBTC:                                     return "0xeb4c2781e4eba804ce9a9803c67d0893436bb27d"
    case .skale:                                      return "0x00c83aecc790e8a4453e5dd3b0b4b3680501a7a7"
    case .stEth:                                      return "0xae7ab96520de3a18e5e111b5eaab095312d7fe84"
    case .wBTC:                                       return "0x2260fac5e5542a773aa44fbcfedf7c193bc2c599"
    case .unknown(let address):                       return address
    case .invalid(let address):                       return address
    }
  }
}

extension Address: ExpressibleByStringLiteral {
  public init(stringLiteral value: StringLiteralType) {
    self.init(rawValue: value)
  }
}
