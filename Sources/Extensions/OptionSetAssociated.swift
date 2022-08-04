//
//  File.swift
//  
//
//  Created by Mikhail Nikanorov on 8/3/22.
//

import Foundation

public protocol OptionSetAssociated: OptionSet where RawValue: FixedWidthInteger {
  associatedtype AT
  var store: [RawValue: AT?] { get set }
}

extension OptionSetAssociated {
  public init(_ member: Self, value: Self.AT?) {
    self.init(rawValue: member.rawValue)
    self.store[member.rawValue] = value
  }
  
  public init(rawValue: RawValue, value: Self.AT?) {
    self.init(rawValue: rawValue)
    self.store[rawValue] = value
  }
  
  fileprivate init(rawValue: RawValue, store: [RawValue: Self.AT?]) {
    self.init(rawValue: rawValue)
    self.store = store
  }
  
  fileprivate static func combinedStore(_ old: [RawValue: Self.AT?], new: [RawValue: Self.AT?]) -> [RawValue: Self.AT?] {
    new.map {$0.key}.reduce(into: old) {
      $0[$1] = new[$1] ?? old[$1]
    }
  }
  
  fileprivate static func storeOverride(_ store: [RawValue: Self.AT?], member: Self?, value: Self.AT?) -> [RawValue: Self.AT?] {
    guard let member: RawValue = member?.rawValue else { return store }
    var store: [RawValue: Self.AT?] = store
    store[member] = value
    return store
  }
  
  mutating public func formUnion(_ other: __owned Self) {
    self = Self(rawValue: self.rawValue | other.rawValue, store: Self.combinedStore(self.store, new: other.store))
  }
}

extension OptionSet where Self: OptionSetAssociated, Self == Element {
  @discardableResult
  public mutating func insert(_ newMember: Element) -> (inserted: Bool, memberAfterInsert: Element) {
    let oldMember = self.intersection(newMember)
    let shouldInsert = oldMember != newMember
    var result = (inserted: shouldInsert, memberAfterInsert: shouldInsert ? newMember : oldMember)
    if shouldInsert {
      self.formUnion(newMember)
    } else {
      let value = newMember.store[newMember.rawValue] as? Self.AT
      self.store = Self.storeOverride(Self.combinedStore(self.store, new: newMember.store), member: newMember, value: value)
      result.memberAfterInsert.store[newMember.rawValue] = newMember.store[newMember.rawValue]
    }
    return result
  }
  
  @discardableResult
  public mutating func remove(_ member: Element) -> Element? {
    var intersectionElements = intersection(member)
    guard !intersectionElements.isEmpty else {
      return nil
    }
    let store: [RawValue: Self.AT?] = self.store
    self.subtract(member)
    self.store = store
    self.store[member.rawValue] = nil
    let value = store[member.rawValue] as? Self.AT
    intersectionElements.store = Self.storeOverride([:], member: member, value: value)
    return intersectionElements
  }
  
  @discardableResult
  public mutating func update(with newMember: Element) -> Element? {
    let previousValue = self.store[newMember.rawValue] as? Self.AT
    var r = self.intersection(newMember)
    self.formUnion(newMember)
    self.store[newMember.rawValue] = newMember.store[newMember.rawValue]
    if r.isEmpty { return nil } else {
      r.store = Self.storeOverride([:], member: newMember, value: previousValue)
      r.store[newMember.rawValue] = previousValue
      return r
    }
  }
}

// MARK: - Sequence

extension OptionSetAssociated where Self: Sequence {
  public typealias Iterator = OptionSetAssociatedIterator
  
  public func makeIterator() -> OptionSetAssociatedIterator<Self> {
    OptionSetAssociatedIterator(element: self)
  }
  
  public static func - (lhs: Self, rhs: Self) -> Self {
    rhs.reduce(into: lhs) {
      $0.remove($1)
    }
  }
  
  public static func + (lhs: Self, rhs: Self) -> Self {
    rhs.reduce(into: lhs) {
      $0.insert($1)
    }
  }
  
  public static func += (lhs: inout Self, rhs: Self) {
    lhs = lhs + rhs
  }
  
  public static func -= (lhs: inout Self, rhs: Self) {
    lhs = lhs - rhs
  }
}

// MARK: - Subscript

extension OptionSetAssociated {
  public subscript<T>(for member: Self) -> T? {
    self.store[member.rawValue] as? T
  }
}

// MARK: - Iterator

public struct OptionSetAssociatedIterator<Element: OptionSetAssociated>: IteratorProtocol {
  private let value: Element
  
  public init(element: Element) {
    self.value = element
  }
  
  private lazy var remainingBits: Element.RawValue = value.rawValue
  private var bitMask: Element.RawValue = 1
  
  public mutating func next() -> Element? {
    while remainingBits != 0 {
      defer { bitMask = bitMask &* 2 }
      if remainingBits & bitMask != 0 {
        remainingBits = remainingBits & ~bitMask
        let value = self.value.store[bitMask] as? Element.AT
        return Element(rawValue: bitMask, value: value)
      }
    }
    return nil
  }
}
