//
//  File.swift
//  
//
//  Created by Mikhail Nikanorov on 3/5/22.
//

import Foundation

protocol ProtoWrappedMessage {
  associatedtype T
  func wrapped(_ chain: MDBXChain) -> T
}
