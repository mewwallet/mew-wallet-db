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
      let chainPart           = MDBXChain.evm.rawValue.setLengthLeft(MDBXKeyLength.chain)
      let dataPart            = self.data
      
      self.key = chainPart + dataPart
    }
    
    public init?(data: Data) {
      guard data.count == MDBXKeyLength.dAppLists else { return nil }
      self.key = data
    }
  }
}
