//
//  AssetKey.swift
//  
//
//  Created by Sergey Kolokolnikov on 05.05.2022.
//

import Foundation
import MEWextensions
import CryptoSwift

public final class AssetKey: MDBXKey {
  
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
  
  private lazy var _addressRange: Range<Int> = { _chainRange.endIndex..<32 }()
  private lazy var _contractAddressRange: Range<Int> = { 32..<64 }()
  private lazy var _idRange: Range<Int> = { 64..<key.count }()
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
    let addressPart         = address.data(using: .utf8)?.setLengthLeft(MDBXKeyLength.address) ?? Data()
    let contractAddressPart = contractAddress.data(using: .utf8)?.setLengthLeft(MDBXKeyLength.contractAddress) ?? Data()
    let assetIdPart         = id.data(using: .utf8)?.sha256().setLengthLeft(MDBXKeyLength.hash) ?? Data()
    
    self.key = chainPart + addressPart + contractAddressPart + assetIdPart
  }
  
  init?(data: Data) {
    guard data.count == MDBXKeyLength.token + MDBXKeyLength.hash else { return nil }
    self.key = data
  }
}

