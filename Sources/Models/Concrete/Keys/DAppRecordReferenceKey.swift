//
//  File.swift
//  
//
//  Created by Mikhail Nikanorov on 5/5/22.
//

import Foundation

public final class DAppRecordReferenceKey: MDBXKey {
  
  // MARK: - Public
  
  public let key: Data
  public var chain: MDBXChain { .universal }
  public var order: UInt16 { return self._order }
  
  // MARK: - Private
  
  private lazy var _chainRange: Range<Int> = { 0..<MDBXKeyLength.chain }()
  
  private lazy var _orderRange: Range<Int> = { _chainRange.endIndex..<_chainRange.upperBound+MDBXKeyLength.order }()
  private lazy var _order: UInt16 = {
    let value = key[_orderRange].withUnsafeBytes { $0.load(as: UInt16.self) }
    return UInt16(bigEndian: value)
  }()
  
  // MARK: - Lifecycle
  
  public init(order: UInt16) {
    let chainPart           = MDBXChain.universal.rawValue.setLengthLeft(MDBXKeyLength.chain)
    let orderPart           = withUnsafeBytes(of: order.bigEndian) { Data($0) }.setLengthLeft(MDBXKeyLength.order)
    
    self.key = chainPart + orderPart
  }
  
  public init?(data: Data) {
    guard data.count == MDBXKeyLength.dAppRecordReference else { return nil }
    self.key = data
  }
}

// MARK: - DAppRecordReferenceKey + Sendable

extension DAppRecordReferenceKey: @unchecked Sendable {}
