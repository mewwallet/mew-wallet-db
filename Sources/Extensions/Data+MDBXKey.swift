//
//  File.swift
//  
//
//  Created by Mikhail Nikanorov on 6/9/21.
//

import Foundation

extension Data: MDBXKey {
  public var chain: MDBXChain {
    return MDBXChain(rawValue: self[0..<MDBXKeyLength.chain])
  }
  
  public var key: Data {
    return self
  }  
}
