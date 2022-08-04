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
  public var chain: MDBXChain { return MDBXChain(rawValue: self._chain) }
  public var address: Address { return self._address }
  public var contractAddress: Address { return self._contractAddress }
  
  // MARK: - Private
  
  private lazy var _chainRange: Range<Int> = { 0..<MDBXKeyLength.chain }()
  private lazy var _chain: Data = {
    return key[_chainRange]
  }()
  
  private lazy var _addressRange: Range<Int> = { _chainRange.endIndex..<_chainRange.upperBound+MDBXKeyLength.address }()
  private lazy var _address: Address = {
    return Address(rawValue: key[_addressRange].hexString)
  }()
  
  private lazy var _contractAddressRange: Range<Int> = { _addressRange.endIndex..<key.count }()
  private lazy var _contractAddress: Address = {
    return Address(rawValue: key[_contractAddressRange].hexString)
  }()
  
  // MARK: - Lifecycle
  
  public init(chain: MDBXChain, address: Address, contractAddress: Address) {
    let chainPart           = chain.rawValue.setLengthLeft(MDBXKeyLength.chain)
    let addressPart         = Data(hex: address.rawValue).setLengthLeft(MDBXKeyLength.address)
    let contractAddressPart = Data(hex: contractAddress.rawValue).setLengthLeft(MDBXKeyLength.address)
    
    self.key = chainPart + addressPart + contractAddressPart
  }
  
  public init(chain: MDBXChain, address: Address, lowerRange: Bool) {
    let chainPart           = chain.rawValue.setLengthLeft(MDBXKeyLength.chain)
    let addressPart         = Data(hex: address.rawValue).setLengthLeft(MDBXKeyLength.address)
    let contractAddressPart: Data
    if lowerRange {
      contractAddressPart = Data().setLengthLeft(MDBXKeyLength.address)
    } else {
      contractAddressPart = Data(repeating: 0xFF, count: MDBXKeyLength.address)
    }
    self.key = chainPart + addressPart + contractAddressPart
  }
  
  public init?(data: Data) {
    guard data.count == MDBXKeyLength.token else { return nil }
    self.key = data
  }
}
