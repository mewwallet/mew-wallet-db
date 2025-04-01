//
//  File.swift
//  
//
//  Created by Mikhail Nikanorov on 3/21/22.
//

import Foundation
import mew_wallet_ios_extensions

public final class TokenKey: MDBXKey {
  
  // MARK: - Public
  
  public let key: Data
  public let chain: MDBXChain
  public let address: Address
  public let contractAddress: Address
  
  // MARK: - Lifecycle
  
  public init(chain: MDBXChain, address: Address, contractAddress: Address) {
    let coder = MDBXKeyCoder()
    
    self.key = coder.encode(fields: [
      chain,
      address,
      contractAddress
    ])
        
    self.chain = chain
    self.address = address
    self.contractAddress = contractAddress
  }
  
  public init(chain: MDBXChain, address: Address, lowerRange: Bool) {
    let coder = MDBXKeyCoder()
    let rangeData = Data([lowerRange ? 0x00 : 0xFF])
    
    self.key = coder.encode(fields: [
      chain,
      address,
      rangeData
    ])
    
    self.chain = chain
    self.address = address
    self.contractAddress = .invalid(rangeData.hexString)
  }
  
  public init?(data: Data) {
    self.key = data
    
    let coder = MDBXKeyCoder()
    let decoded = coder.decode(data: data, fields: [
      .chain,
      .address,
      .address
    ])
    
    self.chain = decoded[0] as! MDBXChain
    self.address = decoded[1] as! Address
    self.contractAddress = decoded[2] as! Address
  }
}

// MARK: - TokenKey + Range

extension TokenKey {
  public static func range(chain: MDBXChain, address: Address) -> MDBXKeyRange {
    let start = TokenKey(chain: chain, address: address, lowerRange: true)
    let end = TokenKey(chain: chain, address: address, lowerRange: false)
    return MDBXKeyRange(start: start, end: end, limit: nil)
  }
}
