//
//  File.swift
//  mew-wallet-db
//
//  Created by Mikhail Nikanorov on 9/27/24.
//

import Foundation
import mew_wallet_ios_extensions

extension PurchaseToken {
  public final class Key: MDBXKey {

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

    public init?(data: Data) {
      do {
        self.key = data
        
        let coder = MDBXKeyCoder()
        let decoded = try coder.decode(data: data, fields: [
          .chain,
          .address
        ])
        
        self.chain = decoded[0] as! MDBXChain
        self.contractAddress = decoded[1] as! Address
      } catch {
        return nil
      }
    }

    public init(chain: MDBXChain, lowerRange: Bool) {
      let coder = MDBXKeyCoder()
      let rangeData = Data([lowerRange ? 0x00 : 0xFF])
      
      self.key = coder.encode(fields: [
        chain,
        rangeData
      ])
      
      self.chain = chain
      self.contractAddress = .invalid(rangeData.hexString)
    }
  }
}

// MARK: - PurchaseToken.Key + Range

extension PurchaseToken.Key {
  public static func range(chain: MDBXChain, limit: UInt? = nil) -> MDBXKeyRange {
    let start = PurchaseToken.Key(chain: chain, lowerRange: true)
    let end = PurchaseToken.Key(chain: chain, lowerRange: false)
    return MDBXKeyRange(start: start, end: end, limit: limit)
  }
}
