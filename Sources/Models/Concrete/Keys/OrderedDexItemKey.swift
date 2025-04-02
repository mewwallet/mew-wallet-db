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
    let coder = MDBXKeyCoder()
    
    self.key = coder.encode(fields: [
      chain,
      order,
      contractAddress
    ])
    
    self.chain = chain
    self.order = order
    self.contractAddress = contractAddress
  }
  
  public init?(data: Data) {
    do {
      self.key = data
      
      let coder = MDBXKeyCoder()
      
      let decoded = try coder.decode(data: data, fields: [
        .chain,
        .order,
        .address
      ])
      self.chain = decoded[0] as! MDBXChain
      self.order = decoded[1] as! UInt16
      self.contractAddress = decoded[2] as! Address
    } catch {
      return nil
    }
  }
}
