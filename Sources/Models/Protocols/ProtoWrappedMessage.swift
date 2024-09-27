//
//  File.swift
//  
//
//  Created by Mikhail Nikanorov on 3/5/22.
//

import Foundation

// MARK: - ProtoWrappedMessage

protocol ProtoWrappedMessage: Sendable {
  associatedtype T: Sendable
  func wrapped(_ chain: MDBXChain) -> T
}
