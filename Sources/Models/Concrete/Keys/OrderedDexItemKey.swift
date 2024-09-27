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
  public let chain: MDBXChain
  public let order: UInt16
  public let contractAddress: Address
  
  // MARK: - Lifecycle
  
  public init(chain: MDBXChain, order: UInt16, contractAddress: Address) {
    let chainPart           = chain.rawValue.setLengthLeft(MDBXKeyLength.chain)
    let orderPart           = withUnsafeBytes(of: order.bigEndian) { Data($0) }.setLengthLeft(MDBXKeyLength.order)
    let contractAddressPart = Data(hex: contractAddress.rawValue).setLengthLeft(MDBXKeyLength.address)
    
    let key = chainPart + orderPart + contractAddressPart
    self.key = key
    
    let _chainRange: Range<Int> = 0..<MDBXKeyLength.chain
    let _orderRange: Range<Int> = _chainRange.endIndex..<_chainRange.upperBound+MDBXKeyLength.order
    let _contractAddressRange: Range<Int> = _orderRange.endIndex..<key.count
    
    self.chain = {
      return MDBXChain(rawValue: key[_chainRange])
    }()
    
    self.order = {
      let value = key.subdata(in: _orderRange).withUnsafeBytes { $0.load(as: UInt16.self) }
      return UInt16(bigEndian: value)
    }()
    
    self.contractAddress = {
      return Address(rawValue: key[_contractAddressRange].hexString)
    }()
  }
  
  public init?(data: Data) {
    guard data.count == MDBXKeyLength.orderedDexItem else { return nil }
    self.key = data
    
    let _chainRange: Range<Int> = 0..<MDBXKeyLength.chain
    let _orderRange: Range<Int> = _chainRange.endIndex..<_chainRange.upperBound+MDBXKeyLength.order
    let _contractAddressRange: Range<Int> = _orderRange.endIndex..<key.count
    
    self.chain = {
      return MDBXChain(rawValue: data[_chainRange])
    }()
    
    self.order = {
      let value = data.subdata(in: _orderRange).withUnsafeBytes { $0.load(as: UInt16.self) }
      return UInt16(bigEndian: value)
    }()
    
    self.contractAddress = {
      return Address(rawValue: data[_contractAddressRange].hexString)
    }()
  }
}
