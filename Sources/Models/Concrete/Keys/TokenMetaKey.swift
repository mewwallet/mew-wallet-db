//
//  File.swift
//  
//
//  Created by Mikhail Nikanorov on 3/4/22.
//

import Foundation
import mew_wallet_ios_extensions

public final class TokenMetaKey: MDBXKey {
  // MARK: - Public
  
  public let key: Data
  public let chain: MDBXChain
  public let contractAddress: Address
  
  // MARK: - Lifecycle
  
  public init(chain: MDBXChain, contractAddress: Address) {
    let coder = MDBXKeyCoder()
    
    self.key = coder.encode(fields: [
      chain,
      contractAddress
    ])
    
    self.chain = chain
    self.contractAddress = contractAddress
  }
  
  public init(chain: MDBXChain, lowerRange: Bool) {
    let rangeData = Data([lowerRange ? 0x00 : 0xFF])
    
    let coder = MDBXKeyCoder()
    
    self.key = coder.encode(fields: [
      chain,
      rangeData
    ])
    
    self.chain = chain
    self.contractAddress = .invalid(rangeData.hexString)
  }
  
  public init?(data: Data) {
    self.key = data
    
    let coder = MDBXKeyCoder()
    let decoded = coder.decode(data: data, fields: [
      .chain,
      .address
    ])
    
    self.chain = decoded[0] as! MDBXChain
    self.contractAddress = decoded[1] as! Address
  }
}

// MARK: - TokenMetaKey + Range

extension TokenMetaKey {
  public static func range(chain: MDBXChain, limit: UInt? = nil) -> MDBXKeyRange {
    let start = TokenMetaKey(chain: chain, lowerRange: true)
    let end = TokenMetaKey(chain: chain, lowerRange: false)
    
    return MDBXKeyRange(start: start, end: end, limit: limit)
  }
}
