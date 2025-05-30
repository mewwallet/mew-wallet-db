//
//  File.swift
//  
//
//  Created by Mikhail Nikanorov on 10/3/22.
//

import Foundation
import mew_wallet_ios_extensions

extension HistorySwap {
  public final class Key: MDBXKey {
    
    // MARK: - Public
    
    public let key: Data
    public let chain: MDBXChain
    public let address: Address
    public let hash: String
    
    // MARK: - Lifecycle
    
    public init(chain: MDBXChain, account: Address, hash: String) {
      let coder = MDBXKeyCoder()
      
      self.key = coder.encode(fields: [
        chain,
        account,
        Data(hex: hash)
      ])
      
      self.chain = chain
      self.address = account
      self.hash = hash
    }
    
    public init(chain: MDBXChain, address: Address?, lowerRange: Bool) {
      let coder = MDBXKeyCoder()
      
      let rangeData = Data([lowerRange ? 0x00 : 0xFF])
      if let address {
        self.key = coder.encode(fields: [
          chain,
          address,
          rangeData
        ])
      } else {
        self.key = coder.encode(fields: [
          chain,
          rangeData
        ])
      }
      
      self.chain = chain
      
      self.address = address ?? .invalid(rangeData.hexString)
      self.hash = rangeData.hexString
    }
    
    public init?(data: Data) {
      do {
        let coder = MDBXKeyCoder()
        
        let decoded = try coder.decode(data: data, fields: [
          .chain,
          .address,
          .rawData(count: MDBXKeyLength.hash)
        ])
        
        self.key = data
        self.chain = decoded[0] as! MDBXChain
        self.address = decoded[1] as! Address
        self.hash = (decoded[2] as! Data).hexString
      } catch {
        return nil
      }
    }
  }
}

// MARK: - HistorySwap.Key + Range

extension HistorySwap.Key {
  public static func range(chain: MDBXChain, address: Address? = nil) -> MDBXKeyRange {
    let start = HistorySwap.Key(chain: chain, address: address, lowerRange: true)
    let end = HistorySwap.Key(chain: chain, address: address, lowerRange: false)
    return MDBXKeyRange(start: start, end: end, limit: nil)
  }
}
