//
//  File.swift
//  
//
//  Created by Mikhail Nikanorov on 3/5/22.
//

import Foundation
import mew_wallet_ios_extensions

/// Chain + Order + ContractAddress
public final class OrderedDexItemKey: MDBXKey {
  
  // MARK: - Public
  
  public let key: Data
  
  public var chain: MDBXChain { return MDBXChain(rawValue: self._chain) }
  public var order: UInt16 { return self._order }
  public var contractAddress: Address { return self._contractAddress }
  
  // MARK: - Private
  
  private lazy var _chainRange: Range<Int> = { 0..<MDBXKeyLength.chain }()
  private lazy var _chain: Data = {
    return key[_chainRange]
  }()
  
  private lazy var _orderRange: Range<Int> = { _chainRange.endIndex..<_chainRange.upperBound+MDBXKeyLength.order }()
  private lazy var _order: UInt16 = {
    let value = key[_orderRange].withUnsafeBytes { $0.load(as: UInt16.self) }
    return UInt16(bigEndian: value)
  }()
  
  private lazy var _contractAddressRange: Range<Int> = { _orderRange.endIndex..<key.count }()
  private lazy var _contractAddress: Address = {
    return Address(rawValue: key[_contractAddressRange].hexString)
  }()
  
  // MARK: - Lifecycle
  
  public init(chain: MDBXChain, order: UInt16, contractAddress: Address) {
    let chainPart           = chain.rawValue.setLengthLeft(MDBXKeyLength.chain)
    let orderPart           = withUnsafeBytes(of: order.bigEndian) { Data($0) }.setLengthLeft(MDBXKeyLength.order)
    let contractAddressPart = Data(hex: contractAddress.rawValue).setLengthLeft(MDBXKeyLength.address)
    
    self.key = chainPart + orderPart + contractAddressPart
  }
  
  public init?(data: Data) {
    guard data.count == MDBXKeyLength.orderedDexItem else { return nil }
    self.key = data
  }
}

// MARK: - OrderedDexItemKey + Sendable

extension OrderedDexItemKey: @unchecked Sendable {}
