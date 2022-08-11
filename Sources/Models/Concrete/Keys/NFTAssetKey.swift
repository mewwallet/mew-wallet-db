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
  public var chain: MDBXChain                 { _collectionKey.chain }
  public var collectionKey: NFTCollectionKey  { _collectionKey }
  public var contractAddress: Address         { _contractAddress }
  public var hash: Data                       { _hash }

  // MARK: - Private
  
  private lazy var _collectionKeyRange: Range<Int> = { 0..<MDBXKeyLength.nftCollection }()
  private lazy var _collectionKey: NFTCollectionKey = {
    return NFTCollectionKey(data: key[_collectionKeyRange])!
  }()
  
  private lazy var _contractAddressRange: Range<Int> = { _collectionKeyRange.endIndex..<_collectionKeyRange.upperBound+MDBXKeyLength.name }()
  private lazy var _contractAddress: Address = {
    return Address(rawValue: key[_contractAddressRange].hexString)
  }()
  
  private lazy var _hashRange: Range<Int> = { _contractAddressRange.endIndex..<key.count }()
  private lazy var _hash: Data = {
    return key[_hashRange]
  }()

  // MARK: - Lifecycle
  
  public init(collectionKey: NFTCollectionKey?, contractAddress: Address, id: String) {
    let collectionKeyPart   = collectionKey?.key ?? Data(repeating: 0x00, count: MDBXKeyLength.nftCollection)
    let contractAddressPart = Data(hex: contractAddress.rawValue).setLengthLeft(MDBXKeyLength.address)
    let hashPart            = id.sha256.setLengthLeft(MDBXKeyLength.hash)
    
    self.key = collectionKeyPart + contractAddressPart + hashPart
  }
  
  public init(collectionKey: NFTCollectionKey?, lowerRange: Bool) {
    let rangeValue: UInt8 = lowerRange ? 0x00 : 0xFF
    
    let collectionKeyPart   = collectionKey?.key ?? Data(repeating: 0x00, count: MDBXKeyLength.nftCollection)
    let contractAddressPart = Data(repeating: rangeValue, count: MDBXKeyLength.address)
    let hashPart            = Data(repeating: rangeValue, count: MDBXKeyLength.hash)
    
    self.key = collectionKeyPart + contractAddressPart + hashPart
  }
  
  public init?(data: Data) {
    guard data.count == MDBXKeyLength.nftAsset else { return nil }
    self.key = data
  }
}

// MARK: - NFTAssetKey + Equatable

extension NFTAssetKey: Equatable {
  public static func == (lhs: NFTAssetKey, rhs: NFTAssetKey) -> Bool { lhs.key == rhs.key }
}

// MARK: - NFTAssetKey + Range

extension NFTAssetKey {
  public static func range(chain: MDBXChain, address: Address) -> MDBXKeyRange {
    let start = NFTAssetKey(collectionKey: NFTCollectionKey(chain: chain, address: address, lowerRange: true), lowerRange: true)
    let end = NFTAssetKey(collectionKey: NFTCollectionKey(chain: chain, address: address, lowerRange: false), lowerRange: false)
    return MDBXKeyRange(start: start, end: end)
  }
  
  public static func range(collectionKey: NFTCollectionKey) -> MDBXKeyRange {
    let start = NFTAssetKey(collectionKey: collectionKey, lowerRange: true)
    let end = NFTAssetKey(collectionKey: collectionKey, lowerRange: false)
    return MDBXKeyRange(start: start, end: end)
  }
}
