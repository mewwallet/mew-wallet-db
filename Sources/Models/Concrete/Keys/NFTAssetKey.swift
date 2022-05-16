//
//  AssetKey.swift
//  
//
//  Created by Sergey Kolokolnikov on 05.05.2022.
//

import Foundation
import MEWextensions

public final class NFTAssetKey: MDBXKey {
  
  // MARK: - Public
  
  public let key: Data
  public var chain: MDBXChain { return MDBXChain(rawValue: self._chain) }
  public var address: String { return self._address }
  public var contractAddress: String { return self._contractAddress }
  public var id: String { return self._id }

  // MARK: - Private
  
  private lazy var _chainRange: Range<Int> = { 0..<MDBXKeyLength.chain }()
  private lazy var _chain: Data = {
    return key[_chainRange]
  }()
  
  private lazy var _addressRange: Range<Int> = { _chainRange.startIndex..<MDBXKeyLength.address }()
  private lazy var _contractAddressRange: Range<Int> = { MDBXKeyLength.address..<MDBXKeyLength.token }()
  private lazy var _idRange: Range<Int> = { MDBXKeyLength.token..<key.count }()
  private lazy var _contractAddress: String = {
    return key[_contractAddressRange].hexString
  }()
  private lazy var _address: String = {
    return key[_addressRange].hexString
  }()
  private lazy var _id: String = {
    return key[_idRange].hexString
  }()

  // MARK: - Lifecycle
  
  public init(chain: MDBXChain, address: String, contractAddress: String, id: String) {
    let chainPart           = chain.rawValue.setLengthLeft(MDBXKeyLength.chain)
    let addressPart         = Data(hex: address).setLengthLeft(MDBXKeyLength.address)
    let contractAddressPart = Data(hex: contractAddress).setLengthLeft(MDBXKeyLength.contractAddress)
    let assetIdPart         = id.sha256.setLengthLeft(MDBXKeyLength.hash)
    
    self.key = chainPart + addressPart + contractAddressPart + assetIdPart
  }
  
  init?(data: Data) {
    guard data.count == MDBXKeyLength.nftAsset else { return nil }
    self.key = data
  }
}

