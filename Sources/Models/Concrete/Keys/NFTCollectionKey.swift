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
  public let chain: MDBXChain
  public let address: Address
  public let name: String
  public let contractAddress: Address
  public let hash: Data
  
  // MARK: - Lifecycle
  
  public init(chain: MDBXChain, address: Address, contractAddress: Address, name: String) {
    var nameData = name.data(using: .utf8) ?? Data()
    if nameData.count > MDBXKeyLength.name {
      nameData = nameData[0..<MDBXKeyLength.name]
    }
    
    let chainPart           = chain.rawValue.setLengthLeft(MDBXKeyLength.chain)
    let addressPart         = Data(hex: address.rawValue).setLengthLeft(MDBXKeyLength.address)
    let namePart            = nameData.setLengthRight(MDBXKeyLength.name)
    let contractAddressPart = Data(hex: contractAddress.rawValue).setLengthLeft(MDBXKeyLength.address)
    let hashPart            = namePart.sha256.setLengthLeft(MDBXKeyLength.hash)
    
    let key = chainPart + addressPart + namePart + contractAddressPart + hashPart
    self.key = key
    
    let _chainRange: Range<Int> = 0..<MDBXKeyLength.chain
    let _addressRange: Range<Int> = _chainRange.endIndex..<_chainRange.upperBound+MDBXKeyLength.address
    let _nameRange: Range<Int> = _addressRange.endIndex..<_addressRange.upperBound+MDBXKeyLength.name
    let _contractAddressRange: Range<Int> = _nameRange.endIndex..<_nameRange.upperBound+MDBXKeyLength.address
    let _hashRange: Range<Int> = _contractAddressRange.endIndex..<key.count
    
    self.chain = {
      return MDBXChain(rawValue: key[_chainRange])
    }()
    
    self.address = {
      return Address(rawValue: key[_addressRange].hexString)
    }()
    
    self.name = {
      return String(data: key[_nameRange], encoding: .utf8) ?? ""
    }()
    
    self.contractAddress = {
      return Address(rawValue: key[_contractAddressRange].hexString)
    }()
    
    self.hash = {
      return key[_hashRange]
    }()
  }
  
  public init(chain: MDBXChain, address: Address, lowerRange: Bool) {
    let rangeValue: UInt8 = lowerRange ? 0x00 : 0xFF
    
    let chainPart           = chain.rawValue.setLengthLeft(MDBXKeyLength.chain)
    let addressPart         = Data(hex: address.rawValue).setLengthLeft(MDBXKeyLength.address)
    let namePart            = Data(repeating: rangeValue, count: MDBXKeyLength.name)
    let contractAddressPart = Data(repeating: rangeValue, count: MDBXKeyLength.address)
    let hashPart            = Data(repeating: rangeValue, count: MDBXKeyLength.hash)
    
    let key = chainPart + addressPart + namePart + contractAddressPart + hashPart
    self.key = key
    
    let _chainRange: Range<Int> = 0..<MDBXKeyLength.chain
    let _addressRange: Range<Int> = _chainRange.endIndex..<_chainRange.upperBound+MDBXKeyLength.address
    let _nameRange: Range<Int> = _addressRange.endIndex..<_addressRange.upperBound+MDBXKeyLength.name
    let _contractAddressRange: Range<Int> = _nameRange.endIndex..<_nameRange.upperBound+MDBXKeyLength.address
    let _hashRange: Range<Int> = _contractAddressRange.endIndex..<key.count
    
    self.chain = {
      return MDBXChain(rawValue: key[_chainRange])
    }()
    
    self.address = {
      return Address(rawValue: key[_addressRange].hexString)
    }()
    
    self.name = {
      return String(data: key[_nameRange], encoding: .utf8) ?? ""
    }()
    
    self.contractAddress = {
      return Address(rawValue: key[_contractAddressRange].hexString)
    }()
    
    self.hash = {
      return key[_hashRange]
    }()
  }

  public init?(data: Data) {
    guard data.count == MDBXKeyLength.nftCollection else { return nil }
    self.key = data
    
    let _chainRange: Range<Int> = 0..<MDBXKeyLength.chain
    let _addressRange: Range<Int> = _chainRange.endIndex..<_chainRange.upperBound+MDBXKeyLength.address
    let _nameRange: Range<Int> = _addressRange.endIndex..<_addressRange.upperBound+MDBXKeyLength.name
    let _contractAddressRange: Range<Int> = _nameRange.endIndex..<_nameRange.upperBound+MDBXKeyLength.address
    let _hashRange: Range<Int> = _contractAddressRange.endIndex..<key.count
    
    self.chain = {
      return MDBXChain(rawValue: data[_chainRange])
    }()
    
    self.address = {
      return Address(rawValue: data[_addressRange].hexString)
    }()
    
    self.name = {
      return String(data: data[_nameRange], encoding: .utf8) ?? ""
    }()
    
    self.contractAddress = {
      return Address(rawValue: data[_contractAddressRange].hexString)
    }()
    
    self.hash = {
      return data[_hashRange]
    }()
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
