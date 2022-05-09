//
//  File.swift
//  
//
//  Created by Mikhail Nikanorov on 5/5/22.
//

import Foundation

extension Data {
  init(hex: String) {
    self.init(Array<UInt8>(hex: hex))
  }

  var bytes: Array<UInt8> {
    Array(self)
  }
  
  var hexString: String {
    self.bytes.hexString
  }
}
