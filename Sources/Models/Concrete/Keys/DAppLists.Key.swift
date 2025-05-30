//
//  File.swift
//  
//
//  Created by Mikhail Nikanorov on 5/23/23.
//

import Foundation
import mew_wallet_ios_extensions

extension DAppLists {
  public final class Key: MDBXKey {
    // MARK: - Public
    
    public let key: Data
    public let chain: MDBXChain = .evm
    public let data = Data(hex: "0x6c69737473") // lists
    
    // MARK: - Lifecycle
    
    public init() {
      let coder = MDBXKeyCoder()
      
      self.key = coder.encode(fields: [
        MDBXChain.evm,
        self.data
      ])
    }
    
    public init?(data: Data) {
      guard data.count == MDBXKeyLength.dAppLists else { return nil }
      self.key = data
    }
  }
}
