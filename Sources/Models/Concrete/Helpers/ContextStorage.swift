//
//  File.swift
//  
//
//  Created by Mikhail Nikanorov on 7/14/22.
//

import Foundation

@propertyWrapper
public final class ContextStorage<T> {
  public var wrappedValue: T?
  
  public init(wrappedValue: T?) {
    self.wrappedValue = wrappedValue
  }
  
  public convenience init() {
    self.init(wrappedValue: nil)
  }
}
