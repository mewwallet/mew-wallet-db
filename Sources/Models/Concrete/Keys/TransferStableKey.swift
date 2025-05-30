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
  public let chain: MDBXChain
  public let address: Address
  public let direction: Transfer.Direction
  public let nonce: UInt64
  public let order: UInt16
  
  // MARK: - Lifecycle
  
  public init(chain: MDBXChain, address: Address, direction: Transfer.Direction, nonce: UInt64, order: UInt16) {
    let coder = MDBXKeyCoder()
    
    self.key = coder.encode(fields: [
      chain,
      address,
      direction,
      nonce,
      order
    ])
    
    self.chain = chain
    self.address = address
    self.direction = direction
    self.nonce = nonce
    self.order = order
  }
  
  public init(chain: MDBXChain, address: Address, lowerRange: Bool) {
    let coder = MDBXKeyCoder()

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
    
    self.key = coder.encode(fields: [
      chain,
      address,
      directionPart,
      noncePart,
      orderPart
    ])
    
    self.chain = chain
    self.address = address
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
        .direction,
        .nonce,
        .order
      ])
      
      self.chain = decoded[0] as! MDBXChain
      self.address = decoded[1] as! Address
      self.direction = decoded[2] as! Transfer.Direction
      self.nonce = decoded[3] as! UInt64
      self.order = decoded[4] as! UInt16
    } catch {
      return nil
    }
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
