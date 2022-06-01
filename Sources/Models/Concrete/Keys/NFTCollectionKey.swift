//
//  File.swift
//  
//
//  Created by Sergey Kolokolnikov on 28.04.2022.
//

import Foundation

public final class NFTCollectionKey: MDBXKey {
  // MARK: - Public
  
  public let key: Data
  public var chain: MDBXChain { return MDBXChain(rawValue: self._chain) }
  public var address: String { return self._address }
  public var contractAddress: String { return self._contractAddress }
  
  // MARK: - Private
  
  private lazy var _chainRange: Range<Int> = { 0..<MDBXKeyLength.chain }()
  private lazy var _chain: Data = {
    return key[_chainRange]
  }()
  
  private lazy var _addressRange: Range<Int> = { _chainRange.endIndex..<32 }()
  private lazy var _contractAddressRange: Range<Int> = { 32..<key.count }()
  private lazy var _contractAddress: String = {
    return key[_contractAddressRange].hexString
  }()
  private lazy var _address: String = {
    return key[_addressRange].hexString
  }()
  
  // MARK: - Lifecycle
  
  public init(chain: MDBXChain, address: String, contractAddress: String) {
    let chainPart           = chain.rawValue.setLengthLeft(MDBXKeyLength.chain)
    let contractAddressPart = Data(hex: contractAddress).setLengthLeft(MDBXKeyLength.contractAddress)
    let addressPart         = Data(hex: address).setLengthLeft(MDBXKeyLength.address)
    
    self.key = chainPart + addressPart + contractAddressPart
  }
  
  public init(chain: MDBXChain, address: String, lowerRange: Bool) {
    let chainPart           = chain.rawValue.setLengthLeft(MDBXKeyLength.chain)
    let addressPart         = Data(hex: address).setLengthLeft(MDBXKeyLength.address)
    let contractAddressPart: Data
    if lowerRange {
      contractAddressPart = Data().setLengthLeft(MDBXKeyLength.contractAddress)
    } else {
      contractAddressPart = Data(repeating: 0xFF, count: MDBXKeyLength.contractAddress)
    }
    self.key = chainPart + addressPart + contractAddressPart
  }

  init?(data: Data) {
    guard data.count == MDBXKeyLength.token else { return nil }
    self.key = data
  }
  
}
