//
//  File.swift
//  mew-wallet-db
//
//  Created by Mikhail Nikanorov on 5/13/25.
//

import Foundation

extension Transfer.Direction: MDBXKeyComponent {
  init(encodedData: Data) throws(DataReaderError) {
    let encoded: UInt8 = try encodedData.readBE()
    self = .init(rawValue: encoded) ?? .`self`
  }
  
  var encodedData: Data {
    self.rawValue.encodedData
  }
}
