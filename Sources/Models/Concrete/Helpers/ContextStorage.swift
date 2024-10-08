//
//  File.swift
//  
//
//  Created by Mikhail Nikanorov on 7/14/22.
//

import Foundation
import mew_wallet_ios_extensions

@propertyWrapper
public final class ContextStorage<T>: Sendable where T: Sendable {
  public let _wrappedValue: ThreadSafe<T?>
  public var wrappedValue: T? {
    set { _wrappedValue.value = newValue }
    get { _wrappedValue.value }
  }
  
  public init(wrappedValue: T?) {
    _wrappedValue = .init(wrappedValue)
  }
  
  public convenience init() {
    self.init(wrappedValue: nil)
  }
}
