//
//  File.swift
//  mew-wallet-db
//
//  Created by Mikhail Nikanorov on 4/1/25.
//

import Foundation

public protocol MDBXKeyComponent {
  init(encodedData: Data)
  var encodedData: Data { get }
}
