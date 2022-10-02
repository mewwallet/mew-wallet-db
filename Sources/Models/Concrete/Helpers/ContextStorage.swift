//
//  File.swift
//  
//
//  Created by Mikhail Nikanorov on 7/14/22.
//

import Foundation

@propertyWrapper
public final class ContextStorage<T> where T: Sendable {
  private let _queue = DispatchQueue(label: "db.contextstorage.queue")
  
  public var _wrappedValue: T?
  public var wrappedValue: T? {
    set {
      _queue.sync {
        _wrappedValue = newValue
      }
    }
    get {
      _wrappedValue
    }
  }
  
  public init(wrappedValue: T?) {
    self.wrappedValue = wrappedValue
  }
  
  public convenience init() {
    self.init(wrappedValue: nil)
  }
}

extension ContextStorage: @unchecked Sendable {}
