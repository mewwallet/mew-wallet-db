//
//  File.swift
//  
//
//  Created by Mikhail Nikanorov on 6/8/22.
//

import Foundation

public enum Address: RawRepresentable, Equatable, Sendable {
  public typealias RawValue = String
  
  public enum AddressType: RawRepresentable, Equatable, Sendable {
    public init?(rawValue: UInt8) {
      switch rawValue {
      case 1: self = .evm
      case 2: self = .bitcoin(.legacy)
      case 3: self = .bitcoin(.segwit)
      case 4: self = .bitcoin(.taproot)
      default: self = .unknown
      }
    }
    
    public var rawValue: UInt8 {
      switch self {
      case .evm:  return 1
      case .bitcoin(let bitcoin):
        switch bitcoin {
        case .legacy:    return 2
        case .segwit:    return 3
        case .taproot:   return 4
        }
      default:
        return 0
      }
    }
    
    public typealias RawValue = UInt8
    
    public enum Bitcoin: Equatable, Sendable {
      case legacy
      case segwit
      case taproot
    }
    case evm
    case bitcoin(Bitcoin)
    case unknown
  }
  
  case _primary             // "0xeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee"
  
  case starkChain           // "0x1edc9ba729ef6fb017ef9c687b1a37d48b6a166c"
  case renBTC               // "0xeb4c2781e4eba804ce9a9803c67d0893436bb27d"
  case skale                // "0x00c83aecc790e8a4453e5dd3b0b4b3680501a7a7"
  case stEth                // "0xae7ab96520de3a18e5e111b5eaab095312d7fe84"
  case wBTC                 // "0x2260fac5e5542a773aa44fbcfedf7c193bc2c599"
  case usdc                 // "0xa0b86991c6218b36c1d19d4a2e9eb0ce3606eb48"
  case matic                // "0x7d1afa7b718fb893db30a3abc0cfc608aacfebb0"
  
  case mewUniverse          // "0xeeeeeece1b4d9c1bd876b3e7fbe1871947c705cd"
  
  case _zktv2BuidlPaymaster  // "0x7F904e350F27aF4D4A70994AE1f3bBC1dAfEe665"
  case _zktv2Buidl           // "0xf551954D449eA3Ae4D6A2656a42d9B9081B137b4"
  
  case _zkv2BuidlPaymaster   // "0xfc5b07a5dd1b80cf271d35642f75cc0500ff1e2c"
  case _zkv2Buidl            // "0x1bba25233556a7c3b41913f35a035916dbed1664"
  
  public static func buidl(for chain: MDBXChain) -> Address {
    switch chain {
    case .zksync_v2_testnet:    return ._zktv2Buidl
    case .zksync_v2_mainnet:    return ._zkv2Buidl
    default:                    return ._zkv2Buidl
    }
  }
  
  public static func buidlPaymaster(for chain: MDBXChain) -> Address {
    switch chain {
    case .zksync_v2_testnet:    return ._zktv2BuidlPaymaster
    case .zksync_v2_mainnet:    return ._zkv2BuidlPaymaster
    default:                    return ._zkv2BuidlPaymaster
    }
  }
  
  case unknown(AddressType, String)
  case invalid(String)
  
  public var isStarkChain: Bool      { self == .starkChain }
  public var isRenBTC: Bool          { self == .renBTC }
  public var isSkale: Bool           { self == .skale }
  public var isStEth: Bool           { self == .stEth }
  public var isPrimary: Bool         { self == ._primary }
  public var isWBTC: Bool            { self == .wBTC }
  public var isZK2Buidl: Bool        { self == ._zktv2Buidl || self == ._zkv2Buidl }
  public var isMEWUniverse: Bool     { self == .mewUniverse }
  
  public var isWrappedBitcoin: Bool  { self.isRenBTC || self.isWBTC }
  
  public var isBitcoinNetwork: Bool  {
    guard case .bitcoin = addressType else {
      return false
    }
    return true
  }
  
  public var addressType: AddressType {
    switch self {
    case .unknown(let type, _):   return type
    case .invalid:                return .unknown
    default:                      return .evm
    }
  }
  
  public init(_ rawValue: String) {
    self.init(rawValue: rawValue)
  }
  
  public init(rawValue: String) {
    let value: String
    let isHex = rawValue.isHex()
    if isHex {
      value = rawValue.stringAddHexPrefix().lowercased()
    } else {
      value = rawValue
    }
    switch value {
    case "0xeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee":      self = ._primary
    case "0x1edc9ba729ef6fb017ef9c687b1a37d48b6a166c":      self = .starkChain
    case "0xeb4c2781e4eba804ce9a9803c67d0893436bb27d":      self = .renBTC
    case "0x00c83aecc790e8a4453e5dd3b0b4b3680501a7a7":      self = .skale
    case "0xae7ab96520de3a18e5e111b5eaab095312d7fe84":      self = .stEth
    case "0x2260fac5e5542a773aa44fbcfedf7c193bc2c599":      self = .wBTC
    case "0xa0b86991c6218b36c1d19d4a2e9eb0ce3606eb48":      self = .usdc
    case "0x7d1afa7b718fb893db30a3abc0cfc608aacfebb0":      self = .matic
    case "0xf551954d449ea3ae4d6a2656a42d9b9081b137b4":      self = ._zktv2Buidl
    case "0x7f904e350f27af4d4a70994ae1f3bbc1dafee665":      self = ._zktv2BuidlPaymaster
    case "0xfc5b07a5dd1b80cf271d35642f75cc0500ff1e2c":      self = ._zkv2BuidlPaymaster
    case "0x1bba25233556a7c3b41913f35a035916dbed1664":      self = ._zkv2Buidl
    case "0xeeeeeece1b4d9c1bd876b3e7fbe1871947c705cd":      self = .mewUniverse
      
    case _ where isHex && value.count == 42:                self = .unknown(.evm, value)
    case _ where value.hasPrefix("1"):                      self = .unknown(.bitcoin(.legacy), value)
    case _ where value.hasPrefix("2"):                      self = .unknown(.bitcoin(.legacy), value)
    case _ where value.hasPrefix("3"):                      self = .unknown(.bitcoin(.legacy), value)
    case _ where value.hasPrefix("m"):                      self = .unknown(.bitcoin(.legacy), value)
    case _ where value.hasPrefix("n"):                      self = .unknown(.bitcoin(.legacy), value)
    case _ where value.hasPrefix("bc1q"):                   self = .unknown(.bitcoin(.segwit), value)
    case _ where value.hasPrefix("bc1p"):                   self = .unknown(.bitcoin(.taproot), value)
    case _ where value.hasPrefix("tb1q"):                   self = .unknown(.bitcoin(.segwit), value)
    case _ where value.hasPrefix("tb1p"):                   self = .unknown(.bitcoin(.taproot), value)
    default:                                                self = .invalid(value)
    }
  }
  
  public init(encodedData: Data) {
    switch encodedData.count {
    case MDBXKeyLength.legacyEVMAddress:
      let rawValue = encodedData.hexString
      self.init(rawValue: rawValue)
    case MDBXKeyLength.addressEncodedLength:
      // bitcoin only for now, we can handle it without type
      let type = AddressType(rawValue: encodedData[0]) ?? .unknown
      let countData = Data(encodedData[1...2])
      let count = {
        let value = countData.withUnsafeBytes { $0.load(as: UInt16.self) }
        let uint = UInt16(bigEndian: value)
        return Int(uint)
      }()
      let addressData = encodedData[encodedData.count-count..<encodedData.count]
      switch type {
      case .evm:
        let rawValue = addressData.hexString
        self.init(rawValue: rawValue)
      case .bitcoin:
        let rawValue = String(data: addressData, encoding: .utf8)!
        self.init(rawValue: rawValue)
      case .unknown:
        let rawValue = String(data: encodedData, encoding: .utf8)!
        self.init(rawValue: rawValue)
      }
    default:
      let rawValue = String(data: encodedData, encoding: .utf8)!
      self.init(rawValue: rawValue)
    }
  }
  
  public var rawValue: String {
    switch self {
    case ._primary:                                   return "0xeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee"
      
    case .starkChain:                                 return "0x1edc9ba729ef6fb017ef9c687b1a37d48b6a166c"
    case .renBTC:                                     return "0xeb4c2781e4eba804ce9a9803c67d0893436bb27d"
    case .skale:                                      return "0x00c83aecc790e8a4453e5dd3b0b4b3680501a7a7"
    case .stEth:                                      return "0xae7ab96520de3a18e5e111b5eaab095312d7fe84"
    case .wBTC:                                       return "0x2260fac5e5542a773aa44fbcfedf7c193bc2c599"
    case .usdc:                                       return "0xa0b86991c6218b36c1d19d4a2e9eb0ce3606eb48"
    case .matic:                                      return "0x7d1afa7b718fb893db30a3abc0cfc608aacfebb0"
      
    case ._zktv2Buidl:                                return "0xf551954d449ea3ae4d6a2656a42d9b9081b137b4"
    case ._zktv2BuidlPaymaster:                       return "0x7f904e350f27af4d4a70994ae1f3bbc1dafee665"
      
    case ._zkv2BuidlPaymaster:                        return "0xfc5b07a5dd1b80cf271d35642f75cc0500ff1e2c"
    case ._zkv2Buidl:                                 return "0x1bba25233556a7c3b41913f35a035916dbed1664"
      
    case .mewUniverse:                                return "0xeeeeeece1b4d9c1bd876b3e7fbe1871947c705cd"
      
    case .unknown(_, let address):                    return address.lowercased()
    case .invalid(let address):                       return address.lowercased()
    }
  }
  
  public var data: Data {
    switch self.addressType {
    case .evm:                  return Data(hex: rawValue)
    case .bitcoin:              return rawValue.data(using: .utf8)!
    case .unknown:              return rawValue.data(using: .utf8)!
    }
  }
  
  public var encodedData: Data {
    switch self.addressType {
    case .evm:
      return Data(hex: rawValue)
    case .bitcoin:
      var data = rawValue.data(using: .utf8)!
      let count = UInt16(clamping: data.count)
      precondition(data.count < MDBXKeyLength.addressEncodedLength)
      data = data.setLengthLeft(MDBXKeyLength.addressEncodedLength)
      data[0] = self.addressType.rawValue.bigEndian
      let lenghtData = withUnsafeBytes(of: count.bigEndian) { Data($0) }
      data[1] = lenghtData[0]
      data[2] = lenghtData[1]
      return data
    case .unknown:
      return rawValue.data(using: .utf8)!
    }
  }
}

extension Address: ExpressibleByStringLiteral {
  public init(stringLiteral value: StringLiteralType) {
    self.init(rawValue: value)
  }
}

extension Address.AddressType: Comparable {
  public static func < (lhs: Address.AddressType, rhs: Address.AddressType) -> Bool {
    return lhs.rawValue < rhs.rawValue
  }
}

extension Address: Comparable {
  public static func ==(lhs: Address, rhs: Address) -> Bool {
    return lhs.rawValue.lowercased() == rhs.rawValue.lowercased()
  }
  
  public static func ==(lhs: Address, rhs: String) -> Bool {
    return lhs == .unknown(lhs.addressType, rhs)
  }
  
  public static func ==(lhs: String, rhs: Address) -> Bool {
    return .unknown(rhs.addressType, lhs) == rhs
  }
}

extension Address: Hashable {}

extension Address.AddressType: Hashable {}
