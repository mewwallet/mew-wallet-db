//
//  File.swift
//  
//
//  Created by Nail Galiaskarov on 6/23/21.
//

import Foundation
import MEWextensions

public class TransferKey: MDBXKey {
  public var projectId: Data {
    return key[0..<MDBXKeyLength.projectId]
  }
  
  public var address: Data {
    let startIndex = MDBXKeyLength.projectId
    let endIndex = startIndex + MDBXKeyLength.address
    return key[startIndex..<endIndex]
  }
  
  public var blockNumber: Decimal {
    let startIndex = MDBXKeyLength.projectId + MDBXKeyLength.address
    let endIndex = startIndex + MDBXKeyLength.blockNumber

    let data = key[startIndex..<endIndex]
    return Decimal(hex: data.hexString)
  }
  
  public var direction: Data {
    let startIndex = MDBXKeyLength.projectId + MDBXKeyLength.address + MDBXKeyLength.blockNumber
    let endIndex = startIndex + MDBXKeyLength.direction
    return key[startIndex..<endIndex]
  }
  
  public var nonce: Decimal {
    let startIndex = MDBXKeyLength.projectId + MDBXKeyLength.address + MDBXKeyLength.blockNumber + MDBXKeyLength.direction
    let endIndex = startIndex + MDBXKeyLength.nonce
    let data = key[startIndex..<endIndex]
    return Decimal(hex: data.hexString)
  }
  
  public var order: UInt8 {
    let startIndex = MDBXKeyLength.projectId + MDBXKeyLength.address + MDBXKeyLength.blockNumber + MDBXKeyLength.direction + MDBXKeyLength.nonce
    let endIndex = startIndex + MDBXKeyLength.order
    let data = key[startIndex..<endIndex]
    return data[0]
  }
  
  public let key: Data
    
  public init(
    projectId: MDBXProjectId,
    address: Data,
    blockNumber: Decimal,
    direction: UInt8,
    nonce: Decimal,
    order: UInt8 = 0
  ) {
    let paddedProjectId = projectId.rawValue.setLengthLeft(MDBXKeyLength.projectId)
    let paddedAddress = address.setLengthLeft(MDBXKeyLength.address)
    let paddedDirection = Data([direction]).setLengthLeft(MDBXKeyLength.direction)
    let paddedBlockNumber = Data(hex: blockNumber.hexString).setLengthLeft(MDBXKeyLength.blockNumber)
    let paddedNonce = Data(hex: nonce.hexString).setLengthLeft(MDBXKeyLength.nonce)
    let paddedOrder = Data([order]).setLengthLeft(MDBXKeyLength.order)
    
    self.key = paddedProjectId + paddedAddress + paddedBlockNumber + paddedDirection + paddedNonce + paddedOrder
  }
  
  public init?(key: Data) {
    guard key.count == MDBXKeyLength.transfer else {
      return nil
    }
    
    self.key = key
  }
}
