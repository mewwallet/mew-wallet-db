//
//  File.swift
//  
//
//  Created by Mikhail Nikanorov on 3/4/22.
//

import Foundation
import mew_wallet_ios_extensions

public final class TokenMetaKey: MDBXKey {
  // MARK: - Public
  
  public let key: Data
  public let chain: MDBXChain
  public let contractAddress: Address
  
  // MARK: - Lifecycle
  
  public init(chain: MDBXChain, contractAddress: Address) {
    let chainPart           = chain.rawValue.setLengthLeft(MDBXKeyLength.chain)
    let contractAddressPart = Data(hex: contractAddress.rawValue).setLengthLeft(MDBXKeyLength.legacyEVMAddress)
    
    let key = chainPart + contractAddressPart
    self.key = key
    
    let _chainRange: Range<Int> = 0..<MDBXKeyLength.chain
    let _contractAddressRange: Range<Int> = _chainRange.endIndex..<key.count
    self.chain = {
      return MDBXChain(rawValue: key[_chainRange])
    }()
    
    self.contractAddress = {
      return Address(rawValue: key[_contractAddressRange].hexString)
    }()
  }
  
  public init(chain: MDBXChain, lowerRange: Bool) {
    let rangeValue: UInt8 = lowerRange ? 0x00 : 0xFF
    
    let chainPart           = chain.rawValue.setLengthLeft(MDBXKeyLength.chain)
    let addressPart         = Data(repeating: rangeValue, count: MDBXKeyLength.legacyEVMAddress)
    
    let key = chainPart + addressPart
    self.key = key
    
    let _chainRange: Range<Int> = 0..<MDBXKeyLength.chain
    let _contractAddressRange: Range<Int> = _chainRange.endIndex..<key.count
    self.chain = {
      return MDBXChain(rawValue: key[_chainRange])
    }()
    
    self.contractAddress = {
      return Address(rawValue: key[_contractAddressRange].hexString)
    }()
  }
  
  public init?(data: Data) {
    guard data.count == MDBXKeyLength.tokenMeta else { return nil }
    self.key = data
    
    let _chainRange: Range<Int> = 0..<MDBXKeyLength.chain
    let _contractAddressRange: Range<Int> = _chainRange.endIndex..<key.count
    self.chain = {
      return MDBXChain(rawValue: data[_chainRange])
    }()
    
    self.contractAddress = {
      return Address(rawValue: data[_contractAddressRange].hexString)
    }()
  }
}

// MARK: - TokenMetaKey + Range

extension TokenMetaKey {
  public static func range(chain: MDBXChain, limit: UInt? = nil) -> MDBXKeyRange {
    let start = TokenMetaKey(chain: chain, lowerRange: true)
    let end = TokenMetaKey(chain: chain, lowerRange: false)
    
    return MDBXKeyRange(start: start, end: end, limit: limit)
  }
}
