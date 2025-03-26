//
//  File.swift
//  
//
//  Created by Mikhail Nikanorov on 6/7/22.
//

import Foundation
import CryptoKit

public final class AccountKey: MDBXKey {
  
  // MARK: - Public
  
  public let key: Data
  public let chain: MDBXChain
  public let address: String
  
  // MARK: - Lifecycle
  
  public init(chain: MDBXChain, address: Address) {
    let chainPart     = chain.rawValue.setLengthLeft(MDBXKeyLength.chain)
    let addressPart   = Data(hex: address.rawValue).setLengthLeft(MDBXKeyLength.address)
    
    self.key = chainPart + addressPart
    
    let _chainRange: Range<Int> = 0..<MDBXKeyLength.chain
    let _addressRange = _chainRange.endIndex..<key.count
    
    self.chain = chain
    self.address = key[_addressRange].hexString
  }
  
  public init?(data: Data) {
    guard data.count == MDBXKeyLength.account else { return nil }
    self.key = data
    
    let _chainRange: Range<Int> = 0..<MDBXKeyLength.chain
    let _addressRange = _chainRange.endIndex..<key.count
    
    self.chain = MDBXChain(rawValue: key[_chainRange])
    self.address = key[_addressRange].hexString
  }
}
