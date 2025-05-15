//
//  File.swift
//  
//
//  Created by Mikhail Nikanorov on 6/7/22.
//

import Foundation
import CryptoKit

public final class AccountKey: MDBXKey {
  
  // MARK: - Public
  
  public let key: Data
  public let chain: MDBXChain
  public let address: String
  
  // MARK: - Lifecycle
  
  public convenience init(address: Address) {
    self.init(chain: address.networkChain, address: address)
  }
  
  public init(chain: MDBXChain, address: Address) {
    let coder = MDBXKeyCoder()
    
    self.key = coder.encode(fields: [
      chain,
      address
    ])
    
    self.chain = chain
    self.address = address.rawValue
  }
  
  public init?(data: Data) {
    do {
      self.key = data
      
      let coder = MDBXKeyCoder()
      
      let decoded = try coder.decode(data: data, fields: [
        .network,
        .address
      ])
      self.chain = decoded[0] as! MDBXChain
      self.address = (decoded[1] as! Address).rawValue
    } catch {
      return nil
    }
  }
}

// MARK: - AccountKey + Equatable

extension AccountKey: Equatable {
  public static func == (lhs: AccountKey, rhs: AccountKey) -> Bool { lhs.key == rhs.key }
}

extension AccountKey: Hashable {
  public func hash(into hasher: inout Hasher) {
    hasher.combine(key)
  }
}
