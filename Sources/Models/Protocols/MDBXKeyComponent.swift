//
//  File.swift
//  mew-wallet-db
//
//  Created by Mikhail Nikanorov on 4/1/25.
//

import Foundation

protocol MDBXKeyComponent {
  init(encodedData: Data) throws(DataReaderError)
  var encodedData: Data { get }
}
