//
//  File.swift
//  
//
//  Created by Mikhail Nikanorov on 2/6/23.
//

import Foundation

#if os(iOS) || os(tvOS)
import UIKit

/// Notification that cache should be cleared
let LRUCacheMemoryWarningNotification: NSNotification.Name =
UIApplication.didReceiveMemoryWarningNotification

#else

/// Notification that cache should be cleared
let LRUCacheMemoryWarningNotification: NSNotification.Name =
  .init("LRUCacheMemoryWarningNotification")

#endif

struct LRU {
  static let cache = LRU.Cache<String>()
  
  final class Cache<Key: Hashable> {
    
    private var values: [Key: Container] = [:]
    private unowned(unsafe) var head: Container?
    private unowned(unsafe) var tail: Container?
    private let lock: NSLock = .init()
    private var token: AnyObject?
    private let notificationCenter: NotificationCenter
    
    /// The current total cost of values in the cache
    private(set) var totalCost: Int = 0
    
    /// The maximum total cost permitted
    var totalCostLimit: Int {
      didSet { clean() }
    }
    
    /// The maximum number of values permitted
    var countLimit: Int {
      didSet { clean() }
    }
    
    /// Initialize the cache with the specified `totalCostLimit` and `countLimit`
    init(
      totalCostLimit: Int = .max,
      countLimit: Int = .max,
      notificationCenter: NotificationCenter = .default
    ) {
      self.totalCostLimit = totalCostLimit
      self.countLimit = countLimit
      self.notificationCenter = notificationCenter
      
      self.token = notificationCenter.addObserver(
        forName: LRUCacheMemoryWarningNotification,
        object: nil,
        queue: nil
      ) { [weak self] _ in
        self?.removeAllValues()
      }
    }
    
    deinit {
      if let token = token {
        notificationCenter.removeObserver(token)
      }
    }
  }
}

// MARK: - LRU.Cache + Accessors

extension LRU.Cache {
  /// The number of values currently stored in the cache
  var count: Int {
    values.count
  }
  
  /// Is the cache empty?
  var isEmpty: Bool {
    values.isEmpty
  }
  
  /// Insert a value into the cache with optional `cost`
  func setValue<Value>(_ value: Value?, forKey key: Key, cost: Int = 0) {
    guard let value = value else {
      let _: Value? = removeValue(forKey: key)
      return
    }
    lock.lock()
    if let container = values[key] {
      container.value = value
      totalCost -= container.cost
      container.cost = cost
      remove(container)
      append(container)
    } else {
      let container = Container(
        value: value,
        cost: cost,
        key: key
      )
      values[key] = container
      append(container)
    }
    totalCost += cost
    lock.unlock()
    clean()
  }
  
  /// Remove a value  from the cache and return it
  @discardableResult func removeValue<Value>(forKey key: Key) -> Value? {
    lock.lock()
    defer { lock.unlock() }
    guard let container = values.removeValue(forKey: key) else {
      return nil
    }
    remove(container)
    totalCost -= container.cost
    return container.value as? Value
  }
  
  /// Fetch a value from the cache
  func value<Value>(forKey key: Key) -> Value? {
    lock.lock()
    defer { lock.unlock() }
    if let container = values[key] {
      remove(container)
      append(container)
      return container.value as? Value
    }
    return nil
  }
  
  /// Remove all values from the cache
  func removeAllValues() {
    lock.lock()
    values.removeAll()
    head = nil
    tail = nil
    lock.unlock()
  }
}

// MARK: LRU.Cache + Container

private extension LRU.Cache {
  final class Container {
    var value: Any
    var cost: Int
    let key: Key
    unowned(unsafe) var prev: Container?
    unowned(unsafe) var next: Container?
    
    init(value: Any, cost: Int, key: Key) {
      self.value = value
      self.cost = cost
      self.key = key
    }
  }
  
  // Remove container from list (must be called inside lock)
  func remove(_ container: Container) {
    if head === container {
      head = container.next
    }
    if tail === container {
      tail = container.prev
    }
    container.next?.prev = container.prev
    container.prev?.next = container.next
    container.next = nil
  }
  
  // Append container to list (must be called inside lock)
  func append(_ container: Container) {
    assert(container.next == nil)
    if head == nil {
      head = container
    }
    container.prev = tail
    tail?.next = container
    tail = container
  }
  
  // Remove expired values (must be called outside lock)
  func clean() {
    lock.lock()
    defer { lock.unlock() }
    while totalCost > totalCostLimit || count > countLimit,
          let container = head
    {
      remove(container)
      values.removeValue(forKey: container.key)
      totalCost -= container.cost
    }
  }
}
