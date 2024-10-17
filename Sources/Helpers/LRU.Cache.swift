//
//  File.swift
//  
//
//  Created by Mikhail Nikanorov on 2/6/23.
//

import Foundation
import mew_wallet_ios_extensions

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
  
  final class Cache<Key: Hashable & Sendable>: Sendable {
    private let lock: NSLock = .init()
    private let values = ThreadSafe<[Key: Container]>([:])
    private let head = ThreadSafe<Container?>(nil)
    private let tail = ThreadSafe<Container?>(nil)
    private let token = ThreadSafe<(any NSObjectProtocol)?>(nil)
    private let notificationCenter: NotificationCenter
    
    /// The current total cost of values in the cache
    private let totalCost = ThreadSafe<Int>(0)
    
    /// The maximum total cost permitted
    let _totalCostLimit: ThreadSafe<Int>
    var totalCostLimit: Int {
      get { return _totalCostLimit.value }
      set {
        _totalCostLimit.value = newValue
        clean()
      }
    }
    
    /// The maximum number of values permitted
    let _countLimit: ThreadSafe<Int>
    var countLimit: Int {
      get { _countLimit.value }
      set {
        _countLimit.value = newValue
        clean()
      }
    }
    
    /// Initialize the cache with the specified `totalCostLimit` and `countLimit`
    init(
      totalCostLimit: Int = .max,
      countLimit: Int = .max,
      notificationCenter: NotificationCenter = .default
    ) {
      self._totalCostLimit = .init(totalCostLimit)
      self._countLimit = .init(countLimit)
      self.notificationCenter = notificationCenter
      
      self.token.value = notificationCenter.addObserver(
        forName: LRUCacheMemoryWarningNotification,
        object: nil,
        queue: nil
      ) { [weak self] _ in
        self?.removeAllValues()
      }
    }
    
    deinit {
      if let token = token.value {
        notificationCenter.removeObserver(token)
        self.token.value = nil
      }
    }
  }
}

// MARK: - LRU.Cache + Accessors

extension LRU.Cache {
  /// The number of values currently stored in the cache
  var count: Int {
    values.value.count
  }
  
  /// Is the cache empty?
  var isEmpty: Bool {
    values.value.isEmpty
  }
  
  /// Insert a value into the cache with optional `cost`
  func setValue<Value>(_ value: Value?, forKey key: Key, cost: Int = 0) {
    guard let value = value else {
      let _: Value? = removeValue(forKey: key)
      return
    }
    
    lock.lock()
    self.values.write { values in
      if let container = values[key] {
        container.value = value
        totalCost.value -= container.cost
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
    }
    totalCost.value += cost
    lock.unlock()
    clean()
  }
  
  /// Remove a value  from the cache and return it
  @discardableResult func removeValue<Value>(forKey key: Key) -> Value? {
    lock.lock()
    defer { lock.unlock() }
    guard let container = values.value.removeValue(forKey: key) else {
      return nil
    }
    remove(container)
    totalCost.value -= container.cost
    return container.value as? Value
  }
  
  /// Fetch a value from the cache
  func value<Value>(forKey key: Key) -> Value? {
    lock.lock()
    defer { lock.unlock() }
    if let container = values.value[key] {
      remove(container)
      append(container)
      return container.value as? Value
    }
    return nil
  }
  
  /// Remove all values from the cache
  func removeAllValues() {
    lock.lock()
    values.value.removeAll()
    head.value = nil
    tail.value = nil
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
    if head.value === container {
      head.value = container.next
    }
    if tail.value === container {
      tail.value = container.prev
    }
    container.next?.prev = container.prev
    container.prev?.next = container.next
    container.next = nil
  }
  
  // Append container to list (must be called inside lock)
  func append(_ container: Container) {
    assert(container.next == nil)
    if head.value == nil {
      head.value = container
    }
    container.prev = tail.value
    tail.value?.next = container
    tail.value = container
  }
  
  // Remove expired values (must be called outside lock)
  func clean() {
    lock.lock()
    defer { lock.unlock() }
    while totalCost.value > totalCostLimit || count > countLimit,
          let container = head.value
    {
      remove(container)
      values.value.removeValue(forKey: container.key)
      totalCost.value -= container.cost
    }
  }
}
