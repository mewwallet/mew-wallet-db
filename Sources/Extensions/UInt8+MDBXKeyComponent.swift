//
//  File.swift
//  mew-wallet-db
//
//  Created by Mikhail Nikanorov on 5/13/25.
//

import Foundation

extension UInt8: MDBXKeyComponent {
  init(encodedData: Data) throws(DataReaderError) {
    let value = encodedData.withUnsafeBytes { $0.loadUnaligned(as: UInt8.self) }
    self = UInt8(bigEndian: value)
  }
  
  var encodedData: Data {
    return withUnsafeBytes(of: self.bigEndian) { Data($0) }
  }
}
