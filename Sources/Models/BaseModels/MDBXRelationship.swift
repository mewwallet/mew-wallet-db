//
//  File.swift
//  
//
//  Created by Nail Galiaskarov on 6/22/21.
//

import Foundation

public final class MDBXRelationship<K: MDBXKey, T: MDBXObject> {
  private let _uuid = UUID().uuidString
  private let _table: MDBXTableName
  
  init(_ table: MDBXTableName) {
    _table = table
  }
  
  // MARK: - Load
  
  func getRelationship(_ range: MDBXKeyRange, policy: RelationshipLoadPolicy, order: MDBXReadOrder, chain: MDBXChain, database: WalletDB?) throws -> [T] {
    guard let database = database else {
      return LRU.cache.value(forKey: _uuid + chain.hexString) ?? []
    }
    
    switch policy {
    case .cacheOrLoad:
      if let _data: [T] = LRU.cache.value(forKey: _uuid + chain.hexString) {
        return _data
      }
      fallthrough
    case .ignoreCache:
      let data: [T] = try database.fetch(range: range, from: _table, order: order)
      LRU.cache.setValue(data, forKey: _uuid + chain.hexString)
      return data
    }
  }
  
  func getRelationship(_ keys: [MDBXKey], policy: RelationshipLoadPolicy, chain: MDBXChain, database: WalletDB?) throws -> [T] {
    guard let database = database else {
      return LRU.cache.value(forKey: _uuid + chain.hexString) ?? []
    }
    
    switch policy {
    case .cacheOrLoad:
      if let _data: [T] = LRU.cache.value(forKey: _uuid + chain.hexString) {
        return _data
      }
      fallthrough
    case .ignoreCache:
      let data: [T] = try database.fetch(keys: keys, from: _table)
      LRU.cache.setValue(data, forKey: _uuid + chain.hexString)
      return data
    }
  }
  
  func updateData(_ data: [T], chain: MDBXChain) {
    LRU.cache.setValue(data, forKey: _uuid + chain.hexString)
  }
}

extension MDBXRelationship: @unchecked Sendable { }
