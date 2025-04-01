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
    let coder = MDBXKeyCoder()
    
    self.key = coder.encode(fields: [
      chain,
      address
    ])
    
    self.chain = chain
    self.address = address.rawValue
  }
  
  public init?(data: Data) {
    self.key = data
    
    let coder = MDBXKeyCoder()
    
    let decoded = coder.decode(data: data, fields: [
      .network,
      .address
    ])
    self.chain = decoded[0] as! MDBXChain
    self.address = (decoded[1] as! Address).rawValue
  }
}

// MARK: - AccountKey + Equatable

extension AccountKey: Equatable {
  public static func == (lhs: AccountKey, rhs: AccountKey) -> Bool { lhs.key == rhs.key }
}

extension AccountKey: Hashable {
  public func hash(into hasher: inout Hasher) {
    hasher.combine(key)
  }
}

public final class AccountKey_v1: MDBXKey {
  
  // MARK: - Public
  
  public let key: Data
  public let chain: MDBXChain
  public let address: String
  
  // MARK: - Lifecycle
  
  public init(address: Address) {
    let chainPart     = MDBXChain.evm.rawValue.setLengthLeft(MDBXKeyLength.chain)
    let addressPart   = Data(hex: address.rawValue).setLengthLeft(MDBXKeyLength.legacyEVMAddress)
    
    self.key = chainPart + addressPart
    
    let _chainRange: Range<Int> = 0..<MDBXKeyLength.chain
    let _addressRange = _chainRange.endIndex..<key.count
    
    self.chain = .evm
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
