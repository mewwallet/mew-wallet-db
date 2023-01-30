//
//  File.swift
//  
//
//  Created by Mikhail Nikanorov on 12/28/22.
//

import Foundation
import mew_wallet_ios_extensions

public final class TransferStableKey: MDBXKey {
  // MARK: - Public
  
  public let key: Data
  public var chain: MDBXChain { MDBXChain(rawValue: _chain) }
  public var address: Address { _address }
  public var direction: Transfer.Direction { Transfer.Direction(rawValue: _direction) ?? .incoming }
  public var nonce: UInt64 { _nonce }
  public var order: UInt16 { _order }
  
  // MARK: - Private
  
  private lazy var _chainRange: Range<Int> = { 0..<MDBXKeyLength.chain }()
  private lazy var _chain: Data = {
    return key[_chainRange]
  }()
  
  private lazy var _addressRange: Range<Int> = { _chainRange.endIndex..<_chainRange.upperBound+MDBXKeyLength.address }()
  private lazy var _address: Address = {
    return Address(rawValue: key[_addressRange].hexString)
  }()
  
  private lazy var _directionRange: Range<Int> = { _addressRange.endIndex..<_addressRange.upperBound+MDBXKeyLength.direction }()
  private lazy var _direction: UInt8 = {
    let value = key[_directionRange].withUnsafeBytes { $0.load(as: UInt8.self) }
    return UInt8(bigEndian: value)
  }()
  
  private lazy var _nonceRange: Range<Int> = { _directionRange.endIndex..<_directionRange.upperBound+MDBXKeyLength.nonce }()
  private lazy var _nonce: UInt64 = {
    let value = key[_nonceRange].withUnsafeBytes { $0.load(as: UInt64.self) }
    return UInt64(bigEndian: value)
  }()
  
  private lazy var _orderRange: Range<Int> = { _nonceRange.endIndex..<key.count }()
  private lazy var _order: UInt16 = {
    let value = Data(key[_orderRange]).withUnsafeBytes { $0.load(as: UInt16.self) }
    return UInt16(bigEndian: value)
  }()
  
  // MARK: - Lifecycle
  
  public init(chain: MDBXChain, address: Address, direction: Transfer.Direction, nonce: UInt64, order: UInt16) {
    let chainPart           = chain.rawValue.setLengthLeft(MDBXKeyLength.chain)
    let addressPart         = Data(hex: address.rawValue).setLengthLeft(MDBXKeyLength.address)
    let directionPart       = withUnsafeBytes(of: direction.rawValue.bigEndian) { Data($0) }.setLengthLeft(MDBXKeyLength.direction)
    let noncePart           = withUnsafeBytes(of: nonce.bigEndian) { Data($0) }.setLengthLeft(MDBXKeyLength.nonce)
    let orderPart           = withUnsafeBytes(of: order.bigEndian) { Data($0) }.setLengthLeft(MDBXKeyLength.order)
    
    self.key = chainPart + addressPart + directionPart + noncePart + orderPart
  }
  
  public init(chain: MDBXChain, address: Address, lowerRange: Bool) {
    let chainPart           = chain.rawValue.setLengthLeft(MDBXKeyLength.chain)
    let addressPart         = Data(hex: address.rawValue).setLengthLeft(MDBXKeyLength.address)

    let directionPart: Data
    let noncePart: Data
    let orderPart: Data
    if lowerRange {
      directionPart = Data().setLengthLeft(MDBXKeyLength.direction)
      noncePart     = Data().setLengthLeft(MDBXKeyLength.nonce)
      orderPart     = Data().setLengthLeft(MDBXKeyLength.order)
    } else {
      directionPart = Data(repeating: 0xFF, count: MDBXKeyLength.direction)
      noncePart     = Data(repeating: 0xFF, count: MDBXKeyLength.nonce)
      orderPart     = Data(repeating: 0xFF, count: MDBXKeyLength.order)
    }
    self.key = chainPart + addressPart + directionPart + noncePart + orderPart
  }
  
  public init?(data: Data) {
    guard data.count == MDBXKeyLength.transferStable else { return nil }
    self.key = data
  }
}

// MARK: - TransferStableKey + Range

extension TransferStableKey {
  public static func range(chain: MDBXChain, address: Address, limit: UInt? = nil) -> MDBXKeyRange {
    let start = TransferStableKey(chain: chain, address: address, lowerRange: true)
    let end = TransferStableKey(chain: chain, address: address, lowerRange: false)
    return MDBXKeyRange(start: start, end: end, limit: limit)
  }
}
