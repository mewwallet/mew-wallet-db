//
//  File.swift
//  
//
//  Created by Nail Galiaskarov on 5/30/21.
//

import Foundation

public protocol MDBXKey: Sendable {
  var key: Data { get }
  var chain: MDBXChain { get }
  init?(data: Data)
}
