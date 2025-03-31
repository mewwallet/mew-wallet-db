//
//  File.swift
//  
//
//  Created by Mikhail Nikanorov on 9/23/22.
//

import Foundation
import mew_wallet_ios_extensions

public final class TransferKey: MDBXKey {
  // MARK: - Public
  
  public let key: Data
  internal let sortingKey: Data
  public let chain: MDBXChain
  public let address: Address
  public let block: UInt64
  public let direction: Transfer.Direction
  public let nonce: UInt64
  public let order: UInt16
  
  // MARK: - Lifecycle
  
  public init(chain: MDBXChain, address: Address, block: UInt64, direction: Transfer.Direction, nonce: UInt64, order: UInt16) {
    let chainPart           = chain.rawValue.setLengthLeft(MDBXKeyLength.chain)
    let addressPart         = Data(hex: address.rawValue).setLengthLeft(MDBXKeyLength.legacyEVMAddress)
    let blockPart           = withUnsafeBytes(of: block.bigEndian) { Data($0) }.setLengthLeft(MDBXKeyLength.block)
    let directionPart       = withUnsafeBytes(of: direction.rawValue.bigEndian) { Data($0) }.setLengthLeft(MDBXKeyLength.direction)
    let noncePart           = withUnsafeBytes(of: nonce.bigEndian) { Data($0) }.setLengthLeft(MDBXKeyLength.nonce)
    let orderPart           = withUnsafeBytes(of: order.bigEndian) { Data($0) }.setLengthLeft(MDBXKeyLength.order)
    
    let key = chainPart + addressPart + blockPart + directionPart + noncePart + orderPart
    self.key = key
    
    let _chainRange: Range<Int> = 0..<MDBXKeyLength.chain
    let _addressRange: Range<Int> =  _chainRange.endIndex..<_chainRange.upperBound+MDBXKeyLength.legacyEVMAddress
    let _blockRange: Range<Int> = _addressRange.endIndex..<_addressRange.upperBound+MDBXKeyLength.block
    let _directionRange: Range<Int> = _blockRange.endIndex..<_blockRange.upperBound+MDBXKeyLength.direction
    let _nonceRange: Range<Int> = _directionRange.endIndex..<_directionRange.upperBound+MDBXKeyLength.nonce
    let _orderRange: Range<Int> = _nonceRange.endIndex..<key.count
    let _sortingKeyRange: PartialRangeFrom<Int> = (MDBXKeyLength.chain+MDBXKeyLength.legacyEVMAddress)...
    
    self.chain = {
      return MDBXChain(rawValue: key[_chainRange])
    }()
    
    self.address = {
      return Address(rawValue: key[_addressRange].hexString)
    }()
    
    self.block = {
      let value = key.subdata(in: _blockRange).withUnsafeBytes { $0.load(as: UInt64.self) }
      return UInt64(bigEndian: value)
    }()
    
    self.direction = {
      let value = key.subdata(in: _directionRange).withUnsafeBytes { $0.load(as: UInt8.self) }
      return Transfer.Direction(rawValue: UInt8(bigEndian: value)) ?? .incoming
    }()
    
    self.nonce = {
      let value = key.subdata(in: _nonceRange).withUnsafeBytes { $0.load(as: UInt64.self) }
      return UInt64(bigEndian: value)
    }()
    
    self.order = {
      let value = key.subdata(in: _orderRange).withUnsafeBytes { $0.load(as: UInt16.self) }
      return UInt16(bigEndian: value)
    }()
    
    self.sortingKey = {
      return key[_sortingKeyRange]
    }()
  }
  
  public init(chain: MDBXChain, address: Address, lowerRange: Bool) {
    let chainPart           = chain.rawValue.setLengthLeft(MDBXKeyLength.chain)
    let addressPart         = Data(hex: address.rawValue).setLengthLeft(MDBXKeyLength.legacyEVMAddress)

    let blockPart: Data
    let directionPart: Data
    let noncePart: Data
    let orderPart: Data
    if lowerRange {
      blockPart     = Data().setLengthLeft(MDBXKeyLength.block)
      directionPart = Data().setLengthLeft(MDBXKeyLength.direction)
      noncePart     = Data().setLengthLeft(MDBXKeyLength.nonce)
      orderPart     = Data().setLengthLeft(MDBXKeyLength.order)
    } else {
      blockPart     = Data(repeating: 0xFF, count: MDBXKeyLength.block)
      directionPart = Data(repeating: 0xFF, count: MDBXKeyLength.direction)
      noncePart     = Data(repeating: 0xFF, count: MDBXKeyLength.nonce)
      orderPart     = Data(repeating: 0xFF, count: MDBXKeyLength.order)
    }
    let key = chainPart + addressPart + blockPart + directionPart + noncePart + orderPart
    self.key = key
    
    let _chainRange: Range<Int> = 0..<MDBXKeyLength.chain
    let _addressRange: Range<Int> =  _chainRange.endIndex..<_chainRange.upperBound+MDBXKeyLength.legacyEVMAddress
    let _blockRange: Range<Int> = _addressRange.endIndex..<_addressRange.upperBound+MDBXKeyLength.block
    let _directionRange: Range<Int> = _blockRange.endIndex..<_blockRange.upperBound+MDBXKeyLength.direction
    let _nonceRange: Range<Int> = _directionRange.endIndex..<_directionRange.upperBound+MDBXKeyLength.nonce
    let _orderRange: Range<Int> = _nonceRange.endIndex..<key.count
    let _sortingKeyRange: PartialRangeFrom<Int> = (MDBXKeyLength.chain+MDBXKeyLength.legacyEVMAddress)...
    
    self.chain = {
      return MDBXChain(rawValue: key[_chainRange])
    }()
    
    self.address = {
      return Address(rawValue: key[_addressRange].hexString)
    }()
    
    self.block = {
      let value = key.subdata(in: _blockRange).withUnsafeBytes { $0.load(as: UInt64.self) }
      return UInt64(bigEndian: value)
    }()
    
    self.direction = {
      let value = key.subdata(in: _directionRange).withUnsafeBytes { $0.load(as: UInt8.self) }
      return Transfer.Direction(rawValue: UInt8(bigEndian: value)) ?? .incoming
    }()
    
    self.nonce = {
      let value = key.subdata(in: _nonceRange).withUnsafeBytes { $0.load(as: UInt64.self) }
      return UInt64(bigEndian: value)
    }()
    
    self.order = {
      let value = key.subdata(in: _orderRange).withUnsafeBytes { $0.load(as: UInt16.self) }
      return UInt16(bigEndian: value)
    }()
    
    self.sortingKey = {
      return key[_sortingKeyRange]
    }()
  }
  
  public init?(data: Data) {
    guard data.count == MDBXKeyLength.transfer else { return nil }
    self.key = data
    
    let _chainRange: Range<Int> = 0..<MDBXKeyLength.chain
    let _addressRange: Range<Int> =  _chainRange.endIndex..<_chainRange.upperBound+MDBXKeyLength.legacyEVMAddress
    let _blockRange: Range<Int> = _addressRange.endIndex..<_addressRange.upperBound+MDBXKeyLength.block
    let _directionRange: Range<Int> = _blockRange.endIndex..<_blockRange.upperBound+MDBXKeyLength.direction
    let _nonceRange: Range<Int> = _directionRange.endIndex..<_directionRange.upperBound+MDBXKeyLength.nonce
    let _orderRange: Range<Int> = _nonceRange.endIndex..<key.count
    let _sortingKeyRange: PartialRangeFrom<Int> = (MDBXKeyLength.chain+MDBXKeyLength.legacyEVMAddress)...
    
    self.chain = {
      return MDBXChain(rawValue: data[_chainRange])
    }()
    
    self.address = {
      return Address(rawValue: data[_addressRange].hexString)
    }()
    
    self.block = {
      let value = data.subdata(in: _blockRange).withUnsafeBytes { $0.load(as: UInt64.self) }
      return UInt64(bigEndian: value)
    }()
    
    self.direction = {
      let value = data.subdata(in: _directionRange).withUnsafeBytes { $0.load(as: UInt8.self) }
      return Transfer.Direction(rawValue: UInt8(bigEndian: value)) ?? .incoming
    }()
    
    self.nonce = {
      let value = data.subdata(in: _nonceRange).withUnsafeBytes { $0.load(as: UInt64.self) }
      return UInt64(bigEndian: value)
    }()
    
    self.order = {
      let value = data.subdata(in: _orderRange).withUnsafeBytes { $0.load(as: UInt16.self) }
      return UInt16(bigEndian: value)
    }()
    
    self.sortingKey = {
      return data[_sortingKeyRange]
    }()
  }
}

// MARK: - TransferKey + Range

extension TransferKey {
  public static func range(chain: MDBXChain, address: Address, limit: UInt? = nil) -> MDBXKeyRange {
    let start = TransferKey(chain: chain, address: address, lowerRange: true)
    let end = TransferKey(chain: chain, address: address, lowerRange: false)
    return MDBXKeyRange(start: start, end: end, limit: limit)
  }
}
