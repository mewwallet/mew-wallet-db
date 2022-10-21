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
  public var chain: MDBXChain           { MDBXChain(rawValue: self._chain) }
  public var address: Address           { _address }
  public var contractAddress: Address   { _contractAddress }
  public var name: String               { _name }
  public var hash: Data                 { _hash }
  
  // MARK: - Private
  
  private lazy var _chainRange: Range<Int> = { 0..<MDBXKeyLength.chain }()
  private lazy var _chain: Data = {
    return key[_chainRange]
  }()
  
  private lazy var _addressRange: Range<Int> = { _chainRange.endIndex..<_chainRange.upperBound+MDBXKeyLength.address }()
  private lazy var _address: Address = {
    return Address(rawValue: key[_addressRange].hexString)
  }()
  
  private lazy var _contractAddressRange: Range<Int> = { _addressRange.endIndex..<_addressRange.upperBound+MDBXKeyLength.address }()
  private lazy var _contractAddress: Address = {
    return Address(rawValue: key[_contractAddressRange].hexString)
  }()
  
  private lazy var _nameRange: Range<Int> = { _contractAddressRange.endIndex..<_contractAddressRange.upperBound+MDBXKeyLength.name }()
  private lazy var _name: String = {
    return String(data: key[_nameRange], encoding: .utf8) ?? ""
  }()
  
  private lazy var _hashRange: Range<Int> = { _nameRange.endIndex..<key.count }()
  private lazy var _hash: Data = {
    return key[_hashRange]
  }()
  
  // MARK: - Lifecycle
  
  public init(chain: MDBXChain, address: Address, contractAddress: Address, name: String) {
    var nameData = name.data(using: .utf8) ?? Data()
    if nameData.count > MDBXKeyLength.name {
      nameData = nameData[0..<MDBXKeyLength.name]
    }
    
    let chainPart           = chain.rawValue.setLengthLeft(MDBXKeyLength.chain)
    let addressPart         = Data(hex: address.rawValue).setLengthLeft(MDBXKeyLength.address)
    let contractAddressPart = Data(hex: contractAddress.rawValue).setLengthLeft(MDBXKeyLength.address)
    let namePart            = nameData.setLengthRight(MDBXKeyLength.name)
    let hashPart            = namePart.sha256.setLengthLeft(MDBXKeyLength.hash)
    
    self.key = chainPart + addressPart + contractAddressPart + namePart + hashPart
  }
  
  public init(chain: MDBXChain, address: Address, lowerRange: Bool) {
    let rangeValue: UInt8 = lowerRange ? 0x00 : 0xFF
    
    let chainPart           = chain.rawValue.setLengthLeft(MDBXKeyLength.chain)
    let addressPart         = Data(hex: address.rawValue).setLengthLeft(MDBXKeyLength.address)
    let contractAddressPart = Data(repeating: rangeValue, count: MDBXKeyLength.address)
    let namePart            = Data(repeating: rangeValue, count: MDBXKeyLength.name)
    let hashPart            = Data(repeating: rangeValue, count: MDBXKeyLength.hash)
    
    self.key = chainPart + addressPart + contractAddressPart + namePart + hashPart
  }

  public init?(data: Data) {
    guard data.count == MDBXKeyLength.nftCollection else { return nil }
    self.key = data
  }
  
}

// MARK: - NFTCollectionKey + Range

extension NFTCollectionKey {
  public static func range(chain: MDBXChain, address: Address) -> MDBXKeyRange {
    let start = NFTCollectionKey(chain: chain, address: address, lowerRange: true)
    let end = NFTCollectionKey(chain: chain, address: address, lowerRange: false)
    return MDBXKeyRange(start: start, end: end, limit: nil)
  }
}

// MARK: - NFTCollectionKey + Sendable

extension NFTCollectionKey: @unchecked Sendable {}
