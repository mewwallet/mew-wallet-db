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
  public let chain: MDBXChain = .evm
  public let order: UInt16
  
  // MARK: - Lifecycle
  
  public init(order: UInt16) {
    let chainPart           = MDBXChain.evm.rawValue.setLengthLeft(MDBXKeyLength.chain)
    let orderPart           = withUnsafeBytes(of: order.bigEndian) { Data($0) }.setLengthLeft(MDBXKeyLength.order)
    
    let key = chainPart + orderPart
    self.key = key
    
    let _chainRange: Range<Int> = 0..<MDBXKeyLength.chain
    let _orderRange: Range<Int> = _chainRange.endIndex..<_chainRange.upperBound+MDBXKeyLength.order
    
    self.order = {
      let value = key.subdata(in: _orderRange).withUnsafeBytes { $0.load(as: UInt16.self) }
      return UInt16(bigEndian: value)
    }()
  }
  
  public init?(data: Data) {
    guard data.count == MDBXKeyLength.dAppRecordReference else { return nil }
    self.key = data
    
    let _chainRange: Range<Int> = 0..<MDBXKeyLength.chain
    let _orderRange: Range<Int> = _chainRange.endIndex..<_chainRange.upperBound+MDBXKeyLength.order
    
    self.order = {
      let value = data.subdata(in: _orderRange).withUnsafeBytes { $0.load(as: UInt16.self) }
      return UInt16(bigEndian: value)
    }()
  }
}
