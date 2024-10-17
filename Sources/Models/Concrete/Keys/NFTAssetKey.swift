//
//  AssetKey.swift
//  
//
//  Created by Sergey Kolokolnikov on 05.05.2022.
//

import Foundation
import mew_wallet_ios_extensions

public final class NFTAssetKey: MDBXKey {
  
  // MARK: - Public
  
  public let key: Data
  public let chain: MDBXChain
  public let collectionKey: NFTCollectionKey
  public let dateHex: String
  public let contractAddress: Address
  public let hash: Data

  // MARK: - Lifecycle
  
  public init(collectionKey: NFTCollectionKey?, date: String, contractAddress: Address, id: String) {
    var nameData = Data(hex: date.components(separatedBy: CharacterSet.decimalDigits.inverted).joined())
    if nameData.count > MDBXKeyLength.dateHex {
      nameData = nameData[0..<MDBXKeyLength.dateHex]
    }
    
    let collectionKeyPart   = collectionKey?.key ?? Data(repeating: 0x00, count: MDBXKeyLength.nftCollection)
    let dateHexPart         = nameData.setLengthRight(MDBXKeyLength.dateHex)
    let contractAddressPart = Data(hex: contractAddress.rawValue).setLengthLeft(MDBXKeyLength.address)
    let hashPart            = id.sha256.setLengthLeft(MDBXKeyLength.hash)
    
    let key = collectionKeyPart + dateHexPart + contractAddressPart + hashPart
    self.key = key
    
    let _collectionKeyRange: Range<Int> = 0..<MDBXKeyLength.nftCollection
    let _dateHexRange: Range<Int> = _collectionKeyRange.endIndex..<_collectionKeyRange.upperBound+MDBXKeyLength.dateHex
    let _contractAddressRange: Range<Int> = _dateHexRange.endIndex..<_dateHexRange.upperBound+MDBXKeyLength.address
    let _hashRange: Range<Int> = _contractAddressRange.endIndex..<key.count

    self.collectionKey = {
      return NFTCollectionKey(data: key[_collectionKeyRange])!
    }()
    self.chain = self.collectionKey.chain
    
    self.dateHex = {
      return key[_dateHexRange].hexString
    }()
    
    self.contractAddress = {
      return Address(rawValue: key[_contractAddressRange].hexString)
    }()
    
    self.hash = {
      return key[_hashRange]
    }()
  }
  
  public init(collectionKey: NFTCollectionKey?, lowerRange: Bool) {
    let rangeValue: UInt8 = lowerRange ? 0x00 : 0xFF
    
    let collectionKeyPart   = collectionKey?.key ?? Data(repeating: 0x00, count: MDBXKeyLength.nftCollection)
    let contractAddressPart = Data(repeating: rangeValue, count: MDBXKeyLength.address)
    let dateHexPart         = Data(repeating: rangeValue, count: MDBXKeyLength.dateHex)
    let hashPart            = Data(repeating: rangeValue, count: MDBXKeyLength.hash)
    
    let key = collectionKeyPart + dateHexPart + contractAddressPart + hashPart
    self.key = key
    
    let _collectionKeyRange: Range<Int> = 0..<MDBXKeyLength.nftCollection
    let _dateHexRange: Range<Int> = _collectionKeyRange.endIndex..<_collectionKeyRange.upperBound+MDBXKeyLength.dateHex
    let _contractAddressRange: Range<Int> = _dateHexRange.endIndex..<_dateHexRange.upperBound+MDBXKeyLength.address
    let _hashRange: Range<Int> = _contractAddressRange.endIndex..<key.count

    self.collectionKey = {
      return NFTCollectionKey(data: key[_collectionKeyRange])!
    }()
    self.chain = self.collectionKey.chain
    
    self.dateHex = {
      return key[_dateHexRange].hexString
    }()
    
    self.contractAddress = {
      return Address(rawValue: key[_contractAddressRange].hexString)
    }()
    
    self.hash = {
      return key[_hashRange]
    }()
  }
  
  public init?(data: Data) {
    guard data.count == MDBXKeyLength.nftAsset else { return nil }
    self.key = data
    
    let _collectionKeyRange: Range<Int> = 0..<MDBXKeyLength.nftCollection
    let _dateHexRange: Range<Int> = _collectionKeyRange.endIndex..<_collectionKeyRange.upperBound+MDBXKeyLength.dateHex
    let _contractAddressRange: Range<Int> = _dateHexRange.endIndex..<_dateHexRange.upperBound+MDBXKeyLength.address
    let _hashRange: Range<Int> = _contractAddressRange.endIndex..<key.count

    self.collectionKey = {
      return NFTCollectionKey(data: data[_collectionKeyRange])!
    }()
    self.chain = self.collectionKey.chain
    
    self.dateHex = {
      return data[_dateHexRange].hexString
    }()
    
    self.contractAddress = {
      return Address(rawValue: data[_contractAddressRange].hexString)
    }()
    
    self.hash = {
      return data[_hashRange]
    }()
  }
}

// MARK: - NFTAssetKey + Equatable

extension NFTAssetKey: Equatable {
  public static func == (lhs: NFTAssetKey, rhs: NFTAssetKey) -> Bool { lhs.key == rhs.key }
}

extension NFTAssetKey: Hashable {
  public func hash(into hasher: inout Hasher) {
    hasher.combine(key)
  }
}

// MARK: - NFTAssetKey + Range

extension NFTAssetKey {
  public static func range(chain: MDBXChain, address: Address, start: NFTAssetKey?, end: [NFTAssetKey]?) -> MDBXKeyRange {
    let op: MDBXKeyRange.Op = start == nil ? .all : .greaterThanStart
    
    let start = start ?? NFTAssetKey(collectionKey: NFTCollectionKey(chain: chain, address: address, lowerRange: true), lowerRange: true)
    if let end {
      let end = end.sorted(by: {
        $0.key.hexString < $1.key.hexString
      }).last ?? NFTAssetKey(collectionKey: NFTCollectionKey(chain: chain, address: address, lowerRange: false), lowerRange: false)
      return MDBXKeyRange(start: start, end: end, limit: nil, op: op)
    } else {
      let end = NFTAssetKey(collectionKey: NFTCollectionKey(chain: chain, address: address, lowerRange: false), lowerRange: false)
      return MDBXKeyRange(start: start, end: end, limit: nil, op: op)
    }
  }
  
  public static func range(collectionKey: NFTCollectionKey) -> MDBXKeyRange {
    let start = NFTAssetKey(collectionKey: collectionKey, lowerRange: true)
    let end = NFTAssetKey(collectionKey: collectionKey, lowerRange: false)
    return MDBXKeyRange(start: start, end: end, limit: nil, op: .all)
  }
}
