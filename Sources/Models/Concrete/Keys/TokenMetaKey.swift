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
  public var chain: MDBXChain { return MDBXChain(rawValue: self._chain) }
  public var contractAddress: Address { return self._contractAddress }
  
  // MARK: - Private
  
  private lazy var _chainRange: Range<Int> = { 0..<MDBXKeyLength.chain }()
  private lazy var _chain: Data = {
    return key[_chainRange]
  }()
  
  private lazy var _contractAddressRange: Range<Int> = { _chainRange.endIndex..<key.count }()
  private lazy var _contractAddress: Address = {
    return Address(rawValue: key[_contractAddressRange].hexString)
  }()
  
  // MARK: - Lifecycle
  
  public init(chain: MDBXChain, contractAddress: Address) {
    let chainPart           = chain.rawValue.setLengthLeft(MDBXKeyLength.chain)
    let contractAddressPart = Data(hex: contractAddress.rawValue).setLengthLeft(MDBXKeyLength.address)
    
    self.key = chainPart + contractAddressPart
  }
  
  init?(data: Data) {
    guard data.count == MDBXKeyLength.tokenMeta else { return nil }
    self.key = data
  }
}
