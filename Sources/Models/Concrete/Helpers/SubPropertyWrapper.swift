//
//  File.swift
//  
//
//  Created by Mikhail Nikanorov on 7/7/22.
//

import Foundation
import SwiftProtobuf
import mew_wallet_ios_extensions

@propertyWrapper
final class SubProperty<Value: ProtoWrappedMessage, ProjectedValue: MDBXBackedObject>: Sendable {
  private let _chain = ThreadSafe<MDBXChain>(.invalid)
  var chain: MDBXChain {
    get { _chain.value }
    set { _chain.value = newValue }
  }
  private let _wrappedValue = ThreadSafe<Value?>(nil)
  var wrappedValue: Value? {
    get { _wrappedValue.value }
    set { _wrappedValue.value = newValue }
  }
  private let _projectedValue = ThreadSafe<ProjectedValue?>(nil)
  var projectedValue: ProjectedValue? {
    get { _projectedValue.value }
    set { _projectedValue.value = newValue }
  }
  
  init(wrappedValue: Value?, chain: MDBXChain) {
    self._wrappedValue.value = wrappedValue
    
    var projected = wrappedValue?.wrapped(chain) as? ProjectedValue
    projected?.database = MEWwalletDBImpl.shared
    self._projectedValue.value = projected
    self._chain.value = chain
  }
  
  convenience init() {
    self.init(wrappedValue: nil, chain: .invalid)
  }
  
  // MARK: - Refreshed
  
  internal func refreshProjected(wrapped: Value?) {
    _wrappedValue.value = wrapped
    var projected = wrappedValue?.wrapped(chain) as? ProjectedValue
    projected?.database = MEWwalletDBImpl.shared
    _projectedValue.value = projected
  }
}

extension Optional: ProtoWrappedMessage, Sendable where Wrapped == any Sendable {
  typealias T = (any Sendable)?
  func wrapped(_ chain: MDBXChain) -> (any Sendable)? {
    return nil
  }
}
