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
  public var contractAddress: String { return self._contractAddress }
  public var accountAddress: String { return self._accountAddress }
  
  // MARK: - Private
  
  private lazy var _chainRange: Range<Int> = { 0..<MDBXKeyLength.chain }()
  private lazy var _chain: Data = {
    return key[_chainRange]
  }()
  
  private lazy var _contractAddressRange: Range<Int> = { _chainRange.endIndex..<32 }()
  private lazy var _accountAddressRange: Range<Int> = { 32..<key.count }()
  private lazy var _contractAddress: String = {
    return key[_contractAddressRange].hexString
  }()
  private lazy var _accountAddress: String = {
    return key[_accountAddressRange].hexString
  }()

  // MARK: - Lifecycle
  
  public init(chain: MDBXChain, contractAddress: String, accountAddress: String) {
    let chainPart           = chain.rawValue.setLengthLeft(MDBXKeyLength.chain)
    let contractAddressPart = Data(hex: contractAddress).setLengthLeft(MDBXKeyLength.contractAddress)
    let accountAddressPart = Data(hex: accountAddress).setLengthLeft(MDBXKeyLength.address)
    
    self.key = chainPart + contractAddressPart + accountAddressPart
  }
  
  init?(data: Data) {
    guard data.count == MDBXKeyLength.tokenMeta else { return nil }
    self.key = data
  }

}
