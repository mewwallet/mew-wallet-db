//
//  File.swift
//  
//
//  Created by Mikhail Nikanorov on 7/8/22.
//

import Foundation

extension Array: MDBXBackedObject where Element: MDBXBackedObject {
  public var database: WalletDB? {
    get { nil }
    set {
      for i in 0..<self.count {
        self[i].database = newValue
      }
    }
  }
}
