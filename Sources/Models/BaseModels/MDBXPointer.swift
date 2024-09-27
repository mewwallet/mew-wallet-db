//
//  File.swift
//  
//
//  Created by Nail Galiaskarov on 5/31/21.
//

import Foundation
import mdbx_ios

enum RelationshipLoadPolicy {
  case ignoreCache
  case cacheOrLoad
}

// TODO: Re-do to @propertyWrapper when "Property wrappers currently cannot define an 'async' or 'throws' accessor" will be fixed

public final class MDBXPointer<K: MDBXKey, T: MDBXObject>: Sendable {
  private let _uuid = UUID().uuidString
  private let _table: MDBXTableName
  
  init(_ table: MDBXTableName) {
    _table = table
  }
  
  func getData(key: K, policy: RelationshipLoadPolicy, chain: MDBXChain, database: (any WalletDB)?) throws -> T {
    guard let database = database else {
      guard let data: T = LRU.cache.value(forKey: _uuid + chain.hexString) else { throw MDBXError.notFound }
      return data
    }
    switch policy {
    case .cacheOrLoad:
      if let data: T = LRU.cache.value(forKey: _uuid + chain.hexString) {
        return data
      }
      fallthrough
    case .ignoreCache:
      var data: T = try database.read(key: key, table: _table)
      data.database = database
      LRU.cache.setValue(data, forKey: _uuid + chain.hexString)
      return data
    }
  }
    
  func updateData(_ data: T, chain: MDBXChain) {
    LRU.cache.setValue(data, forKey: _uuid + chain.hexString)
  }
}

// MARK: RelationshipLoadPolicy + Equatable

extension RelationshipLoadPolicy: Equatable {
  static func ==(lhs: RelationshipLoadPolicy, rhs: RelationshipLoadPolicy) -> Bool {
    switch (lhs, rhs) {
    case (.ignoreCache, .ignoreCache): return true
    case (.cacheOrLoad, .cacheOrLoad): return true
    default:                           return false
    }
  }
}
