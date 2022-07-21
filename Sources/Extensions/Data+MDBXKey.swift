//
//  File.swift
//  
//
//  Created by Mikhail Nikanorov on 6/9/21.
//

import Foundation
import os

extension Data: MDBXKey {
  public var chain: MDBXChain {
    guard self.count >= MDBXKeyLength.chain else {
      Logger.critical(service: .read, "Warning: invalid key")
      return .invalid
    }
    return MDBXChain(rawValue: self[0..<MDBXKeyLength.chain])
  }
  
  public var key: Data {
    return self
  }  
}
