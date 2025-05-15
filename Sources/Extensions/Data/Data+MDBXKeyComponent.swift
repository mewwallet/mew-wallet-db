//
//  File.swift
//  mew-wallet-db
//
//  Created by Mikhail Nikanorov on 4/1/25.
//

import Foundation

extension Data: MDBXKeyComponent {
  init(encodedData: Data) throws(DataReaderError) {
    self = encodedData
  }
  
  public var encodedData: Data {
    return self
  }
}
