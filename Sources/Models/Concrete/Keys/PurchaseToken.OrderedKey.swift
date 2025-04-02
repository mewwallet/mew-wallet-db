//
//  File.swift
//  mew-wallet-db
//
//  Created by Mikhail Nikanorov on 10/10/24.
//

import Foundation
import mew_wallet_ios_extensions

extension PurchaseToken {
  public final class OrderedKey: MDBXKey {

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

    public init(chain: MDBXChain, lowerRange: Bool) {
      let coder = MDBXKeyCoder()
      let rangeData = Data([lowerRange ? 0x00 : 0xFF])
      
      self.key = coder.encode(fields: [
        chain,
        rangeData, //2 ranges for order
        rangeData,
        rangeData //1 range for contract address
      ])
      
      self.chain = chain
      self.order = lowerRange ? .min : .max
      self.contractAddress = .invalid(rangeData.hexString)
    }
  }
}

// MARK: - PurchaseToken.OrderedKey + Range

extension PurchaseToken.OrderedKey {
  public static func range(chain: MDBXChain, limit: UInt? = nil) -> MDBXKeyRange {
    let start = PurchaseToken.OrderedKey(chain: chain, lowerRange: true)
    let end = PurchaseToken.OrderedKey(chain: chain, lowerRange: false)
    return MDBXKeyRange(start: start, end: end, limit: limit)
  }
}
