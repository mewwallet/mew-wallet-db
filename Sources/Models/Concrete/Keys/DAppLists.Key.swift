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
    
    public lazy var key: Data = {
      let chainPart           = chain.rawValue.setLengthLeft(MDBXKeyLength.chain)
      let dataPart            = data
      
      return chainPart + dataPart
    }()
    public var chain: MDBXChain { .universal }
    public var data: Data { Data(hex: "0x6c69737473") } // lists
    
    // MARK: - Lifecycle
    
    public init() { }
    
    public init?(data: Data) {
      guard data.count == MDBXKeyLength.dAppLists else { return nil }
      self.key = data
    }
  }
}
