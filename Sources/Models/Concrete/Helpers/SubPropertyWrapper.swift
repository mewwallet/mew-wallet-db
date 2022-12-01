//
//  File.swift
//  
//
//  Created by Mikhail Nikanorov on 7/7/22.
//

import Foundation
import SwiftProtobuf

@propertyWrapper
final class SubProperty<Value: ProtoWrappedMessage, ProjectedValue: MDBXBackedObject> {
  weak var database: WalletDB?
  var chain: MDBXChain
  var wrappedValue: Value?
  lazy var projectedValue: ProjectedValue? = {
    var projected = wrappedValue?.wrapped(chain) as? ProjectedValue
    projected?.database = self.database
    return projected
  }()
  
  init(wrappedValue: Value?, chain: MDBXChain) {
    self.wrappedValue = wrappedValue
    self.chain = chain
  }
  
  convenience init() {
    self.init(wrappedValue: nil, chain: .invalid)
  }
  
  // MARK: - Refreshed
  
  internal func refreshProjected(wrapped: Value?) {
    wrappedValue = wrapped
    var projected = wrappedValue?.wrapped(chain) as? ProjectedValue
    projected?.database = self.database
    self.projectedValue = projected
  }
}

extension Optional: ProtoWrappedMessage {
  typealias T = Any?
  func wrapped(_ chain: MDBXChain) -> Any? {
    return nil
  }
}

// MARK: - SubProperty + Sendable

extension SubProperty: @unchecked Sendable {}
