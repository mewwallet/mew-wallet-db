//
//  File.swift
//  mew-wallet-db
//
//  Created by Mikhail Nikanorov on 5/13/25.
//

import Foundation

extension UInt64: MDBXKeyComponent {
  init(encodedData: Data) throws(DataReaderError) {
    let value = encodedData.withUnsafeBytes { $0.loadUnaligned(as: UInt64.self) }
    self = UInt64(bigEndian: value)
  }
  
  var encodedData: Data {
    return withUnsafeBytes(of: self.bigEndian) { Data($0) }.setLengthLeft(MDBXKeyLength.block)
  }
}
