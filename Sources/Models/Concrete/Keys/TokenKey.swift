//
//  File.swift
//  
//
//  Created by Mikhail Nikanorov on 3/21/22.
//

import Foundation
import mew_wallet_ios_extensions

public final class TokenKey: MDBXKey {
  
  // MARK: - Public
  
  public let key: Data
  public let chain: MDBXChain
  public let address: Address
  public let contractAddress: Address
  
  // MARK: - Lifecycle
  
  public init(chain: MDBXChain, address: Address, contractAddress: Address) {
    let chainPart           = chain.rawValue.setLengthLeft(MDBXKeyLength.chain)
    let addressPart         = Data(hex: address.rawValue).setLengthLeft(MDBXKeyLength.legacyEVMAddress)
    let contractAddressPart = Data(hex: contractAddress.rawValue).setLengthLeft(MDBXKeyLength.legacyEVMAddress)
    
    let key = chainPart + addressPart + contractAddressPart
    self.key = key
        
    let _chainRange: Range<Int> = 0..<MDBXKeyLength.chain
    let _addressRange: Range<Int> = _chainRange.endIndex..<_chainRange.upperBound+MDBXKeyLength.legacyEVMAddress
    let _contractAddressRange: Range<Int> = _addressRange.endIndex..<key.count
    
    self.chain = {
      return MDBXChain(rawValue: key[_chainRange])
    }()
    
    self.address = {
      return Address(rawValue: key[_addressRange].hexString)
    }()
    
    self.contractAddress = {
      return Address(rawValue: key[_contractAddressRange].hexString)
    }()
  }
  
  public init(chain: MDBXChain, address: Address, lowerRange: Bool) {
    let chainPart           = chain.rawValue.setLengthLeft(MDBXKeyLength.chain)
    let addressPart         = Data(hex: address.rawValue).setLengthLeft(MDBXKeyLength.legacyEVMAddress)
    let contractAddressPart: Data
    if lowerRange {
      contractAddressPart = Data().setLengthLeft(MDBXKeyLength.legacyEVMAddress)
    } else {
      contractAddressPart = Data(repeating: 0xFF, count: MDBXKeyLength.legacyEVMAddress)
    }
    let key = chainPart + addressPart + contractAddressPart
    self.key = key
        
    let _chainRange: Range<Int> = 0..<MDBXKeyLength.chain
    let _addressRange: Range<Int> = _chainRange.endIndex..<_chainRange.upperBound+MDBXKeyLength.legacyEVMAddress
    let _contractAddressRange: Range<Int> = _addressRange.endIndex..<key.count
    
    self.chain = {
      return MDBXChain(rawValue: key[_chainRange])
    }()
    
    self.address = {
      return Address(rawValue: key[_addressRange].hexString)
    }()
    
    self.contractAddress = {
      return Address(rawValue: key[_contractAddressRange].hexString)
    }()
  }
  
  public init?(data: Data) {
    guard data.count == MDBXKeyLength.token else { return nil }
    self.key = data
        
    let _chainRange: Range<Int> = 0..<MDBXKeyLength.chain
    let _addressRange: Range<Int> = _chainRange.endIndex..<_chainRange.upperBound+MDBXKeyLength.legacyEVMAddress
    let _contractAddressRange: Range<Int> = _addressRange.endIndex..<key.count
    
    self.chain = {
      return MDBXChain(rawValue: data[_chainRange])
    }()
    
    self.address = {
      return Address(rawValue: data[_addressRange].hexString)
    }()
    
    self.contractAddress = {
      return Address(rawValue: data[_contractAddressRange].hexString)
    }()
  }
}

// MARK: - TokenKey + Range

extension TokenKey {
  public static func range(chain: MDBXChain, address: Address) -> MDBXKeyRange {
    let start = TokenKey(chain: chain, address: address, lowerRange: true)
    let end = TokenKey(chain: chain, address: address, lowerRange: false)
    return MDBXKeyRange(start: start, end: end, limit: nil)
  }
}
