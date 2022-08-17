//
//  File.swift
//  
//
//  Created by Mikhail Nikanorov on 7/8/22.
//

import Foundation

extension Array: ProtoWrappedMessage where Element: ProtoWrappedMessage {
  typealias T = [Element.T]
  
  func wrapped(_ chain: MDBXChain) -> T {
    map { $0.wrapped(chain) }
  }
}
