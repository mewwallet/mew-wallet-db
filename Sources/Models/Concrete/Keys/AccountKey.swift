//
//  File.swift
//  
//
//  Created by Mikhail Nikanorov on 6/7/22.
//

import Foundation
import CryptoKit

public final class AccountKey: MDBXKey {
  
  // MARK: - Public
  
  public let key: Data
  public var chain: MDBXChain { return MDBXChain(rawValue: self._chain) }
  public var order: UInt16 { return self._order }
  public var address: String { return self._address }
  
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
  
  private lazy var _addressRange: Range<Int> = { _orderRange.endIndex..<key.count }()
  private lazy var _address: String = {
    return key[_addressRange].hexString
  }()
  
  // MARK: - Lifecycle
  
  public init(chain: MDBXChain, order: UInt16, address: Address) {
    let chainPart     = chain.rawValue.setLengthLeft(MDBXKeyLength.chain)
    let orderPart     = withUnsafeBytes(of: order.bigEndian) { Data($0) }.setLengthLeft(MDBXKeyLength.order)
    let addressPart   = Data(hex: address.rawValue).setLengthLeft(MDBXKeyLength.address)
    
    self.key = chainPart + orderPart + addressPart
  }
  
  init?(data: Data) {
    guard data.count == MDBXKeyLength.account else { return nil }
    self.key = data
  }
}
