//
//  File.swift
//  
//
//  Created by Mikhail Nikanorov on 6/9/21.
//

import Foundation
import OSLog

extension Data: MDBXKey {
  public var chain: MDBXChain {
    guard self.count > MDBXKeyLength.chain else {
      os_log("Warning: invalid key", log: .error(.read), type: .fault)
      return .invalid
    }
    return MDBXChain(rawValue: self[0..<MDBXKeyLength.chain])
  }
  
  public var key: Data {
    return self
  }  
}
