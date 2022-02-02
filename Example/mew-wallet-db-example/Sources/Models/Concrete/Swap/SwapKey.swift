//
//  File.swift
//  
//
//  Created by Nail Galiaskarov on 6/21/21.
//

import Foundation

public final class SwapKey: MDBXKey {
  public let transactionKey: RawTransactionKey // 48
  public let extra: Data? // 16
  
  public init(transactionKey: RawTransactionKey, extra: Data? = nil) {
    self.transactionKey = transactionKey
    self.extra = extra
  }
  
  public var key: Data {
    return transactionKey.key + (extra ?? Data())
  }
}
