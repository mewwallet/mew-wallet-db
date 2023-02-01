//
//  File.swift
//  
//
//  Created by macbook on 1.02.2023.
//

import Foundation

public final class MarketCollectionItemKey: MDBXKey {
  public var key: Data
  
  public var chain: MDBXChain
  
  // TODO: discuss the keys
  public init?(data: Data) {
    self.chain = .universal
    self.key = data
  }
}
