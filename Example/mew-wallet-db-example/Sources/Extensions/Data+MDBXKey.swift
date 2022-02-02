//
//  File.swift
//  
//
//  Created by Mikhail Nikanorov on 6/9/21.
//

import Foundation

extension Data: MDBXKey {
  public var key: Data {
    return self
  }  
}
