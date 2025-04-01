//
//  File.swift
//  mew-wallet-db
//
//  Created by Mikhail Nikanorov on 4/1/25.
//

import Foundation

extension Data: MDBXKeyComponent {
  public init(encodedData: Data) {
    self = encodedData
  }
  
  public var encodedData: Data {
    return self
  }
}
