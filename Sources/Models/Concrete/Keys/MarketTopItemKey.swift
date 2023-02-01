//
//  File.swift
//  
//
//  Created by macbook on 29.01.2023.
//

import Foundation

public final class MarketTopItemKey: MDBXKey {
  public var key: Data
  
  public var chain: MDBXChain
  
  // TODO: discuss the keys
  public init?(data: Data) {
    self.chain = .universal
    self.key = data
  }
}
