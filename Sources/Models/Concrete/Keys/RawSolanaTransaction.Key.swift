//
//  RawSolanaTransaction.Key.swift
//  mew-wallet-db
//
//  Created by Mitya on 29/08/2025.
//

import Foundation
import mew_wallet_ios_extensions

extension RawSolanaTransaction {
  public final class Key: MDBXKey {
    // MARK: - Public
    
    public let key: Data
    public let chain: MDBXChain
    public let signature: String
    
    // MARK: - Lifecycle
    
    public init(chain: MDBXChain, signature: String) {
      let coder = MDBXKeyCoder()
      
      self.key = coder.encode(fields: [
        chain,
        signature.data(using: .utf8)!
      ])
      
      self.chain = chain
      self.signature = signature
    }
    
    public init?(data: Data) {
      do {
        let coder = MDBXKeyCoder()
        let decoded = try coder.decode(data: data, fields: [
          .chain,
          .rawData(count: MDBXKeyLength.signature)
        ])
        self.key = data
        self.chain = decoded[0] as! MDBXChain
        self.signature = String(data: (decoded[1] as! Data), encoding: .utf8)!
      } catch {
        return nil
      }
    }
  }
}
