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
  public let contractAddress: Address
  
  // MARK: - Lifecycle
  
  public init(chain: MDBXChain, address: Address, block: UInt64, direction: Transfer.Direction, nonce: UInt64, order: UInt16, contractAddress: Address) {
    let coder = MDBXKeyCoder()
    
    self.key = coder.encode(fields: [
      chain,
      address,
      block,
      direction,
      nonce,
      order,
      contractAddress
    ])
    
    self.sortingKey = coder.encode(fields: [
      block,
      nonce,
      direction,
      order
    ])
    
    self.chain = chain
    self.address = address
    self.block = block
    self.direction = direction
    self.nonce = nonce
    self.order = order
    self.contractAddress = contractAddress
  }
  
  public init(chain: MDBXChain, address: Address, lowerRange: Bool) {
    let coder = MDBXKeyCoder()

    let blockPart: Data
    let directionPart: Data
    let noncePart: Data
    let orderPart: Data
    let contractAddressPart: Data
    if lowerRange {
      blockPart               = Data().setLengthLeft(MDBXKeyLength.block)
      directionPart           = Data().setLengthLeft(MDBXKeyLength.direction)
      noncePart               = Data().setLengthLeft(MDBXKeyLength.nonce)
      orderPart               = Data().setLengthLeft(MDBXKeyLength.order)
      contractAddressPart     = Data().setLengthLeft(MDBXKeyLength.legacyEVMAddress)
      self.contractAddress = .init(rawValue: "0x0000000000000000000000000000000000000000")
    } else {
      blockPart               = Data(repeating: 0xFF, count: MDBXKeyLength.block)
      directionPart           = Data(repeating: 0xFF, count: MDBXKeyLength.direction)
      noncePart               = Data(repeating: 0xFF, count: MDBXKeyLength.nonce)
      orderPart               = Data(repeating: 0xFF, count: MDBXKeyLength.order)
      contractAddressPart     = Data(repeating: 0xFF, count: MDBXKeyLength.legacyEVMAddress)
      self.contractAddress = .init(rawValue: "0xffffffffffffffffffffffffffffffffffffffff")
    }
    
    self.key = coder.encode(fields: [
      chain,
      address,
      blockPart,
      directionPart,
      noncePart,
      orderPart,
      contractAddressPart
    ])
    
    self.sortingKey = coder.encode(fields: [
      blockPart,
      noncePart,
      directionPart,
      orderPart
    ])
    
    self.chain = chain
    self.address = address
    self.block = .zero
    self.direction = .`self`
    self.nonce = 0
    self.order = 0
  }
  
  public init?(data: Data) {
    self.key = data
    
    do {
      let coder = MDBXKeyCoder()
      let decoded = try coder.decode(data: data, fields: [
        .chain,
        .address,
        .block,
        .direction,
        .nonce,
        .order,
        .legacyAddress
      ])
      
      self.chain = decoded[0] as! MDBXChain
      self.address = decoded[1] as! Address
      self.block = decoded[2] as! UInt64
      self.direction = decoded[3] as! Transfer.Direction
      self.nonce = decoded[4] as! UInt64
      self.order = decoded[5] as! UInt16
      self.contractAddress = decoded[6] as! Address
      
      self.sortingKey = coder.encode(fields: [
        self.block,
        self.nonce,
        self.direction,
        self.order
      ])
    } catch {
      return nil
    }
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
