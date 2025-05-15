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

    let rangeData = Data(lowerRange ? [0x00] : [0xFF])
    
    self.key = coder.encode(fields: [
      chain,
      address,
      rangeData, // block part
      rangeData, // direction part
      rangeData, // nonce part
      rangeData, // order part
      rangeData  // contract address
    ])
    
    self.sortingKey = coder.encode(fields: [
      rangeData, // block part
      rangeData, // nonce part
      rangeData, // direction part
      rangeData  // order part
    ])
    
    self.chain = chain
    self.address = address
    self.block = .zero
    self.direction = .`self`
    self.nonce = 0
    self.order = 0
    self.contractAddress = .unknown(.unknown, rangeData.hexString)
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
