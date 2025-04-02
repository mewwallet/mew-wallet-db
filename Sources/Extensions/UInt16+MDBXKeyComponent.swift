//
//  File.swift
//  mew-wallet-db
//
//  Created by Mikhail Nikanorov on 4/1/25.
//

import Foundation

extension UInt16: MDBXKeyComponent {
  public init(encodedData: Data) {
    let value = encodedData.withUnsafeBytes { $0.loadUnaligned(as: UInt16.self) }
    self = UInt16(bigEndian: value)
  }
  
  public var encodedData: Data {
    return withUnsafeBytes(of: self.bigEndian) { Data($0) }.setLengthLeft(MDBXKeyLength.order)
  }
}
