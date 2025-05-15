//
//  File.swift
//  mew-wallet-db
//
//  Created by Mikhail Nikanorov on 5/13/25.
//

import Foundation
import mew_wallet_ios_extensions

extension RawBitcoinTransaction {
  public final class Key: MDBXKey {
    // MARK: - Public
    
    public let key: Data
    public let chain: MDBXChain
    public let hash: String
    
    // MARK: - Lifecycle
    
    public init(chain: MDBXChain, hash: String) {
      let coder = MDBXKeyCoder()
      
      self.key = coder.encode(fields: [
        chain,
        Data(hex: hash)
      ])
      
      self.chain = chain
      self.hash = hash
    }
    
    public init?(data: Data) {
      do {
        let coder = MDBXKeyCoder()
        let decoded = try coder.decode(data: data, fields: [
          .chain,
          .rawData(count: MDBXKeyLength.hash)
        ])
        self.key = data
        self.chain = decoded[0] as! MDBXChain
        self.hash = (decoded[1] as! Data).hexString
      } catch {
        return nil
      }
    }
  }
}
