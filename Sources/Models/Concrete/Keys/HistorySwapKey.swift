//
//  File.swift
//  
//
//  Created by Mikhail Nikanorov on 10/3/22.
//

import Foundation
import mew_wallet_ios_extensions

public final class HistorySwapKey: MDBXKey {
  
  // MARK: - Public
  
  public let key: Data
  public let chain: MDBXChain
  public let address: Address
  public let hash: String
  
  // MARK: - Lifecycle
  
  public init(chain: MDBXChain, account: Address, hash: String) {
    let chainPart           = chain.rawValue.setLengthLeft(MDBXKeyLength.chain)
    let addressPart         = Data(hex: account.rawValue).setLengthLeft(MDBXKeyLength.legacyEVMAddress)
    let hashPart            = Data(hex: hash).setLengthLeft(MDBXKeyLength.hash)
    
    let key = chainPart + addressPart + hashPart
    self.key = key
    
    let _chainRange: Range<Int> = 0..<MDBXKeyLength.chain
    let _addressRange: Range<Int> = _chainRange.endIndex..<_chainRange.upperBound+MDBXKeyLength.legacyEVMAddress
    let _hashRange: Range<Int> = _addressRange.endIndex..<key.count
    
    self.chain = {
      return MDBXChain(rawValue: key[_chainRange])
    }()
    
    self.address = {
      return Address(rawValue: key[_addressRange].hexString)
    }()
    
    self.hash = {
      return key[_hashRange].hexString
    }()
  }
  
  public init(chain: MDBXChain, address: Address?, lowerRange: Bool) {
    let chainPart           = chain.rawValue.setLengthLeft(MDBXKeyLength.chain)
    let addressPart: Data
    if let address {
      addressPart         = Data(hex: address.rawValue).setLengthLeft(MDBXKeyLength.legacyEVMAddress)
    } else {
      if lowerRange {
        addressPart         = Data().setLengthLeft(MDBXKeyLength.legacyEVMAddress)
      } else {
        addressPart         = Data(repeating: 0xFF, count: MDBXKeyLength.legacyEVMAddress)
      }
    }
    let hashPart: Data
    if lowerRange {
      hashPart              = Data().setLengthLeft(MDBXKeyLength.hash)
    } else {
      hashPart              = Data(repeating: 0xFF, count: MDBXKeyLength.hash)
    }
    let key = chainPart + addressPart + hashPart
    self.key = key
    
    let _chainRange: Range<Int> = 0..<MDBXKeyLength.chain
    let _addressRange: Range<Int> = _chainRange.endIndex..<_chainRange.upperBound+MDBXKeyLength.legacyEVMAddress
    let _hashRange: Range<Int> = _addressRange.endIndex..<key.count
    
    self.chain = {
      return MDBXChain(rawValue: key[_chainRange])
    }()
    
    self.address = {
      return Address(rawValue: key[_addressRange].hexString)
    }()
    
    self.hash = {
      return key[_hashRange].hexString
    }()
  }
  
  public init?(data: Data) {
    guard data.count == MDBXKeyLength.historySwap else { return nil }
    self.key = data
    
    let _chainRange: Range<Int> = 0..<MDBXKeyLength.chain
    let _addressRange: Range<Int> = _chainRange.endIndex..<_chainRange.upperBound+MDBXKeyLength.legacyEVMAddress
    let _hashRange: Range<Int> = _addressRange.endIndex..<key.count
    
    self.chain = {
      return MDBXChain(rawValue: data[_chainRange])
    }()
    
    self.address = {
      return Address(rawValue: data[_addressRange].hexString)
    }()
    
    self.hash = {
      return data[_hashRange].hexString
    }()
  }
}

// MARK: - HistorySwapKey + Range

extension HistorySwapKey {
  public static func range(chain: MDBXChain, address: Address? = nil) -> MDBXKeyRange {
    let start = HistorySwapKey(chain: chain, address: address, lowerRange: true)
    let end = HistorySwapKey(chain: chain, address: address, lowerRange: false)
    return MDBXKeyRange(start: start, end: end, limit: nil)
  }
}
